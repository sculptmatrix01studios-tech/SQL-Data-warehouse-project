/* Now we will build the second dimension
   NOTE:
		- Stars [-- *] and all the previous rules which I set for better understanding, will be used here aswell
		- I recommend you to execute the queries for better understanding.
		- To understand check the Data Integration image
		Path: '! Walkthrough --' > '6th - Built Gold Layer' > file 'Data Integration.png'
*/

-- Checking & Analysing...
SELECT
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pn.prd_end_dt
FROM silver.crm_prd_info pn

-- In this case we will not implement the historical information for this view.
-- So we can filter it out and remove the end date.
SELECT
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt
FROM silver.crm_prd_info pn
WHERE pn.prd_end_dt IS NULL -- Filtering out all historical data


-- Joining...
SELECT
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL 



-- We need to check the quality in this case the uniqueness, in order to join the table with the sales (Fact table in which we will create after this one).
-- Checking the quality
SELECT prd_key, COUNT(*) FROM (
SELECT
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL 
)t GROUP BY prd_key
HAVING COUNT(*) > 1

-- Everything is clean so far, so we are safe to join it
-- Let's add a surrogate key
-- Renaming & Sorting the column order for more logic and readability...

SELECT
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) product_key, -- *
pn.prd_id	AS product_id, -- *
pn.prd_key	AS product_number,  -- *
pn.prd_nm	AS product_name,  -- *
pn.cat_id	AS category_id,  -- *
pc.cat		AS category,  -- *
pc.subcat	AS subcategory,  -- *
pc.maintenance,
pn.prd_cost	AS cost,  -- *
pn.prd_line AS product_line,  -- *
pn.prd_start_dt AS start_date  -- *
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL 


-- Creating the view
CREATE VIEW gold.dim_products AS -- *
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) product_key, 
	pn.prd_id	AS product_id, 
	pn.prd_key	AS product_number,  
	pn.prd_nm	AS product_name,  
	pn.cat_id	AS category_id,  
	pc.cat		AS category,  
	pc.subcat	AS subcategory,  
	pc.maintenance,
	pn.prd_cost	AS cost,  
	pn.prd_line AS product_line,  
	pn.prd_start_dt AS start_date  
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL 

-- A quality check script will be provided in the folder 'Tests'