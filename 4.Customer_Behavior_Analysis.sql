-- ==================================================================================================================================================================
--                                             -: Step 3. Customer Behavior Analysis :-
-- ==================================================================================================================================================================
-- 3.1 How many registered customers actually made a purchase?
SELECT 
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT o.customer_id) AS customers_with_orders
FROM
    customers c
        LEFT JOIN
    orders o ON c.customer_id = o.customer_id;

-- 641 out of 1000 registered customers actually made a purchase. 
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.2 How many customers are repeat buyers vs one-time buyers?
SELECT 
    CASE
        WHEN order_count = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM
    (SELECT 
        customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM
        orders
    WHERE
        order_status IN ('Completed' , 'Shipped')
    GROUP BY customer_id) t
GROUP BY customer_type;

-- 316 customers are 'One-Time Buyer' and 108 customers are 'Repeat Buyer'.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.3 Who contributes more revenue?
SELECT 
    CASE
        WHEN o_count = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyer'
    END AS customer_type,
    SUM(revenue) AS total_revenue
FROM
    (SELECT 
        o.customer_id,
            COUNT(DISTINCT o.order_id) AS o_count,
            SUM(oi.quantity * oi.price) AS revenue
    FROM
        orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE
        o.order_status IN ('Completed' , 'Shipped')
    GROUP BY o.customer_id) t
GROUP BY customer_type;

-- 'One-Time Buyer' customer segment contributes more in total revenue.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.4 How loyal are customers?
SELECT 
    AVG(order_count) AS avg_orders_per_customer
FROM
    (SELECT 
        customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM
        orders
    WHERE
        order_status IN ('Completed' , 'Shipped')
    GROUP BY customer_id) t;

-- Almost all customers are 'One-Time Buyer', on average 1.32 orders per customer.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.5 How valuable is an average customer?
SELECT 
    AVG(customer_revenue) AS avg_revenue_per_customer
FROM
    (SELECT 
        o.customer_id,
            SUM(oi.quantity * oi.price) AS customer_revenue
    FROM
        orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE
        o.order_status IN ('Completed' , 'Shipped')
    GROUP BY o.customer_id) t;

-- They are valuable, contribute ~ 1,400 per customer on an average.  
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 3.6 How many customers place 1, 2, 3+ orders?
SELECT 
    order_count, COUNT(*) AS customer_count
FROM
    (SELECT 
        customer_id, COUNT(DISTINCT order_id) AS order_count
    FROM
        orders
    WHERE
        order_status IN ('Completed' , 'Shipped')
    GROUP BY customer_id) t
GROUP BY order_count
ORDER BY order_count;

-- A total of 316 customers are 'One-Time buyer', 83 are buyers 2 times , 21 are 3 times buyer
-- and only 4 out of total customer buyers 4 times.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ==================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==================================================================================================================================================================