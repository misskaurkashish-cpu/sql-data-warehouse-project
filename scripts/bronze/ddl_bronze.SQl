/*
========================================================================================
DDL Script: Create Bronze Tables
========================================================================================

Script Purpose:
    This script creates tables in the 'bronze'.
    Run this script to re-define the DDL structure of 'bronze' Tables and see tables and count data in table.
========================================================================================
*/
 /* tables create*/
   
CREATE TABLE crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);
/* ================================
-- Product Information Table
-- ================================ */
CREATE TABLE crm_prd_info (
    prd_id INT AUTO_INCREMENT PRIMARY KEY,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

/*-- ================================
-- Sales Details Table
-- ================================ */
CREATE TABLE crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
); 

CREATE TABLE erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

CREATE TABLE erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);

CREATE TABLE erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
/*-- import table from table data import from wizards */
/* then >>>>*/
select * from crm_cust_info;
select count(*) from crm_cust_info;
select * from crm_prd_info;
select count(*) from crm_prd_info;
select * from crm_sales_details ;
select count(*) from crm_sales_details;
select * from erp_cust_az12;
select count(*) from erp_cust_az12;
select * from erp_loc_a101;
select count(*) from erp_loc_a101;
select * from erp_px_cat_g1v2;
select count(*) from erp_px_cat_g1v2;
