-- ==================================================================================================================================================================
--                                      -: Step 5. Order Funnel, Cancellations & Fulfillment Analysis :-
-- ==================================================================================================================================================================
-- 5.1 How do orders move through the funnel?
SELECT 
    order_status, COUNT(*) AS total_orders
FROM
    orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- A total of 482 orders are Completed, 229 orders are Processing and 136 orders are Cancelled.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.2 What percentage of orders reach completion?
SELECT 
    COUNT(CASE
        WHEN order_status = 'Completed' THEN 1
    END) AS completed_orders,
    COUNT(*) AS total_orders,
    ROUND(COUNT(CASE
                WHEN order_status = 'Completed' THEN 1
            END) * 100.0 / COUNT(*),
            2) AS completion_rate_percentage
FROM
    orders;

-- 482 of 1000 orders are cancelled, making around 48% completion rate.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.3 How many orders are getting cancelled?
SELECT 
    COUNT(CASE
        WHEN order_status = 'Cancelled' THEN 1
    END) AS cancelled_orders,
    COUNT(*) AS total_orders,
    ROUND(COUNT(CASE
                WHEN order_status = 'Cancelled' THEN 1
            END) * 100.0 / COUNT(*),
            2) AS cancellation_rate_percentage
FROM
    orders;

-- 136 of 1000 orders are cancelled, making ~ 14% cancellation rate.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.4 Are cancellations increasing over time?
SELECT 
    YEAR(order_date) AS order_year,
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN order_status = 'Cancelled' THEN 1
        ELSE 0
    END) AS cancelled_orders,
    ROUND(SUM(CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),
            2) AS cancellation_rate_percentage
FROM
    orders
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Yes, cancellations are continuously increasing over the years.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.5 How fast are orders being fulfilled?
SELECT 
    order_status, COUNT(*) AS total_orders
FROM
    orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- High Completed = Healthy Fulfillment; Which is exactly the same in this case.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.6 Do delays increase cancellations?
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_share
FROM orders
WHERE order_status IN ('Pending', 'Processing', 'Cancelled')
GROUP BY order_status;

-- High Cancelled vs Processing = Customers drop before fulfillment; Which is not in this case.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 5.7 How much revenue is lost from cancelled orders?
SELECT 
    ROUND(SUM(oi.quantity * oi.price), 2) AS revenue_lost
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status = 'Cancelled';

-- A total of ~ 97,000 revenue lost due to cancellation.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ==================================================================================================================================================================
-- Create order_amount Column becuse of calculating revenue repeatedly using joins is error-prone and slow in a complex analysis.
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

-- SANITY CHECK :-
SELECT 
    COUNT(*) AS total_orders,
    COUNT(order_amount) AS orders_with_amount,
    ROUND(SUM(order_amount), 2) AS total_revenue
FROM
    orders;

-- HANDLING NULL VALUES :-
UPDATE orders 
SET 
    order_amount = 0
WHERE
    order_amount IS NULL;

-- FINAL SANITY CHECK :-
SELECT
    COUNT(*) AS total_orders,
    COUNT(order_amount) AS orders_with_amount,
    SUM(order_amount) AS total_revenue,
    COUNT(CASE WHEN order_amount = 0 THEN 1 END) AS zero_revenue_orders
FROM orders;

-- Now we can perform Advance Analysis.
-- ==================================================================================================================================================================


-- ==================================================================================================================================================================
--                                      -: Step 6. Advanced Analysis :-
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