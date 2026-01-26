-- This is the first table of ERP
-- I will have the stars to help you identify slight changes between similar codes
-- These brackets  '{}' is to show that these are codes used in the query for checking things, by removing the '--' from the beginning of the code line you will make the line a non-comment
-- If you are following the process please execute the query in order to have a sharper understanding.
-- The other purpose of these brackets with content inside '{ ... }' is to point to a specific code. As a representation of what was stated as code.


-- Let's take a look in this table 
SELECT
cid,
bdate,
gen
FROM bronze.erp_cust_az12
-- Well... there is only three columns so I believe that this table will be quicker to solve.
-- By checking the model ( path: ' ! Walkthrough -- ' > '5th - Build Silver Layer' ) we can connect the column [ cst_key ] from the table 'crm_cust_info' with the column [ cid ] from the this table 'erp_cust_az12'.

-- Let's check the 'crm_cust_info' table
SELECT * FROM silver.crm_cust_info
-- By executing both I could notice that in the column [ cid ] from the table 'erp_cust_az12' there are extra characters 'NAS%' ( '%' means that whatever comes afterwards is upto the database. )


--Let's check if the customer id from the table 'crm_cust_info' is present in this one that we are examining to integrate 'erp_cust_az12'
SELECT
cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%'
-- Yep we found someone and he has the 'NAS%' id/key, so now we are sure that the customer key/id from the table 'crm_cust_info' has the same data as this one 'erp_cust_az12'
-- There is not a reason why we have these 'NAS' so we have to remove it in order to integrate the data without any issue.


-- Removing the 'NAS%' 
SELECT
cid AS Old_cid, -- Comparison purpose
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12

-- Quick check
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)
-- Great there is not a value from this new transformation that is NOT IN the column [ cst_key ] FROM the table 'silver.crm_cust_info'



-- Moving on to the next column [ bdate ]
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END AS cid,
bdate,
gen
FROM bronze.erp_cust_az12
-- Everything is correct it's type is a DATE, but we must check if there is some birthdates out of range.

-- Checking...
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT 
    bdate 
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();
-- We have a problem here there are customers with the birthdate higher than the current {GETDATE ()} date and customers with birth dates lower than 1924 with doesn't make that much of sense.


-- Solving the issue in our main query
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END AS cid,
CASE  -- *
	WHEN bdate > GETDATE() THEN NULL  -- *
	ELSE bdate  -- *
END AS bdate, -- Set future birthdates to NULL,
gen
FROM bronze.erp_cust_az12
-- We have sollved the issue. You might be wondering where is the removal of the customers with the birthdate equal or smaller than 1924?? Well by removing it it can spoil & lead to missing data for future analysis.



-- Moving on to the next column and las one [ gen ]
-- Checking Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM bronze.erp_cust_az12;
-- This isn't good at all, we have empty string, NULLs and different standardization [ F/M & Male/Female ] all in the same place.

-- Let's solve it
SELECT DISTINCT 
    gen AS old_gen, -- Comparison purpose
CASE  -- *
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'  -- *
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'  -- *
	ELSE 'n/a'  -- *
END AS gen  -- *
FROM bronze.erp_cust_az12;
-- We cleaned the empty string and dealt with the standardization


-- Applying the logic into our main query
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END AS cid,
CASE
	WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END AS bdate, -- Set future birthdates to NULL,
CASE  -- *
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'  -- *
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'  -- *
	ELSE 'n/a'  -- *
END AS gen  -- *
FROM bronze.erp_cust_az12


-- inserting the transfomation into the silver layer
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)  -- *
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid
END AS cid,
CASE
	WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
END AS bdate, -- Set future birthdates to NULL,
CASE  
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female' 
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'  
	ELSE 'n/a'  
END AS gen 
FROM bronze.erp_cust_az12

-- You can check the quality in the script 'TestsT4'
-- We are done here! next folder '5th table silver.erp_loc_a101'