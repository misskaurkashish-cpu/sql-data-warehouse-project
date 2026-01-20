/*
=====================================================================
DDL Script: Create Silver Tables
=====================================================================

Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables
    if they already exist.

    Run this script to re-define the DDL structure of 'bronze' Tables
=====================================================================
*/


SELECT '>> Truncating Table: silver.crm_cust_info' AS message;
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE
        WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_material_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,

    cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;


SELECT '>> Truncating Table: silver.crm_prd_info' AS message;
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info
(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
    prd_nm,
    IFNULL(prd_cost, 0) AS prd_cost,
    CASE
    WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
    WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
    WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
    WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
    ELSE 'n/a'
END AS prd_line
,
    DATE(prd_start_dt) AS prd_start_dt,

DATE(
    DATE_SUB(
        LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
        INTERVAL 1 DAY
    )
) AS prd_end_dt

FROM bronze.crm_prd_info
;


SELECT '>> Truncating Table: silver.crm_sales_details' AS message;
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
 SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
CASE
    WHEN sls_sales IS NULL
      OR sls_sales <= 0
      OR sls_sales != sls_quantity * ABS(sls_price)
    THEN sls_quantity * ABS(sls_price)
    ELSE sls_sales
END AS sls_sales,

sls_quantity,

CASE
    WHEN sls_price IS NULL
      OR sls_price <= 0
    THEN sls_sales / NULLIF(sls_quantity, 0)
    ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details;


SELECT '>> Truncating Table: silver.erp_cust_az12' AS message;
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)

SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
        ELSE cid
    END AS cid,

    CASE
        WHEN bdate > CURDATE() THEN NULL
        ELSE bdate
    END AS bdate,

    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;
 

SELECT '>> Truncating Table: silver.erp_loc_a101' AS message;
TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101
(cid, cntry)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE
    WHEN TRIM(cntry) = 'DE' THEN 'Germany'
    WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry) IN ('Australia') THEN 'Australia'
    WHEN TRIM(cntry) = 'Canada' THEN 'Canada'
	WHEN TRIM(cntry) = 'France' THEN 'france'
	WHEN TRIM(cntry) IN ('United Kingdom') THEN 'United Kingdom'

    ELSE 'n/a'
END AS cntry
FROM bronze.erp_loc_a101;



SELECT '>> Truncating Table: silver.crm_cust_info' AS message;
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.erp_px_cat_g1v2
(id, cat, subcat, maintenance)
SELECT
    id,
    CASE
        WHEN cat  ='Accessories' THEN 'Accessories'
        WHEN cat = 'Clothing'   THEN 'Clothing'
        WHEN cat = 'Components' THEN 'Components'
        ELSE 'n/a'
    END AS cat,
    CASE
    WHEN subcat IN ('13060','Male','Female','17983','14101','18701') THEN 'n/a'
    ELSE TRIM(subcat)
END AS subcat,
     CASE
            WHEN maintenance  ='yes' THEN 'yes'
        WHEN maintenance = 'no'   THEN 'no'
        else 'n/a'
END AS maintenanceS
FROM bronze.erp_px_cat_g1v2;

