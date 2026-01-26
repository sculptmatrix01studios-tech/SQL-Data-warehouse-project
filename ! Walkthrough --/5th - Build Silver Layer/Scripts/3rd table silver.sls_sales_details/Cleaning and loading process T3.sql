-- Last table of the CRM
-- Star will be used [ -- * ]


-- Step 1
-- Analysing & checking.
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
-- WHERE sls_ord_num != TRIM(sls_ord_num)  -- {You can turn this into code. It's a quick check for unwanted spaces}
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)  -- Checking integrity
-- WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_prd_info) -- Checking also for integrity

--It's all clear, the columns [ sls_ord_num | sls_prd_key | sls_cust_id ] are clear



-- Moving to the next ones [ sls_order_dt | sls_ship_dt | sls_due_dt ]
-- We have to change the format because they are dates
-- Let's check column by column


-- First one [ sls_order_dt ]
SELECT 
	sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
-- We have a lot of 0s and these ones along with negative numbers cannot be casted into dates.

-- Replacing the 0s for NULLs
SELECT 
	NULLIF(sls_order_dt, 0) AS sls_order_dt  -- *
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 

-- Now let's limite the length so anything greater than 8 digits is out. (because they are not considered as dates)
-- Set boundaries of the date range
 SELECT 
	NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8  -- Length  
OR sls_order_dt > 20500101  -- Boundary range
OR sls_order_dt < 19000101;  -- Boundary range


--Applying the logic in the main query
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN (sls_order_dt) != 8 THEN NULL  -- *
	 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)  -- * 
END AS sls_order_dt,  -- *
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details

-- Double CAST because we can't convert INT to DATE straight away. You need to INT > VARCHAR > DATE (here in SQL SERVER)


-- The logic goes for the other remaining two columns [ sls_ship_dt | sls_due_dt ]
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN (sls_order_dt) != 8 THEN NULL
	 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LEN (sls_ship_dt) != 8 THEN NULL  -- *
	 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)  -- * 
END AS sls_ship_dt,  -- *
CASE WHEN sls_due_dt = 0 OR LEN (sls_due_dt) != 8 THEN NULL  -- *
	 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)  -- * 
END AS sls_due_dt,  -- *
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details



-- Let's Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;
-- That's really GOOD, no need for transformations or clean ups.



-- Moving to the last three [ sls_sales | sls_quantity | sls_price ]
/* Business Rule here:
				- Σ Sales = Quantity * Price
				- Negative, Zeros, NULLs are NOT allowed!
*/

-- Let's check if there is anything breking this rule
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
-- too much errors we have to solve it.
-- This step requires external analyse as we've done with the date logic
-- It is important to consult the experts about logic that you find out in order to see if it matches with their goals or not.
/* Commun cases and their solutions:
							#1 Data issues will be fixed direct in source system.
							#2 Data Issues has to be fixed in data warehouse.

Rules for this case:
				- If Sales is negative, zero, or null, derive it using Quantity and Price.
				- If Price is zero or null, calculate it using Sales and Quantity
				- If Price is negative, convert it to a positive value
*/


-- Applying the logic & comparing
SELECT DISTINCT
sls_sales AS old_sls_sales,  -- Comparison purpose
sls_price AS old_sls_price,  -- Comparison purpose
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
sls_quantity,  -- Sales quantity is ok so we leave it as it is
CASE 
	WHEN sls_price IS NULL OR sls_price <= 0 
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price  -- Derive price if original value is invalid
END AS sls_price
FROM bronze.crm_sales_details

/* What was done? 
			- Applied the logic using case When
			- Used ABS (Absolute) to prevent negative values in sls_price
			- Distincted to not have repeated values
			- Used old columns for comparison check.
			- Replaced sls_quantity 0 values with NULLs to avoid "Divided by Zero ERROR"
*/




-- Let's integrate this logic in our table:
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN (sls_order_dt) != 8 THEN NULL
	 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LEN (sls_ship_dt) != 8 THEN NULL  
	 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)   
END AS sls_ship_dt,  
CASE WHEN sls_due_dt = 0 OR LEN (sls_due_dt) != 8 THEN NULL  
	 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)  
END AS sls_due_dt, 
CASE -- *
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) -- *
	THEN sls_quantity * ABS(sls_price)  -- *
	ELSE sls_sales  -- *
END AS sls_sales,  -- *
sls_quantity,
CASE  -- *
	WHEN sls_price IS NULL OR sls_price <= 0  -- *
	THEN sls_sales / NULLIF(sls_quantity, 0)  -- *
	ELSE sls_price  -- *
END AS sls_price  -- *
FROM bronze.crm_sales_details
-- Beautiful


-- The DDL is already correct from the [ 'DDL of Silver Layer.sql' ] file
-- It is just to let aware that the first DDL is not always the same as the first due to the transformations that occur in the data type. Hence changing the metadata

-- Inserting into the table
INSERT INTO silver.crm_sales_details (  -- *
			sls_ord_num,  -- *
			sls_prd_key,  -- * 
			sls_cust_id,  -- *
			sls_order_dt,  -- *
			sls_ship_dt,  -- *
			sls_due_dt,  -- *
			sls_sales,  -- *
			sls_quantity,  -- *
			sls_price  -- *
	)  -- *

SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN (sls_order_dt) != 8 THEN NULL
	 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
END AS sls_order_dt,
CASE WHEN sls_ship_dt = 0 OR LEN (sls_ship_dt) != 8 THEN NULL  
	 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)   
END AS sls_ship_dt,  
CASE WHEN sls_due_dt = 0 OR LEN (sls_due_dt) != 8 THEN NULL  
	 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)  
END AS sls_due_dt, 
CASE 
	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
	THEN sls_quantity * ABS(sls_price)  
	ELSE sls_sales  
END AS sls_sales,  
sls_quantity,
CASE  
	WHEN sls_price IS NULL OR sls_price <= 0  
	THEN sls_sales / NULLIF(sls_quantity, 0)  
	ELSE sls_price  
END AS sls_price  
FROM bronze.crm_sales_details

-- We are done for this table, all the columns are well verified & transformed. Script 'TestsT3' is availible if you need to check by yourself

-- Looking at the table
SELECT TOP 1000 * FROM silver.crm_sales_details