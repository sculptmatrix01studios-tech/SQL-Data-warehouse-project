-- This is the second table of ERP 'erp_loc_a101'
-- We will clean & transform and then insert into the Silver Layer 
-- I will have the stars to help you identify slight changes between similar codes
-- If you are following the process please execute the query in order to have a sharper understanding.



-- By checking the model ( path: ' ! Walkthrough -- ' > '5th - Build Silver Layer' ) we can also connect the column [ cst_key ] from the table 'crm_cust_info' with the column [ cid ] from the this table 'erp_loc_a101'.
-- Checking the similarities between the tables
SELECT 
cid,
cntry
FROM bronze.erp_loc_a101;

SELECT cst_key FROM silver.crm_cust_info;
-- So by checking it we can see that there is a difference that can hinder which is the '-' separating the values in the table 'erp_loc_a101'. We must remove it because there is no need for this character '-'


-- Removing...
SELECT 
REPLACE(cid, '-', '') cid, -- *
cntry
FROM bronze.erp_loc_a101;

-- let's check if there is any other difference
SELECT 
REPLACE(cid, '-', '') cid, -- *
cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info) 
-- It's all clear!



-- Moving to the next column [ cntry ] 
-- There is alot of values in there lets distinct it.
SELECT DISTINCT 
    cntry 
FROM bronze.erp_loc_a101
ORDER BY cntry;
-- Trouble here, same as what happened with the column [gen] in the previous table 'erp_cust_az12'

-- Solving & applying in our main query
SELECT 
REPLACE(cid, '-', '') cid, 
CASE  -- *
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'  -- *
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'  -- *
	WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'  -- *
	ELSE TRIM(cntry)  -- *
END AS cntry  -- *
FROM bronze.erp_loc_a101;

-- Great, let's insert the data into the Silver Layer
INSERT INTO silver.erp_loc_a101  -- *
(cid, cntry)
SELECT 
REPLACE(cid, '-', '') cid, 
CASE  
	WHEN TRIM(cntry) = 'DE' THEN 'Germany'  
	WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'  
	WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'  
	ELSE TRIM(cntry) 
END AS cntry 
FROM bronze.erp_loc_a101;

-- There is a script in order for you to check the quality, 'Tests5' is the script name 
-- Job here is done, but we aren't. Let's move to the last table 'silver.erp_px_cat_g1v2'