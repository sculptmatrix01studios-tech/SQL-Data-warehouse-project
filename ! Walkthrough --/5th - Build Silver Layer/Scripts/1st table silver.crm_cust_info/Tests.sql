-- ====================================================================
-- Checking 'silver.crm_cust_info' Quality
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- It is CLEAN!

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key -- Change the column name to check for each one
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);  -- The values in parentises should be the same as the one in SELECT statement
-- It is CLEAN with no SPACES!

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_gndr -- Change the column name to check for each one
FROM silver.crm_cust_info;
-- It is CLEAN & Normalized!

-- Look at the table
SELECT TOP 1000 * FROM silver.crm_cust_info