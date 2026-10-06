-- 1. CREATE AND INITIALIZE DATABASE
DROP DATABASE IF EXISTS store_db;
CREATE DATABASE store_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE store_db;

-- 2. CREATE PRODUCTS TABLE
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category VARCHAR(50) NOT NULL,
    CONSTRAINT chk_products_price CHECK (price >= 0),
    CONSTRAINT chk_products_stock CHECK (stock >= 0)
) ENGINE=InnoDB;

-- 3. INSERT 10 PRODUCTS
INSERT INTO products (name, price, stock, category) VALUES
('Logitech MX Master 3S Wireless Mouse', 99.99, 25, 'Electronics'),
('Dell UltraSharp 27-inch 4K Monitor', 349.99, 10, 'Electronics'),
('Keychron K2 Mechanical Keyboard', 79.50, 15, 'Accessories'),
('Sony WH-1000XM5 Noise Canceling Headphones', 399.99, 8, 'Audio'),
('Anker USB-C to HDMI Cable', 15.99, 50, 'Accessories'),
('Apple iPad Air 11-inch M2', 599.00, 0, 'Tablets'),
('Anker 65W GaN Fast Charger', 35.50, 40, 'Accessories'),
('Samsung Galaxy Tab S9', 799.99, 5, 'Tablets'),
('Aluminum Ergonomic Laptop Stand', 45.00, 0, 'Office Supplies'),
('LG 34-inch Curved UltraWide Monitor', 499.99, 12, 'Electronics');

-- 4. SELECT PRODUCTS WITH PRICE > 100
SELECT * FROM products 
WHERE price > 100;

-- 5. UPDATE PRODUCT PRICE
UPDATE products 
SET price = 109.99 
WHERE id = 1;

-- 6. DELETE OUT-OF-STOCK PRODUCTS
DELETE FROM products 
WHERE stock = 0;

-- 7. VERIFY FINAL TABLE STATE
SELECT * FROM products;