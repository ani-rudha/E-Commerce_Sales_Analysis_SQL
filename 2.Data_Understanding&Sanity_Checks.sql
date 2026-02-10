-- ==================================================================================================================================================================
--                                              -: Step 1. Data Understanding & Sanity Checks :-
-- ==================================================================================================================================================================
-- 1.1 Do we have sufficient data across all core entities?
SELECT 
    'customers' AS table_name, COUNT(*) AS row_count
FROM
    customers 
UNION ALL SELECT 
    'products', COUNT(*)
FROM
    products 
UNION ALL SELECT 
    'orders', COUNT(*)
FROM
    orders 
UNION ALL SELECT 
    'order_items', COUNT(*)
FROM
    order_items;
    
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.2 Are there duplicate records that could inflate metrics?
SELECT 
    customer_id, COUNT(*) AS cnt
FROM
    customers                                                      
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT 
    order_id, COUNT(*) AS cnt
FROM
    orders                                                           
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT 
    order_item_id, COUNT(*) AS cnt
FROM
    order_items                                               
GROUP BY order_item_id
HAVING COUNT(*) > 1;

SELECT 
    product_id, COUNT(*) AS cnt
FROM
    products                                                     
GROUP BY product_id
HAVING COUNT(*) > 1;

-- No, there are no duplicate records that could inflate metrics.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.3 Are there missing values in fields critical for revenue analysis?
SELECT 
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(signup_date IS NULL) AS missing_signup_date
FROM
    customers;

SELECT 
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(order_status IS NULL) AS missing_order_status
FROM
    orders;

SELECT 
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(price IS NULL) AS missing_price
FROM
    order_items;

-- No, there are no missing values in fields critical for revenue analysis.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.4 Do order statuses reflect a realistic sales lifecycle?
SELECT 
    order_status, COUNT(*) AS total_orders
FROM
    orders
GROUP BY order_status;

-- Yes, all good for analysis.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.5 Are there orders or items that don’t map to valid parents?
SELECT 
    o.order_id
FROM
    orders o
        LEFT JOIN                                                                  #Orders without customers
    customers c ON o.customer_id = c.customer_id
WHERE
    c.customer_id IS NULL;

SELECT 
    oi.order_item_id
FROM
    order_items oi
        LEFT JOIN                                                                   #Order items without orders
    orders o ON oi.order_id = o.order_id
WHERE
    o.order_id IS NULL;

SELECT 
    oi.order_item_id
FROM
    order_items oi
        LEFT JOIN                                                                    #Order items without products
    products p ON oi.product_id = p.product_id
WHERE
    p.product_id IS NULL;

-- No there are no orders or items that don’t map to valid parents.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.6 Are there any transactions that violate basic sales logic?
SELECT 
    *
FROM
    order_items
WHERE
    quantity <= 0 OR price <= 0;

-- No, all transactions are align to basic sales logic.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.7 What period does this dataset cover?
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM
    orders;

-- Dataset is up to date, covers ~5 years.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ==================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==================================================================================================================================================================