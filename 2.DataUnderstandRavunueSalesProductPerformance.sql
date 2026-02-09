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
-- Are there spikes or drops in daily sales?
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
--                                            -: Step 4. Product Performance & Revenue Analysis :-
-- ==================================================================================================================================================================
-- 4.1 Which products generate the highest revenue?
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.price) AS total_revenue
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    products p ON oi.product_id = p.product_id
WHERE
    o.order_status IN ('Completed' , 'Shipped')
GROUP BY p.product_id , p.product_name
ORDER BY total_revenue DESC;

-- Products like Headphones, Childrens Books, Loafers, Lipsticks, Mascara make most of the revenue.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.2 Which categories drive the most revenue?
SELECT 
    p.category, SUM(oi.quantity * oi.price) AS category_revenue
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    products p ON oi.product_id = p.product_id
WHERE
    o.order_status IN ('Completed' , 'Shipped')
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Categories like Electronics, Apparels, Footware, Books are made most of the revenue.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.3 Which products sell the most units?
SELECT 
    p.product_name, SUM(oi.quantity) AS total_units_sold
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    products p ON oi.product_id = p.product_id
WHERE
    o.order_status IN ('Completed' , 'Shipped')
GROUP BY p.product_name
ORDER BY total_units_sold DESC;

-- Headphones are the leading total units sold, followed by Hoodie, Smartphone, Tablets, Coats; Top 5 products.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.4 Which products earn high revenue with fewer sales?
SELECT 
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.price) AS revenue
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    products p ON oi.product_id = p.product_id
WHERE
    o.order_status IN ('Completed' , 'Shipped')
GROUP BY p.product_name
HAVING units_sold < 50
ORDER BY revenue DESC;

-- Gaming Console, Sneakers, T-Shirt, Bluetooth Speaker and Childrens Book are the top 5 products with fewer units sold.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.5 Which categories increase order value?
SELECT 
    p.category,
    ROUND(SUM(oi.quantity * oi.price) / COUNT(DISTINCT o.order_id),
            2) AS avg_order_value
FROM
    order_items oi
        JOIN
    orders o ON oi.order_id = o.order_id
        JOIN
    products p ON oi.product_id = p.product_id
WHERE
    o.order_status IN ('Completed' , 'Shipped')
GROUP BY p.category
ORDER BY avg_order_value DESC;

-- The top 5 categories are Beauty, Groceries, Apparels, Electronics and Books.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 4.6 Which products barely sell? (less than 10 units sold)
SELECT 
    p.product_name, SUM(oi.quantity) AS units_sold
FROM
    products p
        LEFT JOIN
    order_items oi ON p.product_id = oi.product_id
        LEFT JOIN
    orders o ON oi.order_id = o.order_id
        AND o.order_status IN ('Completed' , 'Shipped')
GROUP BY p.product_name
HAVING units_sold IS NULL OR units_sold < 10
ORDER BY units_sold;

-- The top 5 worst performing products are Eyeshadow Palettes, Biographies, Cheeses, Moisturizers and Self-Help Books.
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ==================================================================================================================================================================
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ==================================================================================================================================================================