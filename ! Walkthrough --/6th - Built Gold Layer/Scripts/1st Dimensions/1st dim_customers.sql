/* Here we will do something different.
	Gold Layer generally represents not only technical skill but also business understanding
	so do make/build it we need to divide into 2 sections Fact and Dimension with a star type of schema.

	In this phase we can just select the data from the Silver Layer, because as we know the Bronze Layer has bad data 

	Here is Where my role as A.E. (Analytical Engineer) begins, I will be the bridge from technical information to the business level information.
	What I will do:
				- Create tables (views) with way more familiar names
				- Divide it into more digested model (Star SCHEMA), making it suitable for the consume.

	NOTE:
		- Stars [-- *] and all the previous rules which I set for better understanding, will be used here aswell
		- I recommend you to execute the queries for better understanding.
*/

-- Selecting the database (server was closed, it's another day)
USE DataWarehouse
-- Checking the tables to aggregate and integrate.
SELECT 
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date
FROM silver.crm_cust_info ci

-- Named the table 'ci' because we will join need soon with the other ones.
-- We are done selecting columns from this 'silver.crm_cust_info' table, now let's move.
-- I will avoid inner Joins (only matching data is retrieved from the table that is being joint), due to data loss.
-- Joining strategy will be LEFT JOIN, coming always from a "Master table" (a table that has the main information that allows connecting to the other ones)

-- Joining...
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_gndr,
	ci.cst_create_date,
	ca.bdate,  -- (column selected for the aggregation)
	ca.gen, -- (column selected for the aggregation)
	la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca -- (The table that is being added)
ON		  ci.cst_key = ca.cid -- (Where we are joining)
LEFT JOIN silver.erp_loc_a101 la -- (The table that is being added)
ON		  ci.cst_key = la.cid -- (Where we are joining)

-- We need to check for duplicates that might be introduced by the join logic
SELECT cst_id, COUNT (*) FROM   -- *
(  --*
	SELECT 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate, 
		ca.gen, 
		la.cntry
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca 
	ON		  ci.cst_key = ca.cid 
	LEFT JOIN silver.erp_loc_a101 la 
	ON		  ci.cst_key = la.cid 
)t  GROUP BY cst_id  -- *
HAVING COUNT (*) > 1  -- *
-- All clear!!! let's move on building


-- Another integration issue is that there is to columns providing the gender info. [ci.cst_gndr & ca.gen]
-- Solution is data integration. we need to see it seperatly 
SELECT DISTINCT
	ci.cst_gndr, 
	ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la 
ON		  ci.cst_key = la.cid 
ORDER BY 1,2

/* So there are informations that match and others that don't. 
   This causes NULLs to appear even though the main information isn't NULL. It happens due to the JOIN
   The assurance comes because we ordered them row wise so the position of both is-as it is from the database.
   In this way we can figure out if the X client is actual male/female or n/a.
   That's the moment that we need to talk with the experts to know which table is the master.
   Then whenever the master's information is missing we will tell SQL to use the other table.
*/

-- CRM is the one, now that's apply the logic
SELECT DISTINCT
	ci.cst_gndr, 
	ca.gen,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  -- *
		 ELSE COALESCE (ca.gen, 'n/a')  -- *
	END AS new_gen  -- *
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la 
ON		  ci.cst_key = la.cid 
ORDER BY 1,2
-- And it's working perfectly



-- Applying to the main query
SELECT 
	ci.cst_id,
	ci.cst_key,
	ci.cst_firstname,
	ci.cst_lastname,
	ci.cst_marital_status,
	ci.cst_create_date,
	ca.bdate,  
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr  -- *
		 ELSE COALESCE (ca.gen, 'n/a')  -- *
	END AS new_gen,  -- *
	la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la 
ON		  ci.cst_key = la.cid
-- We applied it & removid the privious ones


-- Giving friendly names
SELECT 
	ci.cst_id			   AS  customer_id,   -- *
	ci.cst_key		       AS  customer_number,   -- *
	ci.cst_firstname	   AS  first_name,   -- *
	ci.cst_lastname		   AS  last_name,   -- *
	la.cntry			   AS  country,   -- *
	ci.cst_marital_status  AS  marital_status,   -- *
	ca.bdate	           AS  birthdate,  -- *
	ci.cst_create_date	   AS  create_date,   -- *
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
		 ELSE COALESCE (ca.gen, 'n/a')  
	END					   AS  gender   -- *
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la 
ON		  ci.cst_key = la.cid

-- Now we need to do one last step which is a surrogate key to act as primery key.

/* Surrogate key is System-generated unique identifier assigned to each record in a table.
   To set them we can do it thorough:
								- DDL-based generation.
								- Query-based using Window function (Row_Number)
   In this case we will use the query-based one.
*/


-- Creating a surrogate key...

SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,    -- *
	ci.cst_id							AS  customer_id,   
	ci.cst_key							AS  customer_number,  
	ci.cst_firstname					AS  first_name,   
	ci.cst_lastname						AS  last_name,  
	la.cntry							AS  country,   
	ci.cst_marital_status				AS  marital_status,   
	ca.bdate							AS  birthdate,  
	ci.cst_create_date					AS  create_date,  
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
		 ELSE COALESCE (ca.gen, 'n/a')  
	END									AS  gender  
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la 
ON		  ci.cst_key = la.cid




-- Last step is to create the object
CREATE VIEW gold.dim_customers AS   -- *
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,    -- *
	ci.cst_id							AS  customer_id,   
	ci.cst_key							AS  customer_number,  
	ci.cst_firstname					AS  first_name,   
	ci.cst_lastname						AS  last_name,  
	la.cntry							AS  country,   
	ci.cst_marital_status				AS  marital_status,   
	ca.bdate							AS  birthdate,  
	ci.cst_create_date					AS  create_date,  
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr 
		 ELSE COALESCE (ca.gen, 'n/a')  
	END									AS  gender  
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la 
ON		  ci.cst_key = la.cid
-- We are all set!!

-- There will be a Quality check script in the folder 'Tests' in the folder '6th - Built Gold Layer' for all the views which we will create.