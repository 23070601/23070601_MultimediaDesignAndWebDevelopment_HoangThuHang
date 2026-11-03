# Chapter 7: Advanced SQL — Complete Guide & Visual Examples

> **Course:** INS3064 - Multimedia Design and Web Development  
> **Reference:** Chapter 7 - PHP & MySQL Web Development (Joins, Subqueries, Aggregations, Views, Indexes)  
> **Environment:** phpMyAdmin & MySQL Relational Database  
> *(Comprehensive study guide designed for international students with visual ASCII diagrams, row-matching traces, execution pipelines, and exact phpMyAdmin result sets)*

---

## 📑 Table of Contents

1. [Database Schema (`shop_db`) & Sample Dataset](#1-database-schema-shop_db--sample-dataset)
2. [Section 1: JOIN — Combining Tables](#section-1-join--combining-tables)
   - 1.1 INNER JOIN (Intersection of both tables)
   - 1.2 LEFT JOIN (Preserve all rows from the Left table)
   - 1.3 RIGHT JOIN (Preserve all rows from the Right table)
   - 1.4 Multiple JOINs (Chaining 4 interconnected tables)
3. [Section 2: Subqueries (Nested Queries)](#section-2-subqueries-nested-queries)
   - 2.1 Subquery in `WHERE` clause (Scalar & Multi-row `IN`)
   - 2.2 Subquery in `FROM` clause (Derived Tables / Inline Views)
4. [Section 3: GROUP BY & HAVING (Data Aggregation)](#section-3-group-by--having-data-aggregation)
   - 3.1 Aggregate Functions (`COUNT`, `SUM`, `AVG`, `MAX`, `MIN`) & `GROUP BY`
   - 3.2 `WHERE` (Pre-filter) vs `HAVING` (Post-filter) Execution Pipeline
5. [Section 4: Views (Virtual Tables)](#section-4-views-virtual-tables)
6. [Section 5: Indexes (Query Performance Optimization)](#section-5-indexes-query-performance-optimization)
   - 5.1 B-Tree Index vs Full Table Scan
   - 5.2 Single-column Index & Composite Index (The Leftmost Prefix Rule)
7. [Section 6: Real-World Business Reports](#section-6-real-world-business-reports)
8. [Section 7: Practice Exercises & Step-by-Step Solutions](#section-7-practice-exercises--step-by-step-solutions)
9. [Section 8: phpMyAdmin Graphical Interface Guide](#section-8-phpmyadmin-graphical-interface-guide)
10. [Quick Reference Cheat Sheet](#quick-reference-cheat-sheet)

---

## 1. Database Schema (`shop_db`) & Sample Dataset

To clearly demonstrate the behavior of different SQL `JOIN` types and advanced query constructs, the `shop_db` dataset includes intentional edge cases:
* **Product `#4 (Unsorted gadget)`**: Has no category assigned (`category_id = NULL`).
* **Category `#3 (Empty category)`**: Has zero products referencing it.
* **Product `#2 (Notebook 16)` & `#4`**: Have never been ordered (no entries in `order_items`).

### 1.1 Entity Relationship Diagram (ASCII ERD)

```text
+------------------+         1:N         +-------------------+
|    categories    |<--------------------+     products      |
+------------------+                     +-------------------+
| PK id            |                     | PK id             |
|    name          |                     |    name           |
|    slug          |                     |    price          |
| FK parent_id     |                     |    stock          |
+------------------+                     | FK category_id    |
                                         +-------------------+
                                                   ^
                                                   | 1:N
                                                   |
+------------------+         1:N         +-------------------+
|      users       |                     |    order_items    |
+------------------+                     +-------------------+
| PK id            |                     | PK id             |
|    email         |                     | FK order_id       |
|    role          |                     | FK product_id     |
+------------------+                     |    quantity       |
         |                               |    price          |
         | 1:N                           +-------------------+
         v                                         |
+------------------+                               | N:1
|      orders      |<------------------------------+
+------------------+
| PK id            |
| FK user_id       |
|    total         |
|    status        |
|    created_at    |
+------------------+
```

### 1.2 Initial Raw Data State

```text
Table: users
+----+------------------+----------+----------+
| id | email            | password | role     |
+----+------------------+----------+----------+
|  1 | anna@example.com | hash1    | customer |
|  2 | ben@example.com  | hash2    | customer |
+----+------------------+----------+----------+

Table: categories
+----+----------------+----------------+-----------+
| id | name           | slug           | parent_id |
+----+----------------+----------------+-----------+
|  1 | Laptops        | laptops        |      NULL |
|  2 | Phones         | phones         |      NULL |
|  3 | Empty category | empty          |      NULL | <-- No products in this category!
+----+----------------+----------------+-----------+

Table: products
+----+-----------------+-----------------+---------+-------+-------------+
| id | name            | slug            | price   | stock | category_id |
+----+-----------------+-----------------+---------+-------+-------------+
|  1 | Notebook 14     | notebook-14     |  750.00 |     5 |           1 | --> "Laptops"
|  2 | Notebook 16     | notebook-16     | 1250.00 |     2 |           1 | --> "Laptops"
|  3 | Phone A         | phone-a         |  320.00 |    10 |           2 | --> "Phones"
|  4 | Unsorted gadget | unsorted-gadget |   90.00 |     7 |        NULL | <-- NO category assigned!
+----+-----------------+-----------------+---------+-------+-------------+

Table: orders
+----+---------+---------+-----------+---------------------+
| id | user_id | total   | status    | created_at          |
+----+---------+---------+-----------+---------------------+
|  1 |       1 | 1070.00 | delivered | 2026-10-15 10:00:00 | (Placed by Anna)
|  2 |       2 |  320.00 | pending   | 2026-10-18 14:30:00 | (Placed by Ben)
+----+---------+---------+-----------+---------------------+

Table: order_items
+----+----------+------------+----------+--------+
| id | order_id | product_id | quantity | price  |
+----+----------+------------+----------+--------+
|  1 |        1 |          1 |        1 | 750.00 | --> Order 1: 1 unit of Notebook 14
|  2 |        1 |          3 |        1 | 320.00 | --> Order 1: 1 unit of Phone A
|  3 |        2 |          3 |        1 | 320.00 | --> Order 2: 1 unit of Phone A
+----+----------+------------+----------+--------+
```

---

## Section 1: JOIN — Combining Tables

A `JOIN` clause combines rows from two or more tables based on a related column between them (typically `Foreign Key = Primary Key`).

```text
Venn Diagram Overview of JOIN Types:

      INNER JOIN                    LEFT JOIN                    RIGHT JOIN
   +------+  +------+           +######+  +------+           +------+  +######+
  /        \/        \         /####### \/        \         /        \/ #######\
 |    A    |  A∩B  |  B  |   |   A ###| A∩B |  B  |   |    A   | A∩B |### B   |
  \        /\        /         \####### /\        /         \        /\ #######/
   +------+  +------+           +######+  +------+           +------+  +######+
   Matching rows only         All rows from Table A       All rows from Table B
  (Intersection A ∩ B)        (Unmatched B -> NULL)       (Unmatched A -> NULL)
```

---

### 1.1 INNER JOIN

**Rule:** Returns only rows where there is an exact match in **BOTH** tables. If a row in table A does not match any row in table B on the join condition, it is excluded from the final result.

#### SQL Query:
```sql
SELECT 
    p.id, 
    p.name AS product_name, 
    p.price, 
    c.name AS category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.id;
```

#### Row Matching Execution Trace (ASCII):
```text
Table: products (p)                           Table: categories (c)
+----+-----------------+-------------+        +----+----------------+
| id | name            | category_id |        | id | name           |
+----+-----------------+-------------+        +----+----------------+
|  1 | Notebook 14     |           1 | =====> |  1 | Laptops        | MATCH!   (Kept)
|  2 | Notebook 16     |           1 | =====> |  1 | Laptops        | MATCH!   (Kept)
|  3 | Phone A         |           2 | =====> |  2 | Phones         | MATCH!   (Kept)
|  4 | Unsorted gadget |        NULL | =====> ❌ No matching ID  | NO MATCH (Dropped)
+----+-----------------+-------------+        |  3 | Empty category | ❌ No product points here (Dropped)
                                              +----+----------------+
```

#### Result in phpMyAdmin:
```text
Showing rows 0 - 2 (3 total, Query took 0.0008 seconds)
+----+--------------+---------+---------------+
| id | product_name | price   | category_name |
+----+--------------+---------+---------------+
|  1 | Notebook 14  |  750.00 | Laptops       |
|  2 | Notebook 16  | 1250.00 | Laptops       |
|  3 | Phone A      |  320.00 | Phones        |
+----+--------------+---------+---------------+
```
> **Key Observations:**
> - `Unsorted gadget` is **excluded** because its `category_id` is `NULL`.
> - `Empty category` is **excluded** because no products link to category ID `3`.

---

### 1.2 LEFT JOIN (LEFT OUTER JOIN)

**Rule:** Returns **ALL** rows from the left table (`products`), along with matching rows from the right table (`categories`). If no match exists on the right, MySQL outputs `NULL` for the right table's columns.

#### SQL Query:
```sql
SELECT 
    p.name AS product_name, 
    c.name AS category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;
```

#### Row Matching Execution Trace (ASCII):
```text
Table: products (LEFT TABLE - 100% Retained)    Table: categories (RIGHT TABLE)
+-----------------+-------------+               +----+----------------+
| name            | category_id |               | id | name           |
+-----------------+-------------+               +----+----------------+
| Notebook 14     |           1 | ------------> |  1 | Laptops        | -> Laptops
| Notebook 16     |           1 | ------------> |  1 | Laptops        | -> Laptops
| Phone A         |           2 | ------------> |  2 | Phones         | -> Phones
| Unsorted gadget |        NULL | ------------> ❌ Not found         | -> NULL (Padded with NULL)
+-----------------+-------------+               +----+----------------+
```

#### Result in phpMyAdmin:
```text
Showing rows 0 - 3 (4 total, Query took 0.0006 seconds)
+-----------------+---------------+
| product_name    | category_name |
+-----------------+---------------+
| Notebook 14     | Laptops       |
| Notebook 16     | Laptops       |
| Phone A         | Phones        |
| Unsorted gadget | NULL          |  <-- Preserved even though it has no category!
+-----------------+---------------+
```
> **When to use LEFT JOIN?** Use it whenever you want to display the full inventory catalog on your website, including newly created products that have not yet been assigned to a department or category.

---

### 1.3 RIGHT JOIN (RIGHT OUTER JOIN)

**Rule:** Returns **ALL** rows from the right table (`categories`), along with matching rows from the left table (`products`). If a category has no products assigned, the product columns are filled with `NULL`.

#### SQL Query:
```sql
SELECT 
    c.name AS category_name, 
    p.name AS product_name
FROM products p
RIGHT JOIN categories c ON p.category_id = c.id;
```

#### Row Matching Execution Trace (ASCII):
```text
Table: products (LEFT)                 Table: categories (RIGHT TABLE - 100% Retained)
+-----------------+-------------+      +----+----------------+
| name            | category_id |      | id | name           |
+-----------------+-------------+      +----+----------------+
| Notebook 14     |           1 | <--- |  1 | Laptops        | (2 matching products)
| Notebook 16     |           1 | <--- |    |                |
| Phone A         |           2 | <--- |  2 | Phones         | (1 matching product)
| NULL            |        NULL | <--- |  3 | Empty category | ❌ No products -> Padded with NULL
+-----------------+-------------+      +----+----------------+
```

#### Result in phpMyAdmin:
```text
Showing rows 0 - 3 (4 total, Query took 0.0006 seconds)
+----------------+--------------+
| category_name  | product_name |
+----------------+--------------+
| Laptops        | Notebook 14  |
| Laptops        | Notebook 16  |
| Phones         | Phone A      |
| Empty category | NULL         |  <-- Preserved even though it contains 0 products!
+----------------+--------------+
```
> **Industry Best Practice:** Most backend developers prefer writing `LEFT JOIN` and swapping table positions rather than using `RIGHT JOIN`. It keeps SQL code naturally readable from left to right:
> `FROM categories c LEFT JOIN products p ON c.id = p.category_id` produces identical output.

---

### 1.4 Multiple JOINs (Chaining 4 Interconnected Tables)

In real-world e-commerce systems, an itemized invoice spans multiple tables:
`orders` $\rightarrow$ `users` (who placed the order)  
`orders` $\rightarrow$ `order_items` $\rightarrow$ `products` (item details, quantity, purchase price).

#### SQL Query:
```sql
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
```

#### Data Pipeline Execution Flow (ASCII):
```text
[Step 1: Scan orders o]
Filter: WHERE status = 'delivered'
  |-- Order #1 (user_id = 1, status = 'delivered') -> PASS!
  |-- Order #2 (user_id = 2, status = 'pending')   -> ❌ Filtered out by WHERE clause!
         |
         v
[Step 2: JOIN users u ON o.user_id = u.id]
  |-- Order #1 (user_id = 1) =====> User #1 (anna@example.com)
         |
         v
[Step 3: JOIN order_items oi ON o.id = oi.order_id]
  |-- Order #1 contains 2 line items:
        + Item #1: product_id = 1, quantity = 1, price = 750.00
        + Item #2: product_id = 3, quantity = 1, price = 320.00
         |
         v
[Step 4: JOIN products p ON oi.product_id = p.id]
  |-- Item #1 (product_id = 1) =====> "Notebook 14"
  |-- Item #2 (product_id = 3) =====> "Phone A"
```

#### Result in phpMyAdmin:
```text
Showing rows 0 - 1 (2 total, Query took 0.0011 seconds)
+----------+------------------+--------------+----------+--------+
| order_id | customer_email   | product_name | quantity | price  |
+----------+------------------+--------------+----------+--------+
|        1 | anna@example.com | Notebook 14  |        1 | 750.00 |
|        1 | anna@example.com | Phone A      |        1 | 320.00 |
+----------+------------------+--------------+----------+--------+
```

---

## Section 2: Subqueries (Nested Queries)

A **Subquery** (or inner query) is a `SELECT` statement embedded inside another SQL statement (`SELECT`, `INSERT`, `UPDATE`, or `DELETE`).

```text
Execution Flow:
+-----------------------------------------------------------+
|  Outer Query                                              |
|  SELECT * FROM products WHERE price > [ SUBQUERY RESULT ] |
+--------------------------------------------|--------------+
                                             | Executes First
                                             v
                         +-----------------------------------+
                         | Subquery: (SELECT AVG(price)...)  |
                         | Computes scalar value: 602.50     |
                         +-----------------------------------+
```

---

### 2.1 Subquery in `WHERE` Clause

#### Example A: Single-Value Scalar Subquery — Find products priced above store average
```sql
SELECT * 
FROM products 
WHERE price > (SELECT AVG(price) FROM products);
```

**Step-by-step Execution:**
1. **Step 1 (Inner query executes first):**
   $$\text{AVG(price)} = \frac{750.00 + 1250.00 + 320.00 + 90.00}{4} = \mathbf{602.50}$$
2. **Step 2 (Outer query executes with calculated value):**
   MySQL evaluates: `SELECT * FROM products WHERE price > 602.50;`
   - Notebook 14 ($750.00 > 602.50$) $\rightarrow$ **Kept**
   - Notebook 16 ($1250.00 > 602.50$) $\rightarrow$ **Kept**
   - Phone A ($320.00 \ngtr 602.50$) $\rightarrow$ Discarded
   - Unsorted gadget ($90.00 \ngtr 602.50$) $\rightarrow$ Discarded

**Result in phpMyAdmin:**
```text
+----+-------------+-------------+---------+-------+-------------+
| id | name        | slug        | price   | stock | category_id |
+----+-------------+-------------+---------+-------+-------------+
|  1 | Notebook 14 | notebook-14 |  750.00 |     5 |           1 |
|  2 | Notebook 16 | notebook-16 | 1250.00 |     2 |           1 |
+----+-------------+-------------+---------+-------+-------------+
```

---

#### Example B: Multi-Value Subquery with `IN` — Customers who placed at least one order
```sql
SELECT * 
FROM users 
WHERE id IN (SELECT DISTINCT user_id FROM orders);
```

**Step-by-step Evaluation:**
```text
[Inner Query]: SELECT DISTINCT user_id FROM orders;
              Result set: (1, 2)

[Outer Query]: SELECT * FROM users WHERE id IN (1, 2);
```

**Result in phpMyAdmin:**
```text
+----+------------------+----------+----------+
| id | email            | password | role     |
+----+------------------+----------+----------+
|  1 | anna@example.com | hash1    | customer |
|  2 | ben@example.com  | hash2    | customer |
+----+------------------+----------+----------+
```

---

### 2.2 Subquery in `FROM` Clause (Derived Table / Inline View)

When a subquery is placed in the `FROM` clause, its result set acts as a **temporary intermediate table (Derived Table)**.  
⚠️ **Mandatory Syntax Rule:** Every derived table **must** be given an alias (`AS table_alias`).

#### Problem: Calculate top revenue-generating categories
```sql
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
```

#### Derived Table Lifecycle (ASCII):
```text
STEP 1: The inner query generates the temporary table `category_revenue`:
+----------------+---------------+
| category_name  | total_revenue |
+----------------+---------------+
| Laptops        |        750.00 | (1 Notebook 14 @ 750)
| Phones         |        640.00 | (2 Phone A @ 320: 1 from Order 1, 1 from Order 2)
+----------------+---------------+

STEP 2: The outer query treats it like a real table:
- Sorts via: ORDER BY total_revenue DESC
- Limits to: LIMIT 5
```

**Result in phpMyAdmin:**
```text
+---------------+---------------+
| category_name | total_revenue |
+---------------+---------------+
| Laptops       |        750.00 |
| Phones        |        640.00 |
+---------------+---------------+
```

---

## Section 3: GROUP BY & HAVING (Data Aggregation)

### 3.1 Aggregate Functions & `GROUP BY`

Standard SQL Aggregate Functions:
- `COUNT(*)`: Counts the total number of rows.
- `SUM(column)`: Calculates the mathematical sum of values.
- `AVG(column)`: Computes the arithmetic average.
- `MIN(column)`: Identifies the lowest value.
- `MAX(column)`: Identifies the highest value.

#### SQL Query: Total products, average unit price, and total inventory stock per category
```sql
SELECT 
    category_id, 
    COUNT(*) AS product_count, 
    AVG(price) AS avg_price, 
    SUM(stock) AS total_stock
FROM products
GROUP BY category_id;
```

#### Bucket Sorting Visualization (ASCII):
```text
Raw products table rows:
  [Prod 1, Cat 1, $750,  Stock 5]
  [Prod 2, Cat 1, $1250, Stock 2]
  [Prod 3, Cat 2, $320,  Stock 10]
  [Prod 4, NULL,  $90,   Stock 7]
                  |
                  | Sorted into "Buckets" grouped by category_id
                  v
 +---------------------------+-------------------+-------------------+
 |     Bucket: cat_id = 1    | Bucket: cat_id = 2| Bucket: cat_id=NULL|
 +---------------------------+-------------------+-------------------+
 | - Notebook 14 ($750, stk 5| - Phone A         | - Unsorted gadget |
 | - Notebook 16 ($1250,stk 2|   ($320, stk 10)  |   ($90, stk 7)    |
 +---------------------------+-------------------+-------------------+
                  |                   |                   |
                  | Collapsed into 1 aggregated summary row per bucket:
                  v                   v                   v
           COUNT: 2            COUNT: 1            COUNT: 1
           AVG:   1000.00      AVG:   320.00       AVG:   90.00
           SUM:   7            SUM:   10           SUM:   7
```

**Result in phpMyAdmin:**
```text
+-------------+---------------+-------------+-------------+
| category_id | product_count | avg_price   | total_stock |
+-------------+---------------+-------------+-------------+
|        NULL |             1 |   90.000000 |           7 |
|           1 |             2 | 1000.000000 |           7 |
|           2 |             1 |  320.000000 |          10 |
+-------------+---------------+-------------+-------------+
```

---

### 3.2 `WHERE` vs `HAVING` Comparison

A fundamental concept tested in database engineering:

```text
SQL Execution Lifecycle Pipeline:

  [ 1. FROM & JOIN ]   Loads, correlates, and joins initial tables
          |
          v
  [ 2. WHERE ]         ROW-LEVEL FILTER (Runs BEFORE grouping)
          |            ❌ CANNOT evaluate aggregate functions (e.g., SUM, COUNT)!
          v
  [ 3. GROUP BY ]      Collapses individual rows into distinct groups/buckets
          |
          v
  [ 4. HAVING ]        GROUP-LEVEL FILTER (Runs AFTER grouping)
          |            ✅ DESIGNED specifically for aggregates (COUNT, SUM, AVG)
          v
  [ 5. SELECT ]        Projects selected columns & calculated expressions
          |
          v
  [ 6. ORDER BY / LIMIT ] Sorts rows and paginates result set
```

#### Comparison Matrix:
| Feature | `WHERE` Clause | `HAVING` Clause |
| :--- | :--- | :--- |
| **Execution Point** | Executes **before** `GROUP BY` grouping | Executes **after** `GROUP BY` grouping |
| **Target Scope** | Individual table rows | Grouped / aggregated summaries |
| **Aggregate Functions** | ❌ Forbidden (`WHERE SUM(price) > 100` $\rightarrow$ Syntax Error) | ✅ Allowed (`HAVING COUNT(p.id) >= 2`) |

#### SQL Query Example: Filter categories that contain 2 or more products
```sql
SELECT 
    c.name AS category_name, 
    COUNT(p.id) AS product_count
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id
HAVING product_count >= 2;
```

**Result in phpMyAdmin:**
```text
+---------------+---------------+
| category_name | product_count |
+---------------+---------------+
| Laptops       |             2 |
+---------------+---------------+
(Phones [1 product] and Empty category [0 products] were discarded by HAVING)
```

---

## Section 4: Views (Virtual Tables)

### 4.1 Concept & Architecture

A **View** is a **stored query** presented to the application as a virtual table.
- A View **does not store duplicated records** on the storage disk.
- Whenever you query a View, MySQL runs the underlying `SELECT` statement in real time.

```text
View Architecture:

                Web Application / PHP Script
                             |
                             v  Queries: SELECT * FROM product_summary;
       +-----------------------------------------------+
       |             VIEW: product_summary             |
       |     (Encapsulates multi-table JOIN logic)     |
       +-----------------------------------------------+
                             |
                             v  Executes underlying SQL:
       +-----------------------------------------------+
       |  SELECT p.id, p.name, p.price, c.name...      |
       |  FROM products p LEFT JOIN categories c...    |
       +-----------------------------------------------+
                             |
             +---------------+---------------+
             v                               v
     Table: products                 Table: categories
```

### 4.2 Creating, Querying, and Dropping Views

#### 1. Create a View (`CREATE VIEW`):
Encapsulate complex `LEFT JOIN` operations so that developers can query a single clean interface:
```sql
CREATE VIEW product_summary AS
SELECT 
    p.id, 
    p.name AS product_name, 
    p.price, 
    c.name AS category_name, 
    p.stock
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;
```

#### 2. Querying the View:
```sql
-- Filter high-value products directly from the View
SELECT product_name, price, category_name 
FROM product_summary 
WHERE price > 100;
```

**Result in phpMyAdmin:**
```text
+--------------+---------+---------------+
| product_name | price   | category_name |
+--------------+---------+---------------+
| Notebook 14  |  750.00 | Laptops       |
| Notebook 16  | 1250.00 | Laptops       |
| Phone A      |  320.00 | Phones        |
+--------------+---------+---------------+
```

#### 3. Dropping a View (`DROP VIEW`):
```sql
DROP VIEW IF EXISTS product_summary;
```

#### Key Advantages of Views:
1. **Query Simplicity:** Hides complex joins from frontend developers.
2. **Access Control & Security:** Exposes product names and prices without exposing sensitive procurement costs or supplier margins.
3. **Consistency:** Guarantees business formulas (such as tax or revenue calculation) remain uniform across all reports.

---

## Section 5: Indexes (Query Performance Optimization)

### 5.1 B-Tree Index vs Full Table Scan

When a table grows to 1,000,000 records:
* **Without Index (Full Table Scan):** To find `name = 'Phone A'`, MySQL reads every single record from row 1 to row 1,000,000 ($\mathcal{O}(N)$ complexity).
* **With Index (B-Tree Search):** MySQL organizes keys into a balanced tree. The record is located in approximately 3 to 4 pointer hops ($\mathcal{O}(\log N)$ complexity).

```text
Balanced Tree (B-Tree) Index Traversal:
                         [ Root Node: M ]
                        /                \
                       v                  v
          [ Branch: D - H ]            [ Branch: P - T ]
          /       |       \            /        |       \
         v        v        v          v         v        v
       [A-C]    [E-G]    [I-L]      [N-O]     [Phone A] [U-Z]
                                                 |
                                                 v
                                        Points directly to physical
                                        storage block (Row ID #3)
```

---

### 5.2 Single-Column & Composite Indexes

#### 1. Single-Column Index:
Add an index to columns frequently used in `WHERE`, `ORDER BY`, or `JOIN ON` clauses:
```sql
-- Speeds up search by product name
CREATE INDEX idx_products_name ON products(name);

-- Speeds up category relationship lookups in JOINs
CREATE INDEX idx_products_category ON products(category_id);
```

#### 2. Composite (Multi-Column) Index:
Used when queries routinely filter by combinations of columns:
```sql
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

#### 💡 The Leftmost Prefix Rule (Crucial Concept):
An index on `(user_id, status)` functions like a telephone directory ordered by `(Last_Name, First_Name)`:
- ✅ `WHERE user_id = 1 AND status = 'delivered'` $\rightarrow$ **INDEX USED** (Maximum speed).
- ✅ `WHERE user_id = 1` $\rightarrow$ **INDEX USED** (Matches leftmost prefix).
- ❌ `WHERE status = 'delivered'` $\rightarrow$ **INDEX CANNOT BE USED** (Skips the leading `user_id` column!).

#### 3. Viewing and Dropping Indexes:
```sql
-- Display all indexes on the products table
SHOW INDEX FROM products;

-- Remove an index
DROP INDEX idx_products_name ON products;
```

#### ⚖️ The Engineering Trade-off of Indexes:
```text
+------------------------------------+------------------------------------+
|             ADVANTAGES             |            DISADVANTAGES           |
+------------------------------------+------------------------------------+
| ⚡ Dramatically accelerates read    | ⏳ Slows down write operations:     |
|    queries: SELECT, WHERE, JOIN,   |    INSERT, UPDATE, DELETE require  |
|    ORDER BY, and GROUP BY.         |    rebalancing the B-Tree index.   |
|                                    | 💾 Consumes additional storage     |
|                                    |    space in RAM and Disk.          |
+------------------------------------+------------------------------------+
👉 GOLDEN RULE: Index columns filtered or joined frequently; avoid over-indexing!
```

---

## Section 6: Real-World Business Reports

### Report 1: Monthly Revenue & Customer Acquisition Report

#### SQL Query:
```sql
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
```

#### Technical Breakdown:
- `DATE_FORMAT(o.created_at, '%Y-%m')`: Extracts Year-Month bucket (e.g. `2026-10`).
- `COUNT(DISTINCT o.id)`: Counts unique order IDs (prevents double-counting when orders contain multiple line items).
- `COUNT(DISTINCT o.user_id)`: Measures unique active paying customers.
- `SUM(oi.price * oi.quantity)`: Computes actual gross revenue per line item.
- `WHERE o.status = 'delivered'`: Eliminates pending or cancelled checkouts.

#### Result in phpMyAdmin:
```text
+---------+--------------+-----------------+------------+---------+
| month   | total_orders | total_customers | items_sold | revenue |
+---------+--------------+-----------------+------------+---------+
| 2026-10 |            1 |               1 |          2 | 1070.00 |
+---------+--------------+-----------------+------------+---------+
```

---

### Report 2: Top 10 Best-Selling Products by Revenue

#### SQL Query:
```sql
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
```

#### Result in phpMyAdmin:
```text
+--------------+------------+---------+
| product_name | total_sold | revenue |
+--------------+------------+---------+
| Notebook 14  |          1 |  750.00 |
| Phone A      |          1 |  320.00 |
+--------------+------------+---------+
```

---

## Section 7: Practice Exercises & Step-by-Step Solutions

---

### 📝 Exercise 1: JOIN Queries

#### Requirement 1.1: Orders with customer information
```sql
SELECT 
    o.id AS order_id, 
    o.total, 
    o.status, 
    o.created_at, 
    u.id AS customer_id, 
    u.email AS customer_email
FROM orders o
INNER JOIN users u ON o.user_id = u.id;
```
**Output:**
```text
+----------+---------+-----------+---------------------+-------------+------------------+
| order_id | total   | status    | created_at          | customer_id | customer_email   |
+----------+---------+-----------+---------------------+-------------+------------------+
|        1 | 1070.00 | delivered | 2026-10-15 10:00:00 |           1 | anna@example.com |
|        2 |  320.00 | pending   | 2026-10-18 14:30:00 |           2 | ben@example.com  |
+----------+---------+-----------+---------------------+-------------+------------------+
```

---

#### Requirement 1.2: Products with category name (including unassigned products)
```sql
SELECT 
    p.id AS product_id, 
    p.name AS product_name, 
    p.price, 
    p.stock, 
    COALESCE(c.name, 'Unassigned') AS category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;
```
> **Pro Tip:** `COALESCE(c.name, 'Unassigned')` replaces raw database `NULL` values with user-friendly text.

**Output:**
```text
+------------+-----------------+---------+-------+---------------+
| product_id | product_name    | price   | stock | category_name |
+------------+-----------------+---------+-------+---------------+
|          1 | Notebook 14     |  750.00 |     5 | Laptops       |
|          2 | Notebook 16     | 1250.00 |     2 | Laptops       |
|          3 | Phone A         |  320.00 |    10 | Phones        |
|          4 | Unsorted gadget |   90.00 |     7 | Unassigned    |
+------------+-----------------+---------+-------+---------------+
```

---

#### Requirement 1.3: Categories that currently have NO products assigned

**Solution Pattern (Anti-Join Pattern):** Perform a `LEFT JOIN` from `categories` to `products`, then filter with `WHERE p.id IS NULL`.

```sql
SELECT 
    c.id AS category_id, 
    c.name AS category_name
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
WHERE p.id IS NULL;
```

#### Anti-Join Logic Trace (ASCII):
```text
categories c (LEFT)                     products p (RIGHT)
+----+----------------+                 +----+-----------------+-------------+
| id | name           |                 | id | name            | category_id |
+----+----------------+                 +----+-----------------+-------------+
|  1 | Laptops        | --------------> |  1 | Notebook 14     |           1 | (Has product: p.id = 1)
|  2 | Phones         | --------------> |  3 | Phone A         |           2 | (Has product: p.id = 3)
|  3 | Empty category | --------------> ❌ | NULL            |        NULL | (No product: p.id IS NULL)
+----+----------------+                 +----+-----------------+-------------+

Mệnh đề WHERE p.id IS NULL selects exactly category ID #3!
```

**Output:**
```text
+-------------+----------------+
| category_id | category_name  |
+-------------+----------------+
|           3 | Empty category |
+-------------+----------------+
```

---

### 📝 Exercise 2: Reporting & Statistics

#### Requirement 2.1: Revenue by category
```sql
SELECT 
    c.id AS category_id, 
    c.name AS category_name, 
    COALESCE(SUM(oi.price * oi.quantity), 0.00) AS total_revenue
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY c.id, c.name
ORDER BY total_revenue DESC;
```
**Output:**
```text
+-------------+----------------+---------------+
| category_id | category_name  | total_revenue |
+-------------+----------------+---------------+
|           1 | Laptops        |        750.00 |
|           2 | Phones         |        640.00 |
|           3 | Empty category |          0.00 |
+-------------+----------------+---------------+
```

---

#### Requirement 2.2: Top 5 customers by total spending
```sql
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
```
**Output:**
```text
+-------------+------------------+-------------+--------------+
| customer_id | customer_email   | total_spent | orders_count |
+-------------+------------------+-------------+--------------+
|           1 | anna@example.com |     1070.00 |            1 |
|           2 | ben@example.com  |      320.00 |            1 |
+-------------+------------------+-------------+--------------+
```

---

#### Requirement 2.3: Products that have NEVER been sold

**Solution Pattern:** `LEFT JOIN` the `products` table with `order_items`. Any product never purchased will yield `oi.id IS NULL`.

```sql
SELECT 
    p.id AS product_id, 
    p.name AS product_name, 
    p.price, 
    p.stock
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE oi.id IS NULL;
```

#### Visual Verification (ASCII):
```text
Table: products p                        Table: order_items oi
+----+-----------------+                 +----+------------+
| id | name            |                 | id | product_id |
+----+-----------------+                 +----+------------+
|  1 | Notebook 14     | --------------> |  1 |          1 | -> SOLD (oi.id = 1)
|  2 | Notebook 16     | --------------> ❌ No entry found  | -> UNSOLD (oi.id = NULL)
|  3 | Phone A         | --------------> |  2 |          3 | -> SOLD (oi.id = 2)
|  4 | Unsorted gadget | --------------> ❌ No entry found  | -> UNSOLD (oi.id = NULL)
+----+-----------------+                 +----+------------+
```

**Output:**
```text
+------------+-----------------+---------+-------+
| product_id | product_name    | price   | stock |
+------------+-----------------+---------+-------+
|          2 | Notebook 16     | 1250.00 |     2 |
|          4 | Unsorted gadget |   90.00 |     7 |
+------------+-----------------+---------+-------+
```

---

## Section 8: phpMyAdmin Graphical Interface Guide

### 8.1 Executing SQL Queries in phpMyAdmin
```text
phpMyAdmin Navigation Interface:
+-----------------------------------------------------------------------------------------+
| [Server: localhost:3306] > [Database: shop_db]                                          |
+-----------------------------------------------------------------------------------------+
| Structure |  👉 SQL 👈  | Search | Query | Export | Import | Operations | Designer     |
+-----------------------------------------------------------------------------------------+
| Run SQL query/queries on database shop_db:                                              |
| +-------------------------------------------------------------------------------------+ |
| | SELECT p.name, c.name FROM products p LEFT JOIN categories c ON p.category_id=c.id; | |
| +-------------------------------------------------------------------------------------+ |
| [ Clear ]                                                             [ 👉 Go / Exec 👈 ]|
+-----------------------------------------------------------------------------------------+
```

### 8.2 Inspecting Foreign Key Relationships with the "Designer" Tab
1. Select the `shop_db` database in the left sidebar.
2. Click the **Designer** tab located in the top navigation bar (or under **More $\rightarrow$ Designer**).
3. phpMyAdmin displays the interactive ER diagram with visual connector lines between Primary and Foreign Keys.

### 8.3 Managing Indexes Visually via the "Structure" Tab
1. Click on the `products` table $\rightarrow$ navigate to the **Structure** tab.
2. Scroll below the column definitions to the **Indexes** pane:
   - Click **+ Create an index on 1 column** to create an index through GUI dialogs.
   - Click **Drop** next to any index name (`idx_products_name`) to delete it.

### 8.4 Viewing and Inspecting Views in the phpMyAdmin Sidebar Tree
- Once you execute `CREATE VIEW product_summary AS ...`, the left navigation sidebar updates:
```text
▼ shop_db (5 tables, 1 view)
    ├── 📄 categories
    ├── 📄 order_items
    ├── 📄 orders
    ├── 📄 products
    ├── 📄 users
    └── 👁️ product_summary  <-- The "eye" icon indicates a virtual VIEW!
```
- Clicking on `product_summary` opens the live result grid exactly like a physical table.

---

## Quick Reference Cheat Sheet

```text
+---------------------+-------------------------------------------------------------+
| SQL Construct       | Core Purpose & Behavior                                     |
+---------------------+-------------------------------------------------------------+
| INNER JOIN          | Keeps rows only when matching keys exist in BOTH tables.    |
| LEFT JOIN           | Retains ALL left-table rows; fills right columns with NULL. |
| RIGHT JOIN          | Retains ALL right-table rows; fills left columns with NULL.  |
| LEFT JOIN + IS NULL | Identifies orphan records (Anti-Join pattern).              |
| SUBQUERY            | Nested query calculating intermediate scalars or sets.      |
| GROUP BY            | Aggregates and collapses duplicate key rows into buckets.   |
| HAVING              | Post-filter applied AFTER aggregate functions execute.      |
| VIEW                | Stored virtual query; consumes 0 disk storage for records.  |
| INDEX (B-Tree)      | Accelerates SELECT/WHERE lookups to O(log N); slows writes. |
+---------------------+-------------------------------------------------------------+
```

