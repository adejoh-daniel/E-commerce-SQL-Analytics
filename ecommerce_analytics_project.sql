-- =======================================================
-- 1. DATABASE & SCHEMA CREATION
-- =======================================================
CREATE DATABASE IF NOT EXISTS ecommerce_analytics;
USE ecommerce_analytics;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    signup_date DATE,
    country VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- =======================================================
-- 2. INSERTING MOCK DATA
-- =======================================================
INSERT INTO products (product_name, category, price, stock_quantity) VALUES
('Wireless Noise-Canceling Headphones', 'Electronics', 150.00, 45),
('Ergonomic Mechanical Keyboard', 'Electronics', 85.50, 60),
('4K Ultra HD Monitor 27"', 'Electronics', 320.00, 20),
('Premium Leather Daily Planner', 'Office Supplies', 25.00, 150),
('Stainless Steel Water Bottle 1L', 'Home & Kitchen', 30.00, 200),
('Smart Fitness Watch v2', 'Electronics', 199.99, 12),
('Ergonomic Office Desk Chair', 'Home & Kitchen', 245.00, 15),
('Eco-Friendly Yoga Mat', 'Home & Kitchen', 40.00, 85);

INSERT INTO customers (first_name, last_name, email, signup_date, country) VALUES
('Abubakar', 'Anil', 'abubakar.anil@email.com', '2025-01-15', 'Nigeria'),
('Chidi', 'Okonkwo', 'chidi.o@email.com', '2025-03-22', 'Nigeria'),
('Sarah', 'Smith', 'sarah.s@email.com', '2025-06-02', 'United States'),
('Zainab', 'Bello', 'z.bello@email.com', '2025-09-18', 'Nigeria'),
('David', 'Jones', 'david.j@email.com', '2025-11-05', 'United Kingdom'),
('Amara', 'Eze', 'amara.eze@email.com', '2026-02-10', 'Nigeria'),
('John', 'Doe', 'j.doe@email.com', '2026-04-29', 'United States');

INSERT INTO orders (order_id, customer_id, order_date, order_status) VALUES
(1001, 1, '2025-01-20', 'Shipped'),
(1002, 2, '2025-03-25', 'Shipped'),
(1003, 3, '2025-06-15', 'Shipped'),
(1004, 2, '2025-06-20', 'Shipped'),
(1005, 4, '2025-09-20', 'Shipped'),
(1006, 1, '2025-11-10', 'Shipped'),
(1007, 5, '2025-12-05', 'Cancelled'), 
(1008, 5, '2025-12-06', 'Shipped'),
(1009, 6, '2026-02-15', 'Shipped'), 
(1010, 1, '2026-03-01', 'Shipped'), 
(1011, 4, '2026-04-12', 'Shipped'),
(1012, 7, '2026-05-02', 'Shipped'),
(1013, 6, '2026-06-18', 'Shipped'), 
(1014, 1, '2026-06-25', 'Pending');  

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1001, 1, 1, 150.00), 
(1002, 3, 1, 320.00), 
(1003, 4, 2, 25.00),  
(1004, 2, 1, 85.50),  
(1005, 5, 3, 30.00),  
(1006, 6, 1, 199.99), 
(1007, 7, 1, 245.00), 
(1008, 8, 2, 40.00),  
(1009, 3, 2, 320.00), 
(1010, 2, 1, 85.50),  
(1011, 4, 1, 25.00),  
(1012, 5, 1, 30.00),  
(1013, 1, 1, 150.00), 
(1014, 6, 1, 199.99); 


-- =======================================================
-- 3. PORTFOLIO QUERY 1: MONTH-OVER-MONTH REVENUE GROWTH
-- =======================================================
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        SUM(oi.quantity * oi.unit_price) AS current_month_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Shipped'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT 
    order_month,
    current_month_revenue,
    LAG(current_month_revenue, 1) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue, 1) OVER (ORDER BY order_month)) / 
        LAG(current_month_revenue, 1) OVER (ORDER BY order_month)) * 100, 
        2
    ) AS mom_growth_percentage
FROM MonthlyRevenue
ORDER BY order_month;


-- =======================================================
-- 4. PORTFOLIO QUERY 2: RFM CUSTOMER SEGMENTATION
-- =======================================================
WITH CustomerRFM_Metrics AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF('2026-06-29', MAX(o.order_date)) AS recency_days,
        COUNT(DISTINCT o.order_id) AS frequency_count,
        SUM(oi.quantity * oi.unit_price) AS total_monetary_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_name,
    recency_days,
    frequency_count,
    total_monetary_value,
    CASE 
        WHEN recency_days <= 30 AND frequency_count >= 3 THEN 'VIP / Champion'
        WHEN recency_days <= 60 THEN 'Active / Recent Buyer'
        WHEN recency_days > 365 THEN 'Churned / Dead Account'
        ELSE 'At-Risk / Needs Re-engagement'
    END AS customer_segment
FROM CustomerRFM_Metrics
ORDER BY total_monetary_value DESC;