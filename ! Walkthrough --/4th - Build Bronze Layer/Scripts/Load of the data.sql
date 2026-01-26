/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;

Details: 
   -- The file delimiter for this CSV file is ",".
   -- The CSV files will be located in the folder "Datasets"
   -- The stars comments " -- * " is to show the lines added for better understanding.

NOTE: 
    This script is done in steps and documentation form, so to get the procedure right away 
    scroll down and copy the last step.

    An alternative is to access the folder "scripts" outside the walkthrough.
===============================================================================
*/


-- 1st version (How to load)

BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  -- Here the location may vary according to where your file is stored.
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK  -- Useful so SQL can go and lock the table after the load. This can improve performance and avoid hinderence.
);

-- testing the quality and see if the number matches with the CSV file. (-1 row because the name of the column is no longer a row)
-- These scripts are used 
SELECT * FROM bronze.crm_cust_info;

-- counting the rows
SELECT COUNT(*) FROM bronze.crm_cust_info;




-- 2nd Version ( FULL LOAD )
TRUNCATE TABLE bronze.crm_cust_info; -- This script is added in order to avoid duplicates when executing the script
GO

BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  -- Here the location may vary according to where your file is stored.
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK 
);
-- This works as a refresh




-- 3rd version ( ADDING THE OTHER FILES )

-- CRM SECTION
TRUNCATE TABLE bronze.crm_cust_info; 
GO

BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK 
);

TRUNCATE TABLE bronze.crm_prd_info; 
GO

BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\prd_info.csv' 
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK 
);

TRUNCATE TABLE bronze.crm_sales_details; 
GO

BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\sales_details.csv' 
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK 
);

-- ERP SECTION
TRUNCATE TABLE bronze.erp_cust_az12; 
GO

BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\cust_az12.csv' 
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK 
);

TRUNCATE TABLE bronze.erp_loc_a101; 
GO

BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\loc_a101.csv' 
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK 
);

TRUNCATE TABLE bronze.erp_px_cat_g1v2; 
GO

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\px_cat_g1v2.csv' 
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
    TABLOCK 
);




-- 4th Version ( CREATING STORED PROCEDURES )

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	-- CRM SECTION
	TRUNCATE TABLE bronze.crm_cust_info; 
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	TRUNCATE TABLE bronze.crm_prd_info; 
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\prd_info.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	TRUNCATE TABLE bronze.crm_sales_details; 
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\sales_details.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	-- ERP SECTION
	TRUNCATE TABLE bronze.erp_cust_az12; 
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\cust_az12.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	TRUNCATE TABLE bronze.erp_loc_a101; 
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\loc_a101.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	TRUNCATE TABLE bronze.erp_px_cat_g1v2; 
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\px_cat_g1v2.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);
END
-- 'GO' had to be remove because it was hindering the procedure



-- 5th Version more professional ( ADDING PRINTS TO TRACK EXECUTE, DEBUG ISSUES, AND UNDERSTAND ITS FLOW ) { PRINT ''} 
-- The stars comments " -- * " will start from here to identify slight changes throught the code.

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	PRINT '===============================================' -- *
	PRINT 'Loading Bronze Layer' -- *
	PRINT '===============================================' -- *
	-- CRM SECTION
	PRINT '-----------------------------------------------' -- *
	PRINT 'Loading CRM Tables' -- *
	PRINT '-----------------------------------------------' -- *

	PRINT '>> Truncating Table: bronze.crm_cust_info' -- *
	TRUNCATE TABLE bronze.crm_cust_info; 

	PRINT '>> Inserting Data into Table: bronze.crm_cust_info' -- *
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	PRINT '>> Truncating Table: bronze.crm_prd_info' -- *
	TRUNCATE TABLE bronze.crm_prd_info; 

	PRINT '>> Inserting Data into Table: bronze.crm_prd_info' -- *
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\prd_info.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	PRINT '>> Truncating Table: bronze.crm_sales_details' -- *
	TRUNCATE TABLE bronze.crm_sales_details; 

	PRINT '>> Inserting Data into Table: bronze.crm_sales_details' -- *
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\sales_details.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	-- ERP SECTION
	PRINT '-----------------------------------------------' -- *
	PRINT 'Loading ERP Tables' -- *
	PRINT '-----------------------------------------------' -- *

	PRINT '>> Truncating Table: bronze.erp_cust_az12' -- *
	TRUNCATE TABLE bronze.erp_cust_az12; 

	PRINT '>> Inserting Data into Table: bronze.erp_cust_az12' -- *
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\cust_az12.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	PRINT '>> Truncating Table: bronze.erp_loc_a101' -- *
	TRUNCATE TABLE bronze.erp_loc_a101; 

	PRINT '>> Inserting Data into Table: bronze.erp_loc_a101' -- *
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\loc_a101.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);

	PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2' -- *
	TRUNCATE TABLE bronze.erp_px_cat_g1v2; 

	PRINT '>> Inserting Data into Table: bronze.erp_px_cat_g1v2' -- *
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\px_cat_g1v2.csv' 
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK 
	);
END

-- Execution command
EXEC bronze.load_bronze



-- 6th Version ( ENSURING ERROR HANDLING, DATA INTEGRETY, AND ISSUE LOGGING FOR EASIER DEBUGGING )

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY -- *
		PRINT '==============================================='
		PRINT 'Loading Bronze Layer' 
		PRINT '===============================================' 
		-- CRM SECTION
		PRINT '-----------------------------------------------' 
		PRINT 'Loading CRM Tables' 
		PRINT '-----------------------------------------------' 

		PRINT '>> Truncating Table: bronze.crm_cust_info' 
		TRUNCATE TABLE bronze.crm_cust_info; 

		PRINT '>> Inserting Data into Table: bronze.crm_cust_info' 
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);

		PRINT '>> Truncating Table: bronze.crm_prd_info' 
		TRUNCATE TABLE bronze.crm_prd_info; 

		PRINT '>> Inserting Data into Table: bronze.crm_prd_info' 
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\prd_info.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);

		PRINT '>> Truncating Table: bronze.crm_sales_details' 
		TRUNCATE TABLE bronze.crm_sales_details; 

		PRINT '>> Inserting Data into Table: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\sales_details.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);

		-- ERP SECTION
		PRINT '-----------------------------------------------' 
		PRINT 'Loading ERP Tables' 
		PRINT '-----------------------------------------------' 

		PRINT '>> Truncating Table: bronze.erp_cust_az12' 
		TRUNCATE TABLE bronze.erp_cust_az12; 

		PRINT '>> Inserting Data into Table: bronze.erp_cust_az12' 
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\cust_az12.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);

		PRINT '>> Truncating Table: bronze.erp_loc_a101' 
		TRUNCATE TABLE bronze.erp_loc_a101; 

		PRINT '>> Inserting Data into Table: bronze.erp_loc_a101' 
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\loc_a101.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);

		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2' 
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; 

		PRINT '>> Inserting Data into Table: bronze.erp_px_cat_g1v2' 
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\px_cat_g1v2.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
	END TRY -- *
	BEGIN CATCH -- *
		PRINT '=========================================='  -- *
		PRINT 'ERROR OCCURED DURING LOAADING BRONZE LAYER'  -- *
		PRINT 'Error Message' + ERROR_MESSAGE();  -- *
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);   -- *
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);  -- *
		PRINT '=========================================='  -- *
	END CATCH -- *
END



-- 7th Version ( TRACK ETL DURATION ) 
-- Helps to identify boottlenecks, optimize performance, monitor trends, detect issues


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME  -- *
	BEGIN TRY 
		PRINT '===============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==============================================='; 
		-- CRM SECTION
		PRINT '-----------------------------------------------'; 
		PRINT 'Loading CRM Tables'; 
		PRINT '-----------------------------------------------'; 

		SET @start_time = GETDATE () -- *
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info; 

		PRINT '>> Inserting Data into Table: bronze.crm_cust_info'; 
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () -- *
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  -- *

		SET @start_time = GETDATE () -- *
		PRINT '>> Truncating Table: bronze.crm_prd_info'; 
		TRUNCATE TABLE bronze.crm_prd_info; 

		PRINT '>> Inserting Data into Table: bronze.crm_prd_info'; 
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\prd_info.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () -- *
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  -- *

		SET @start_time = GETDATE () -- *
		PRINT '>> Truncating Table: bronze.crm_sales_details'; 
		TRUNCATE TABLE bronze.crm_sales_details; 

		PRINT '>> Inserting Data into Table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\sales_details.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () -- *
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  -- *

		-- ERP SECTION
		PRINT '-----------------------------------------------'; 
		PRINT 'Loading ERP Tables';
		PRINT '-----------------------------------------------';

		SET @start_time = GETDATE () -- *
		PRINT '>> Truncating Table: bronze.erp_cust_az12'; 
		TRUNCATE TABLE bronze.erp_cust_az12; 

		PRINT '>> Inserting Data into Table: bronze.erp_cust_az12'; 
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\cust_az12.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () -- *
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  -- *

		SET @start_time = GETDATE () -- *
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101; 

		PRINT '>> Inserting Data into Table: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\loc_a101.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () -- *
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  -- *

		SET @start_time = GETDATE () -- *
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'; 
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; 

		PRINT '>> Inserting Data into Table: bronze.erp_px_cat_g1v2'; 
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\px_cat_g1v2.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () -- *
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  -- *
		
		END TRY 
	BEGIN CATCH 
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOAADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();  
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);   
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);  
		PRINT '=========================================='
	END CATCH 
END

-- Mistake to avoid "; or :" after the '@start_time' or '@end_time'





-- 8th Version and Last ( Calculating the Duration of loading Bronze Layer "Whole Batch" )

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME  -- *
	BEGIN TRY 
		SET @batch_start_time = GETDATE();  -- *
		PRINT '===============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==============================================='; 
		-- CRM SECTION
		PRINT '-----------------------------------------------'; 
		PRINT 'Loading CRM Tables'; 
		PRINT '-----------------------------------------------'; 

		SET @start_time = GETDATE () 
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info; 

		PRINT '>> Inserting Data into Table: bronze.crm_cust_info'; 
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\cust_info.csv'  
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE ()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  
		PRINT '>> ----------------------------------------';  

		SET @start_time = GETDATE () 
		PRINT '>> Truncating Table: bronze.crm_prd_info'; 
		TRUNCATE TABLE bronze.crm_prd_info; 

		PRINT '>> Inserting Data into Table: bronze.crm_prd_info'; 
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\prd_info.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () 
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------------------------------------';  

		SET @start_time = GETDATE () 
		PRINT '>> Truncating Table: bronze.crm_sales_details'; 
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> ----------------------------------------';  

		PRINT '>> Inserting Data into Table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_crm\sales_details.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE () 
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds'; 
		PRINT '>> ----------------------------------------';  

		-- ERP SECTION
		PRINT '-----------------------------------------------'; 
		PRINT 'Loading ERP Tables';
		PRINT '-----------------------------------------------';

		SET @start_time = GETDATE () 
		PRINT '>> Truncating Table: bronze.erp_cust_az12'; 
		TRUNCATE TABLE bronze.erp_cust_az12; 

		PRINT '>> Inserting Data into Table: bronze.erp_cust_az12'; 
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\cust_az12.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE ()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  

		SET @start_time = GETDATE () 
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101; 

		PRINT '>> Inserting Data into Table: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\loc_a101.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE ()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';  -- *
		PRINT '>> ----------------------------------------';  

		SET @start_time = GETDATE ()
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'; 
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; 

		PRINT '>> Inserting Data into Table: bronze.erp_px_cat_g1v2'; 
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\LENOVO\OneDrive\Desktop\Work center\Data analytics\SQL\30 HOUR COURSE\Projects\DWH\Datasets\source_erp\px_cat_g1v2.csv' 
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK 
		);
		SET @end_time = GETDATE ()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF (second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> ----------------------------------------'

		SET @batch_end_time = GETDATE ();  -- *
		PRINT'==========================================='  -- *
		PRINT'Loading Bronze Layer is Completed'  -- *
		PRINT'	 + Total Load Duration:	 ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';  -- *
		PRINT'===========================================' -- *
	END TRY 
	BEGIN CATCH 
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOAADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();  
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);   
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);  
		PRINT '=========================================='
	END CATCH 
END

-- EXECUTION COMMAND (to check the final messaging)
EXEC bronze.load_bronze


/* Conclusion of this step is thet Data Engineering is not all about how to load the data

   But it's how to engineer the whole pipeline, from the errors, duration of the code execution, documentation and etc. To ensure an easy and effective debugging and optimaze workflow.