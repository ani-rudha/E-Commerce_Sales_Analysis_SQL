-- ==================================================================================================================================================================

--     Create order_amount Column becuse of calculating revenue repeatedly using joins is error-prone and slow in a complex analysis

-- ==================================================================================================================================================================
-- ADD THE COLUMN - 'order_amount' :-

ALTER TABLE orders
ADD COLUMN order_amount DECIMAL(10,2);

UPDATE orders o
        JOIN
    (SELECT 
        order_id, SUM(quantity * price) AS calculated_amount
    FROM
        order_items
    GROUP BY order_id) t ON o.order_id = t.order_id 
SET 
    o.order_amount = t.calculated_amount;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SANITY CHECK :-

SELECT 
    COUNT(*) AS total_orders,
    COUNT(order_amount) AS orders_with_amount,
    ROUND(SUM(order_amount), 2) AS total_revenue
FROM
    orders;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- HANDLING NULL VALUES :-

UPDATE orders 
SET 
    order_amount = 0
WHERE
    order_amount IS NULL;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FINAL SANITY CHECK :-

SELECT
    COUNT(*) AS total_orders,
    COUNT(order_amount) AS orders_with_amount,
    SUM(order_amount) AS total_revenue,
    COUNT(CASE WHEN order_amount = 0 THEN 1 END) AS zero_revenue_orders
FROM orders;

-- ==================================================================================================================================================================

--                                          Now we can perform Advance Analysis

-- ==================================================================================================================================================================

-- ==================================================================================================================================================================
--                                      -: Step 6. Advanced Sales Analysis :-
-- ==================================================================================================================================================================
-- 6.1 Are a small group of customers driving a large portion of revenue?
SELECT 
    c.customer_id,
    COUNT(o.order_id) AS total_orders,
    SUM(o.order_amount) AS total_revenue
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
WHERE
    o.order_status = 'Completed'
GROUP BY c.customer_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Ideal candidates for retention & upsell.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.2 Are our best-selling products also our highest-revenue products?
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.price) AS product_revenue
FROM
    order_items oi
        JOIN
    products p ON oi.product_id = p.product_id
        JOIN
    orders o ON oi.order_id = o.order_id
WHERE
    o.order_status = 'Completed'
GROUP BY p.product_id , p.product_name
ORDER BY product_revenue DESC;

-- Yes, our top 5 products are also the highest revenued products.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.3 What is the financial impact of order cancellations?
SELECT 
    COUNT(*) AS cancelled_orders,
    SUM(order_amount) AS revenue_lost
FROM
    orders
WHERE
    order_status = 'Cancelled';

-- A total of 136 cancelled orders cost ~ 97,000 of revenue.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 6.4 Are orders stuck in non-completed states affecting cash flow?
SELECT 
    order_status,
    COUNT(*) AS order_count,
    SUM(order_amount) AS revenue_value
FROM
    orders
WHERE
    order_status IN ('Pending' , 'Processing')
GROUP BY order_status
ORDER BY revenue_value DESC;

-- Yes a large portion of revenue is stuck in in-completed orders, due to Pending and Processing.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
 

-- ==================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==================================================================================================================================================================