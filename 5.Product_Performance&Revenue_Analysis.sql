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