-- 1. TOTAL NUMBER OF PRODUCTS
SELECT COUNT(*) AS total_products
FROM products;

-- 2. TOTAL INVENTORY VALUE (price * stock)
SELECT SUM(price * stock) AS total_inventory_value
FROM products;

-- 3. PRODUCTS THAT ARE ALMOST OUT OF STOCK (stock < 10)
SELECT id, name, category, price, stock
FROM products
WHERE stock < 10
ORDER BY stock ASC;

-- 4. RANK PRODUCTS BY PRICE (using window function DENSE_RANK)
SELECT 
    id,
    name,
    category,
    price,
    DENSE_RANK() OVER (ORDER BY price DESC) AS price_rank
FROM products;

-- BONUS: COMBINED SUMMARY METRICS REPORT
SELECT 
    COUNT(*) AS total_products,
    SUM(stock) AS total_stock_units,
    SUM(price * stock) AS total_inventory_value,
    ROUND(AVG(price), 2) AS average_price
FROM products;