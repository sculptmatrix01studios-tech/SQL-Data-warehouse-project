/* Now we will clean the second table [ bronze.crm_prd_info ] to load to [ silver.crm_prd_info ]

Note: 
	- Stars will be used to indicate slight changes [ --* ]
	- The solution is in order left to right according to the columns in the table
*/


-- Checking for data quality issues 
-- main table query:
SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info


-- Starting with the first column the PK [ prd_id ]
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*) 
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
-- It's clean



-- Now moving to the next [ prd_key ]
-- What has to be done now is to slipt the prd_key into 2 new columns. [ Category ]

SELECT
	prd_id,
	prd_key,
	SUBSTRING(prd_key, 1, 5) AS cat_id, -- *
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
-- Now in our data base there is a column from another source system that we can use to join


-- The column which contains the data in question:
SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2 
-- But there is an issue, the separetors are different. ( '_' != '-' )
-- Solution:
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- *
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
-- We just replaced the character to match the one from the other table

-- Now a quick check to see if everything is correct
-- Checking if there is an info. not matching the column from the table which we want to join to
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN  -- *
(SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)  -- * 
-- From the result after executing, we have some values but they are not bad because our only concern is the separator character [ '-' | '_' ]    
-- So the first part of extration is done


-- Now the second part
-- the extraction of the product key itself [ prd_key ]
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  -- *
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
-- Why we have done this? in order to join this table with the sales table, because they have a relatioship in one of their columns.


-- Quick check to see if there are matching between the tables
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN   -- ( Just use 'IN' instead of 'NOT IN' to find matching )
(SELECT sls_prd_key FROM bronze.crm_sales_details)  -- *
-- Well there is a lot of information that is not in there...

-- Let's check individually
SELECT sls_prd_key FROM bronze.crm_sales_details WHERE sls_prd_key LIKE 'FK%'   -- [I could just select it and execute individually but the goal is that you the viewer can understand what is going on. ]
-- Appearantly there isn't any 'FK' product keys... Which means that there is any order placed with this product.
-- Still there is no problem, we are satified with the results. So this column is done



-- Moving on to the next [ prd_nm ]
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    prd_nm 
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
-- Everything clean so far. (But still I might use the TRIM function just to prevent future data do leak out of the table)



-- Moving on to the next [ prd_cost ]
-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT 
    prd_cost 
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Well we have NULLs. (Depending on the business each business has their own way to handle the NULLs. In this case we will use 0 instead.)
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,  -- *
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
-- This step & column are done. (Tests script is available, name: 'TestsT2')


-- Moving on [ prd_line ]
-- Data Standardization & Consistency
SELECT DISTINCT 
    prd_line 
FROM bronze.crm_prd_info;

-- Let's normalize them as we know.
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE -- *
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain' -- *
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'  -- *
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'  -- *
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring' -- *
		ELSE 'n/a'  -- *
	END AS prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info



-- Moving on to the last columns [ prd_start_dt | prd_end_dt ]
-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT 
    * 
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
-- This doesn't make sense so we will solve it with logic


-- So based on the analyze ( go to the path [ '! walkthrough -- ' > '5th - Build Silver Layer' ] there is an image called "Logic for the starting time & end time" )
/* Here is the context:
			- 4th group of data is the right option
			- The logic is that the starting date of the current cannot be greater than the next one and so on.
			- The next one cannot start with the exact date as the previous one's end_date so we need to subtract one from that value (-1)
			- NULL in that image isn't a threat because it just means that there is no date after that one. ( no end/Current )
*/

-- Applying the logic
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE 
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain' 
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'  
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'  
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring' 
		ELSE 'n/a'  
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt, -- *
	CAST(
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1   -- *
		AS DATE  -- *
	) AS prd_end_dt  -- *
FROM bronze.crm_prd_info
-- WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')      -- { You turn can it into code, just delete the [ -- ] before the query. The purpose is just to check if the logic is correct}

/* What was changed:
				- We casted the dates with the CAST fuction. 
				Why? Because when the data is DATETIME and its time is all 0s so it becomes irrelevant to keep that way, so it is important to make it easier to read.
				- We used LEAD because it fits perfectly our logic
				- Deducted one ( - 1 ) as a final touch of the logic.
*/


-- There is one thing I would like you viewer to have in mind. The Silver DDL script is Totally fine but originally it was using the same meta data as the Bronze and had some columns missing so is just to say that the DDL in this process usually changes
-- I did leave this clear because there is a chance that you've seen the video and noticed it but the scripts outside the " ! Walkthrough -- " Folder are the final scripts (in case you need to visualize the process in your own device/database.)



-- Time to insert the data

INSERT INTO silver.crm_prd_info (  -- *
			prd_id,  -- *
			cat_id,  -- * 
			prd_key,  -- *
			prd_nm,  -- *
			prd_cost,  -- *
			prd_line,  -- *
			prd_start_dt,  -- *
			prd_end_dt  -- *
		)  -- *
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,  
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE 
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain' 
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'  
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'  
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring' 
		ELSE 'n/a'  
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt, 
	CAST(
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1   
		AS DATE  
	) AS prd_end_dt  
FROM bronze.crm_prd_info

-- Looking at the Table
SELECT TOP 1000 * FROM silver.crm_prd_info

-- There is a script for the quality test 'TestsT2'