-- This is the third and last table of ERP 'erp_px_cat_g1v2'
-- We will clean & transform and then insert into the Silver Layer 
-- I will have the stars to help you identify slight changes between similar codes
-- If you are following the process please execute the query in order to have a sharper understanding.
-- As usually the solution will be column by column.

-- By checking the model ( path: ' ! Walkthrough -- ' > '5th - Build Silver Layer' ) the relations is between the column [ prd_key ] from the table 'crm_prd_info' with the column [ id ] from the this table 'erp_px_cat_g1v2'.
-- And in the Silver Layer we created an extra column [cat_id] which was derived from the column [ prd_key ] from the table 'crm_prd_info', for the very purpose to join with this one 'erp_px_cat_g1v2'

SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2
-- So our column here [ id ] is good enough, so there is nothing we need to do here.


-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);
-- Impressive, everything is clean here, inventory data are usually organized because there is more control over the data that gets in.



-- How about: Data Standardization & Consistency

SELECT DISTINCT 
    cat 
FROM bronze.erp_px_cat_g1v2;
-- Seems Good to me 

SELECT DISTINCT 
    subcat 
FROM bronze.erp_px_cat_g1v2;
-- Seems good so far

SELECT DISTINCT 
    maintenance 
FROM bronze.erp_px_cat_g1v2;
-- Perfect, all clear!

-- Time to load
INSERT INTO silver.erp_px_cat_g1v2  -- *
(id, cat, subcat, maintenance)  -- *
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2

-- Looking at the table
SELECT * FROM silver.erp_px_cat_g1v2
-- We are done!

-- Quality check script is available 'TestsT6'
-- The next step is to gather all the final versions of the loading query from each table and make a procedure.
-- Path: '! Walkthrough --' > '5th - Build Silver Layer' > file name 'Procedure & Load of Silver Layer.sql'