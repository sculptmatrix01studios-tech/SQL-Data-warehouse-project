/* I will walk you through the process of cleaning & loading the silver table.
I had to split each table process into Folders to avoid a mess and also overload of information.

As the Folder name suggests we will start with the table [ silver.crm_cust_info ]

So our first process is to check the quality of the Bronze Layer and identify the issues
so we can solve accordingly.

Note: Stars will be used to indicate slight changes [ --* ]
*/


-- Analyzing the table and checking the columns 
SELECT 
*
FROM bronze.crm_cust_info
-- So the decision after analysing  is that we will solve column by column from left to right.
-- First thing to check will be the primary key, and it cannot contain NULLs nor Duplicates.



-- (This is the first test script)
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*) 
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- After checking there was found 6 Rows duplicated in which there is 1 NULL as well.



--(Transformating process)

-- Before starting with the transformation we will take one ID value so we can analyze and choose the valid one.
SELECT 
*
FROM bronze.crm_cust_info
WHERE cst_id = 29466
-- By looking to the data, the valid one will be the one with the most recent date.

-- Solution
SELECT
*
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL -- Filtering the NULLs out
)t WHERE flag_last = 1  -- Filtering out all the values that are greater than 1 by using the flag
-- Now we have a base & clean table where we can keep on checking the other columns and keep on cleaning.
-- Why this is the main reference of the clean table? (FROM subquery). A.: Because since the ID is a primery key it affectS the table structure, so for that we need it as the table we're the data is being taken from.



-- Moving on to the next columns [ cst_key | cst_firstname | cst_lastname | cst_marital_status | cst_gndr ]
-- These are string values and the Goal is to check and clean unwanted spaces.
-- So the logic of the query will be: If the original value is not equal to the same value after trimming, it mmeans there are spaces!

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key 
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key);
-- Here the quality is GOOD!

SELECT 
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
-- Here the quality is BAD!

SELECT 
    cst_lastname 
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
-- Here the quality is BAD!

SELECT 
    cst_marital_status 
FROM bronze.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);
-- Here the quality is GOOD!


SELECT 
    cst_gndr 
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
-- Here the quality is also GOOD!



-- Transforming the data
-- Now we will trasform the BAD ones, but for this we need to remove '*' and mention each column into the SELECT statement

-- Main table query:
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname, -- *
TRIM(cst_lastname) AS cst_lastname,  --*
cst_marital_status,
cst_gndr,
cst_create_date
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL 
)t WHERE flag_last = 1




-- Moving on to the next columns [ cst_marital_status | cst_gndr ]
-- Here the quality check is the consistency of values in low cardinality columns
-- The Goal is to make these values clear and meaningful. Hence avoiding abbreviated terms

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM bronze.crm_cust_info;
-- The values in there are abbreviated and the goal is to not find result in this query.

-- Soluction
-- Main table query:
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname, 
TRIM(cst_lastname) AS cst_lastname,
CASE -- *
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'  -- *
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'  -- *
	ELSE 'n/a'  -- *
END AS cst_marital_status, -- *
CASE  -- *
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'  -- *
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'  -- *
	ELSE 'n/a'  -- *
END AS cst_gndr,  -- *
cst_create_date
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL 
)t WHERE flag_last = 1

/* Context of what happened:
                    - Used 'CASE WHEN... ELSE... END' to transform the values abbreviated (Normalization)
                    - Switched the main value ( cst_gndr ) to [ TRIM (cst_gndr) ].
                    The operation has the goal to prevent unwanted spaces, preventing missing data the future after new data is inserted (good practice)
                    - ADD 'UPPER' making it [ UPPER(TRIM (cst_gndr)) ].
                    This is to prevent missing data due to the CAPS variation.
                    It means that this value 'F' is not equal to this value 'f'.
*/



-- For the last column [ cst_create_date ] there is nothing to do because in the DDL it is already specified as a DATE so when loading it will run smoothly.



-- Last step is to load everything

INSERT INTO silver.crm_cust_info ( -- *
    cst_id,  -- *
    cst_key,  -- *
    cst_firstname,  -- *
    cst_lastname,
    cst_marital_status,  -- *
    cst_gndr,  -- *
    cst_create_date)  -- *

SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname, 
TRIM(cst_lastname) AS cst_lastname,
CASE 
	WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'  
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'  
	ELSE 'n/a'  
END AS cst_marital_status, 
CASE  
	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'  
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'  
	ELSE 'n/a'  
END AS cst_gndr,  
cst_create_date
FROM(
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL 
)t WHERE flag_last = 1

-- Now there is a quality check script [ Tests (is the name of the .sql file) ] separated so you can check the quality of the Silver Layer one by one. 