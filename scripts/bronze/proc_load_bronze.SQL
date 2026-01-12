/*
========================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
========================================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the 'import data wizard' to load data from CSV files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
   call bronze.loading_tables();
========================================================================================
*/

truncate table `bronze`.`crm_cust_info`;
truncate table `bronze`.`crm_prd_info`;
truncate table `bronze`.`crm_sales_details`;
truncate table `bronze`.`erp_cust_az12`;
truncate table `bronze`.`erp_loc_a101`;
truncate table `bronze`.`erp_px_cat_g1v2`;
/* after truncate and import data from wizard */
CREATE TABLE IF NOT EXISTS bronze.load_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100),
    start_time DATETIME,
    end_time DATETIME,
    duration_seconds DECIMAL(10,3),
    run_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELIMITER $$

CREATE PROCEDURE bronze.loading_tables()
BEGIN
    DECLARE v_start DATETIME;
    DECLARE v_end DATETIME;

    /* ================= crm_cust_info ================= */
    SET v_start = NOW();
    SELECT COUNT(*) FROM bronze.crm_cust_info;   -- simulate load
    SET v_end = NOW();
    INSERT INTO bronze.load_log(table_name,start_time,end_time,duration_seconds)
    VALUES ('crm_cust_info', v_start, v_end,
            TIMESTAMPDIFF(MICROSECOND,v_start,v_end)/1000000);

    /* ================= crm_prd_info ================= */
    SET v_start = NOW();
    SELECT COUNT(*) FROM bronze.crm_prd_info;
    SET v_end = NOW();
    INSERT INTO bronze.load_log VALUES
    (NULL,'crm_prd_info',v_start,v_end,
     TIMESTAMPDIFF(MICROSECOND,v_start,v_end)/1000000,NOW());

    /* ================= crm_sales_details ================= */
    SET v_start = NOW();
    SELECT COUNT(*) FROM bronze.crm_sales_details;
    SET v_end = NOW();
    INSERT INTO bronze.load_log VALUES
    (NULL,'crm_sales_details',v_start,v_end,
     TIMESTAMPDIFF(MICROSECOND,v_start,v_end)/1000000,NOW());

    /* ================= erp_cust_az12 ================= */
    SET v_start = NOW();
    SELECT COUNT(*) FROM bronze.erp_cust_az12;
    SET v_end = NOW();
    INSERT INTO bronze.load_log VALUES
    (NULL,'erp_cust_az12',v_start,v_end,
     TIMESTAMPDIFF(MICROSECOND,v_start,v_end)/1000000,NOW());

    /* ================= erp_loc_a101 ================= */
    SET v_start = NOW();
    SELECT COUNT(*) FROM bronze.erp_loc_a101;
    SET v_end = NOW();
    INSERT INTO bronze.load_log VALUES
    (NULL,'erp_loc_a101',v_start,v_end,
     TIMESTAMPDIFF(MICROSECOND,v_start,v_end)/1000000,NOW());

    /* ================= erp_px_cat_g1v2 ================= */
    SET v_start = NOW();
    SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
    SET v_end = NOW();
    INSERT INTO bronze.load_log VALUES
    (NULL,'erp_px_cat_g1v2',v_start,v_end,
     TIMESTAMPDIFF(MICROSECOND,v_start,v_end)/1000000,NOW());

    /* ===== Final Output ===== */
    SELECT 
        table_name,
        start_time,
        end_time,
        duration_seconds AS load_time_seconds
    FROM bronze.load_log
    WHERE run_time >= DATE_SUB(NOW(), INTERVAL 5 MINUTE)
    ORDER BY id DESC;
END$$

DELIMITER ;
CALL bronze.loading_tables();
