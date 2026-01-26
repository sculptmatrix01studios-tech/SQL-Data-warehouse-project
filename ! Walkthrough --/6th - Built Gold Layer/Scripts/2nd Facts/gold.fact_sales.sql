/* Last view of our Gold Layer for this project. It will be a fact table.
   NOTE:
		- I recommend you to execute the queries for better understanding.
		- To understand check the Data Integration image
		Path: '! Walkthrough --' > '6th - Built Gold Layer' > file 'Data Integration.png'
*/

-- Checking & Analysing
SELECT
sd.sls_ord_num,
sd.sls_prd_key,
sd.sls_cust_id,
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
FROM silver.crm_sales_details sd
-- This is clearly a fact table, it contains factual information.
-- We will join the dimensions here by using their surrogate keys.



-- Joining, naming & creating the view...
CREATE VIEW gold.fact_sales AS
SELECT
sd.sls_ord_num  AS order_nunmber,
pr.product_key, 
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt  AS shipping_date,
sd.sls_due_dt   AS due_date,
sd.sls_sales    AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id