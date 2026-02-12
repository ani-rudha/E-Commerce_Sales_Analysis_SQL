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
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==================================================================================================================================================================