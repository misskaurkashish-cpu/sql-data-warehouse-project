/*
======================================================================
DDL Script: Create Gold Views
======================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables
    (Star Schema).

    Each view performs transformations and combines data from the
    Silver layer to produce a clean, enriched, and business-ready
    dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
======================================================================
*/

-- ======================================================================
-- Create Dimension: gold.dim_customers
-- ======================================================================

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    customer_number,
    first_name,
    last_name,
    country,
    marital_status,
    gender,
    birthdate,
    create_date
FROM (
    SELECT
        ci.cst_id        AS customer_id,
        ci.cst_key       AS customer_number,
        ci.cst_firstname AS first_name,
        ci.cst_lastname  AS last_name,

        /* Country */
        COALESCE(la.cntry, 'UNKNOWN') AS country,

        ci.cst_material_status AS marital_status,

        /* Gender */
        COALESCE(NULLIF(ci.cst_gndr, 'n/a'), ca.gen, 'n/a') AS gender,

        ca.bdate           AS birthdate,
        ci.cst_create_date AS create_date,

        /* Dedup */
        ROW_NUMBER() OVER (
            PARTITION BY ci.cst_id, ci.cst_key
            ORDER BY
                (la.cntry IS NULL),
                ci.cst_create_date DESC
        ) AS rn

    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid
) t
WHERE rn = 1;


-- ======================================================================
-- Create Dimension: gold.dim_product
-- ======================================================================

create view gold.dim_product as
SELECT
   product_id,
    product_number,
    product_name,
    category_id,
    category,
    subcategory,
    maintenance,
    cost,
    product_line,
    start_date
FROM (
    SELECT
        pn.prd_id      AS product_id,
        pn.prd_key     AS product_number,
        pn.prd_nm      AS product_name,
        pn.cat_id      AS category_id,

        pc.cat         AS category,
        pc.subcat      AS subcategory,
        pc.maintenance AS maintenance,

        CAST(pn.prd_cost AS UNSIGNED) AS cost,
        pn.prd_line     AS product_line,
        pn.prd_start_dt AS start_date,

        ROW_NUMBER() OVER (
            PARTITION BY pn.prd_key
            ORDER BY pn.prd_start_dt DESC
        ) AS rn

    FROM silver.crm_prd_info pn
    INNER JOIN silver.erp_px_cat_g1v2 pc   -- 👈 LEFT JOIN nahi
        ON pn.cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL
) t
WHERE rn = 1;

-- ======================================================================
-- Create Dimension: gold.fact_sales
-- ======================================================================
DROP VIEW IF EXISTS gold.fact_sales;

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num   AS order_number,
    pr.product_number,
    cu.customer_key,
    sd.sls_order_dt  AS order_date,
    sd.sls_ship_dt   AS shipping_date,
    sd.sls_due_dt    AS due_date,
    sd.sls_sales     AS sales_amount,
    sd.sls_quantity  AS quantity,
    sd.sls_price     AS price
FROM silver.crm_sales_details sd
INNER JOIN gold.dim_product pr      -- 🔴 LEFT → INNER
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;

 

