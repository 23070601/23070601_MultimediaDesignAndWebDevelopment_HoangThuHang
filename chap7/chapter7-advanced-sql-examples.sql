-- =============================================================================
-- Chapter 07: Advanced SQL — Runnable Examples & Exercises
-- Course: INS3064 - Multimedia Design and Web Development
-- Reference: Chapter 7 - PHP & MySQL Web Development
-- Database: shop_db
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. DATABASE SETUP & INITIAL TEST DATA
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS shop_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE shop_db;

-- 1. Users table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'customer') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Product categories table
CREATE TABLE IF NOT EXISTS categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES categories(id)
);

-- 3. Products table
CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- 4. Customer orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 5. Order line items table
CREATE TABLE IF NOT EXISTS order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert sample records
INSERT IGNORE INTO users (id, email, password) VALUES
(1, 'anna@example.com', 'hash1'),
(2, 'ben@example.com', 'hash2');

INSERT IGNORE INTO categories (id, name, slug) VALUES
(1, 'Laptops', 'laptops'),
(2, 'Phones', 'phones'),
(3, 'Empty category', 'empty'); -- Empty category with zero products

INSERT IGNORE INTO products (id, name, slug, price, stock, category_id) VALUES
(1, 'Notebook 14', 'notebook-14', 750.00, 5, 1),
(2, 'Notebook 16', 'notebook-16', 1250.00, 2, 1),
(3, 'Phone A', 'phone-a', 320.00, 10, 2),
(4, 'Unsorted gadget', 'unsorted-gadget', 90.00, 7, NULL); -- Product without a category

INSERT IGNORE INTO orders (id, user_id, total, status) VALUES
(1, 1, 1070.00, 'delivered'),
(2, 2, 320.00, 'pending');

INSERT IGNORE INTO order_items (id, order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1, 750.00),
(2, 1, 3, 1, 320.00),
(3, 2, 3, 1, 320.00);


-- =============================================================================
-- SECTION 1: JOIN QUERIES (COMBINING TABLES)
-- =============================================================================

-- 1.1 INNER JOIN: Returns only rows that match in BOTH tables
-- (Product 4 with NULL category and Category 3 with no products are excluded)
SELECT 
    p.id, 
    p.name AS product_name, 
    p.price, 
    c.name AS category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.id;

-- 1.2 LEFT JOIN: Returns all products, including those without a category (shows NULL)
SELECT 
    p.name AS product_name, 
    c.name AS category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;

-- 1.3 RIGHT JOIN: Returns all categories, including empty categories without products
SELECT 
    c.name AS category_name, 
    p.name AS product_name
FROM products p
RIGHT JOIN categories c ON p.category_id = c.id;

-- 1.4 Multiple JOINs: Chain of 4 tables (orders -> users, order_items -> products)
SELECT 
    o.id AS order_id, 
    u.email AS customer_email, 
    p.name AS product_name, 
    oi.quantity, 
    oi.price
FROM orders o
INNER JOIN users u ON o.user_id = u.id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
WHERE o.status = 'delivered';


-- =============================================================================
-- SECTION 2: SUBQUERIES (NESTED QUERIES)
-- =============================================================================

-- 2.1.A Scalar subquery in WHERE: Products with price above catalog average
SELECT * 
FROM products 
WHERE price > (SELECT AVG(price) FROM products);

-- 2.1.B Multi-value subquery with IN: Customers who placed at least one order
SELECT * 
FROM users 
WHERE id IN (SELECT DISTINCT user_id FROM orders);

-- 2.2 Subquery in FROM: Derived table calculating revenue per category
SELECT 
    category_name, 
    total_revenue
FROM (
    SELECT 
        c.name AS category_name, 
        SUM(oi.price * oi.quantity) AS total_revenue
    FROM categories c
    JOIN products p ON c.id = p.category_id
    JOIN order_items oi ON p.id = oi.product_id
    GROUP BY c.id
) AS category_revenue
ORDER BY total_revenue DESC
LIMIT 5;


-- =============================================================================
-- SECTION 3: GROUP BY & HAVING
-- =============================================================================

-- 3.1 GROUP BY: Count products, average unit price, and total stock per category
SELECT 
    category_id, 
    COUNT(*) AS product_count, 
    AVG(price) AS avg_price, 
    SUM(stock) AS total_stock
FROM products
GROUP BY category_id;

-- 3.2 HAVING: Post-aggregation filter (categories containing 2 or more products)
SELECT 
    c.name AS category_name, 
    COUNT(p.id) AS product_count
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id
HAVING product_count >= 2;


-- =============================================================================
-- SECTION 4: VIEWS (VIRTUAL TABLES)
-- =============================================================================

-- Create or update a reusable View
CREATE OR REPLACE VIEW product_summary AS
SELECT 
    p.id, 
    p.name AS product_name, 
    p.price, 
    c.name AS category_name, 
    p.stock
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;

-- Query the View as if it were a physical table
SELECT * 
FROM product_summary 
WHERE price > 100;

-- Drop the View when no longer needed
-- DROP VIEW IF EXISTS product_summary;


-- =============================================================================
-- SECTION 5: INDEXES (QUERY OPTIMIZATION)
-- =============================================================================

-- Create single-column indexes
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_category ON products(category_id);

-- Create a composite (multi-column) index
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- View indexes on products table
SHOW INDEX FROM products;

-- Drop an index
-- DROP INDEX idx_products_name ON products;


-- =============================================================================
-- SECTION 6: REAL-WORLD BUSINESS REPORTS
-- =============================================================================

-- Report 1: Monthly revenue & unique customer acquisition
SELECT 
    DATE_FORMAT(o.created_at, '%Y-%m') AS month, 
    COUNT(DISTINCT o.id) AS total_orders, 
    COUNT(DISTINCT o.user_id) AS total_customers, 
    SUM(oi.quantity) AS items_sold, 
    SUM(oi.price * oi.quantity) AS revenue
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
WHERE o.status = 'delivered'
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m')
ORDER BY month DESC;

-- Report 2: Top 10 best-selling products by revenue
SELECT 
    p.name AS product_name, 
    SUM(oi.quantity) AS total_sold, 
    SUM(oi.price * oi.quantity) AS revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
GROUP BY p.id
ORDER BY total_sold DESC
LIMIT 10;


-- =============================================================================
-- SECTION 7: PRACTICE EXERCISES SOLUTIONS
-- =============================================================================

-- Exercise 1.1: List of orders with customer information
SELECT 
    o.id AS order_id, 
    o.total, 
    o.status, 
    o.created_at, 
    u.id AS customer_id, 
    u.email AS customer_email
FROM orders o
INNER JOIN users u ON o.user_id = u.id;

-- Exercise 1.2: Products with category name (including unassigned items)
SELECT 
    p.id AS product_id, 
    p.name AS product_name, 
    p.price, 
    p.stock, 
    c.name AS category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;

-- Exercise 1.3: Categories that currently have NO products assigned (Anti-Join)
SELECT 
    c.id AS category_id, 
    c.name AS category_name
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
WHERE p.id IS NULL;

-- Exercise 2.1: Total revenue by category
SELECT 
    c.id AS category_id, 
    c.name AS category_name, 
    COALESCE(SUM(oi.price * oi.quantity), 0.00) AS total_revenue
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY c.id, c.name
ORDER BY total_revenue DESC;

-- Exercise 2.2: Top 5 customers by total spending
SELECT 
    u.id AS customer_id, 
    u.email AS customer_email, 
    COALESCE(SUM(o.total), 0.00) AS total_spent, 
    COUNT(o.id) AS orders_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.email
ORDER BY total_spent DESC
LIMIT 5;

-- Exercise 2.3: Products that have NEVER been sold
SELECT 
    p.id AS product_id, 
    p.name AS product_name, 
    p.price, 
    p.stock
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.id IS NULL;
