-- ==================================================================================================================================================================
--                                             -: Step 2. Revenue & Sales Trend Analysis :-
-- ==================================================================================================================================================================
-- 2.1 What is the total realized revenue?
SELECT 
    SUM(oi.quantity * oi.price) AS total_revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN ('Completed' , 'Shipped');

-- Total revenue is ~ 407,000. 
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.2 How many orders actually generated revenue?
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE
            WHEN o.order_status IN ('Completed' , 'Shipped') THEN o.order_id
        END) AS revenue_orders
FROM
    orders o;

-- A total of 561 out of 1000 orders generate revenue. 
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.3 How much does a customer spend per order on average?
SELECT 
    SUM(oi.quantity * oi.price) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN ('Completed' , 'Shipped');

-- A customer spends around 1190 per order on average.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.4 Is revenue growing, declining, or seasonal?
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * oi.price) AS monthly_revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN ('Completed' , 'Shipped')
GROUP BY month
ORDER BY month;

-- The revenue growth is seasonal.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.5 How much revenue is lost due to cancellations or delays?
SELECT 
    o.order_status, SUM(oi.quantity * oi.price) AS revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN ('Cancelled' , 'Processing', 'Pending')
GROUP BY o.order_status;

-- Cancelled orders are costing around ~ 97,000; but majority revenue is stuck in Processing.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2.6 Are there spikes or drops in daily sales?
SELECT 
    o.order_date, SUM(oi.quantity * oi.price) AS daily_revenue
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status IN ('Completed' , 'Shipped')
GROUP BY o.order_date
ORDER BY o.order_date;

-- Yes, but it's completely normal.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ==================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==================================================================================================================================================================