-- 1. GET THE 5 MOST EXPENSIVE PRODUCTS
SELECT * 
FROM products
ORDER BY price DESC
LIMIT 5;

-- 2. SEARCH PRODUCTS BY NAME (e.g., matching any product name containing 'Monitor')
SELECT * 
FROM products
WHERE name LIKE '%Monitor%';

-- 3. COUNT PRODUCTS BY CATEGORY
SELECT category, COUNT(*) AS total_products
FROM products
GROUP BY category
ORDER BY total_products DESC;

-- 4. IMPLEMENT PAGINATION WITH 10 PRODUCTS PER PAGE
-- Page 1 (records 1 to 10)
SELECT * 
FROM products
ORDER BY id ASC
LIMIT 10 OFFSET 0;

-- Page 2 (records 11 to 20)
SELECT * 
FROM products
ORDER BY id ASC
LIMIT 10 OFFSET 10;