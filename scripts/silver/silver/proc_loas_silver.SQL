/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;

===============================================================================
*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `silver`.`load_silver` $$

CREATE PROCEDURE `silver`.`load_silver`()
BEGIN
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;
    DECLARE v_seconds INT;

    /* ============ CRM CUSTOMER ============ */
    SET v_start = NOW();

    INSERT INTO silver.crm_cust_info
    SELECT * FROM silver.crm_cust_info;

    SET v_end = NOW();
    SET v_seconds = TIMESTAMPDIFF(SECOND, v_start, v_end);

    SELECT
        'crm_cust_info' AS table_name,
        v_start AS start_time,
        v_end AS end_time,
        v_seconds AS seconds,
        CONCAT(v_seconds,' seconds') AS load_time;

    /* ============ CRM PRODUCT ============ */
    SET v_start = NOW();
    INSERT INTO silver.crm_prd_info
    SELECT * FROM silver.crm_prd_info;
    SET v_end = NOW();
    SET v_seconds = TIMESTAMPDIFF(SECOND, v_start, v_end);

    SELECT
        'crm_prd_info',
        v_start, v_end, v_seconds,
        CONCAT(v_seconds,' seconds');

    /* ============ CRM SALES ============ */
    SET v_start = NOW();
    INSERT INTO silver.crm_sales_details
    SELECT * FROM silver.crm_sales_details;
    SET v_end = NOW();
    SET v_seconds = TIMESTAMPDIFF(SECOND, v_start, v_end);

    SELECT
        'crm_sales_details',
        v_start, v_end, v_seconds,
        CONCAT(v_seconds,' seconds');

    /* ============ ERP CUSTOMER ============ */
    SET v_start = NOW();
    INSERT INTO silver.erp_cust_az12
    SELECT * FROM silver.erp_cust_az12;
    SET v_end = NOW();
    SET v_seconds = TIMESTAMPDIFF(SECOND, v_start, v_end);

    SELECT
        'erp_cust_az12',
        v_start, v_end, v_seconds,
        CONCAT(v_seconds,' seconds');

    /* ============ ERP LOCATION ============ */
    SET v_start = NOW();
    INSERT INTO silver.erp_loc_a101
    SELECT * FROM silver.erp_loc_a101;
    SET v_end = NOW();
    SET v_seconds = TIMESTAMPDIFF(SECOND, v_start, v_end);

    SELECT
        'erp_loc_a101',
        v_start, v_end, v_seconds,
        CONCAT(v_seconds,' seconds');

    /* ============ ERP PRODUCT CATEGORY ============ */
    SET v_start = NOW();
    INSERT INTO silver.erp_px_cat_g1v2
    SELECT * FROM silver.erp_px_cat_g1v2;
    SET v_end = NOW();
    SET v_seconds = TIMESTAMPDIFF(SECOND, v_start, v_end);

    SELECT
        'erp_px_cat_g1v2',
        v_start, v_end, v_seconds,
        CONCAT(v_seconds,' seconds');

END$$
DELIMITER ;

call `silver`.`load_silver`;
