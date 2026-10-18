-- ============================================================
--  bookstore_db.sql
--  Online Bookstore — Complete Database Schema & Sample Data
--  Course : INS3064
--  Engine : InnoDB | Charset: utf8mb4
-- ============================================================

-- ============================================================
-- SECTION 0 — DATABASE SETUP
-- ============================================================
CREATE DATABASE IF NOT EXISTS bookstore
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bookstore;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- SECTION 1 — NORMALIZATION EXPLANATION (3NF)
-- ============================================================
/*
  FIRST NORMAL FORM (1NF)
  ───────────────────────
  • Every column holds a single atomic value.
  • No repeating groups or arrays.
  • Example: a book's multiple authors are NOT stored as a
    comma-separated string inside `books.authors`. Instead,
    the M:N relationship is split into a separate junction
    table `book_authors`, so each cell is atomic.

  SECOND NORMAL FORM (2NF)
  ────────────────────────
  • All non-key attributes depend on the WHOLE primary key.
  • Applies to tables with composite PKs:
      - book_authors  PK(book_id, author_id)
        → `role` describes the relationship between that
           specific book AND that specific author, not just
           the book or the author alone. ✓
      - book_categories  PK(book_id, category_id)
        → no extra columns; pure association. ✓
      - order_items  has a surrogate PK `item_id`, plus
        UNIQUE(order_id, book_id).
        → `unit_price` records the price at the moment of
           purchase (per order-line pair), not a property
           of either order or book in isolation. ✓

  THIRD NORMAL FORM (3NF)
  ───────────────────────
  • No transitive dependencies (non-key → non-key).
  • Key design decisions that achieve 3NF:
      1. Publisher details (name, address, website, phone)
         live in their own `publishers` table.
         `books` stores only `publisher_id` (FK).
         This prevents: book_id → publisher_id → publisher_name
         (which would be a transitive dependency). ✓
      2. Customer details (name, email, address) are in
         `customers`; `orders` stores only `customer_id`.
         This prevents: order_id → customer_id → customer_email. ✓
      3. Category hierarchy uses a self-referencing FK
         (parent_id) in `categories`, NOT a denormalized
         column like `parent_name` beside `name`. ✓
      4. `order_items.subtotal` is stored as a computed
         snapshot (quantity × unit_price at purchase time)
         for audit purposes — considered acceptable
         denormalization in e-commerce systems (historical
         accuracy). If strict 3NF is required, drop it and
         compute on read. ✓
*/

-- ============================================================
-- SECTION 2 — TABLE DEFINITIONS
-- ============================================================

-- -----------------------------------------------------------
-- 2.1  publishers
-- -----------------------------------------------------------
CREATE TABLE publishers (
    publisher_id   INT            NOT NULL AUTO_INCREMENT,
    name           VARCHAR(150)   NOT NULL,
    address        VARCHAR(255)   DEFAULT NULL,
    website        VARCHAR(255)   DEFAULT NULL,
    email          VARCHAR(150)   DEFAULT NULL,
    phone          VARCHAR(30)    DEFAULT NULL,
    founded_year   YEAR           DEFAULT NULL,
    PRIMARY KEY (publisher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.2  authors
-- -----------------------------------------------------------
CREATE TABLE authors (
    author_id    INT           NOT NULL AUTO_INCREMENT,
    first_name   VARCHAR(80)   NOT NULL,
    last_name    VARCHAR(80)   NOT NULL,
    biography    TEXT          DEFAULT NULL,
    nationality  VARCHAR(60)   DEFAULT NULL,
    birth_date   DATE          DEFAULT NULL,
    email        VARCHAR(150)  DEFAULT NULL,
    PRIMARY KEY (author_id),
    UNIQUE KEY uq_author_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.3  categories  (self-referencing for sub-genres)
-- -----------------------------------------------------------
CREATE TABLE categories (
    category_id   INT           NOT NULL AUTO_INCREMENT,
    name          VARCHAR(100)  NOT NULL,
    description   TEXT          DEFAULT NULL,
    parent_id     INT           DEFAULT NULL,
    PRIMARY KEY (category_id),
    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_id) REFERENCES categories (category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.4  books
-- -----------------------------------------------------------
CREATE TABLE books (
    book_id           INT            NOT NULL AUTO_INCREMENT,
    title             VARCHAR(255)   NOT NULL,
    isbn              VARCHAR(20)    NOT NULL,
    publisher_id      INT            NOT NULL,
    publication_date  DATE           DEFAULT NULL,
    edition           SMALLINT       DEFAULT 1,
    language          VARCHAR(50)    DEFAULT 'English',
    pages             SMALLINT       DEFAULT NULL,
    price             DECIMAL(10,2)  NOT NULL,
    stock             INT            NOT NULL DEFAULT 0,
    description       TEXT           DEFAULT NULL,
    cover_image_url   VARCHAR(255)   DEFAULT NULL,
    created_at        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id),
    UNIQUE KEY uq_book_isbn (isbn),
    CONSTRAINT fk_book_publisher
        FOREIGN KEY (publisher_id) REFERENCES publishers (publisher_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_book_price  CHECK (price > 0),
    CONSTRAINT chk_book_stock  CHECK (stock >= 0),
    CONSTRAINT chk_book_pages  CHECK (pages IS NULL OR pages > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.5  book_authors  (M:N junction — books ↔ authors)
-- -----------------------------------------------------------
CREATE TABLE book_authors (
    book_id    INT   NOT NULL,
    author_id  INT   NOT NULL,
    role       ENUM('primary','co-author','editor') NOT NULL DEFAULT 'primary',
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book
        FOREIGN KEY (book_id) REFERENCES books (book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ba_author
        FOREIGN KEY (author_id) REFERENCES authors (author_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.6  book_categories  (M:N junction — books ↔ categories)
-- -----------------------------------------------------------
CREATE TABLE book_categories (
    book_id      INT   NOT NULL,
    category_id  INT   NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_bc_book
        FOREIGN KEY (book_id) REFERENCES books (book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bc_category
        FOREIGN KEY (category_id) REFERENCES categories (category_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.7  customers
-- -----------------------------------------------------------
CREATE TABLE customers (
    customer_id    INT           NOT NULL AUTO_INCREMENT,
    first_name     VARCHAR(80)   NOT NULL,
    last_name      VARCHAR(80)   NOT NULL,
    email          VARCHAR(150)  NOT NULL,
    password_hash  VARCHAR(255)  NOT NULL,
    phone          VARCHAR(30)   DEFAULT NULL,
    address        VARCHAR(255)  DEFAULT NULL,
    city           VARCHAR(100)  DEFAULT NULL,
    country        VARCHAR(80)   NOT NULL DEFAULT 'Vietnam',
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_id),
    UNIQUE KEY uq_customer_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.8  orders
-- -----------------------------------------------------------
CREATE TABLE orders (
    order_id          INT            NOT NULL AUTO_INCREMENT,
    customer_id       INT            NOT NULL,
    order_date        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status            ENUM('pending','confirmed','shipped','delivered','cancelled')
                                     NOT NULL DEFAULT 'pending',
    total_amount      DECIMAL(12,2)  NOT NULL,
    shipping_address  VARCHAR(255)   NOT NULL,
    shipping_city     VARCHAR(100)   NOT NULL,
    shipping_country  VARCHAR(80)    NOT NULL DEFAULT 'Vietnam',
    notes             TEXT           DEFAULT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_order_total CHECK (total_amount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.9  order_items
-- -----------------------------------------------------------
CREATE TABLE order_items (
    item_id     INT            NOT NULL AUTO_INCREMENT,
    order_id    INT            NOT NULL,
    book_id     INT            NOT NULL,
    quantity    SMALLINT       NOT NULL,
    unit_price  DECIMAL(10,2)  NOT NULL,
    subtotal    DECIMAL(12,2)  NOT NULL,
    PRIMARY KEY (item_id),
    UNIQUE KEY uq_order_book (order_id, book_id),
    CONSTRAINT fk_oi_order
        FOREIGN KEY (order_id) REFERENCES orders (order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_oi_book
        FOREIGN KEY (book_id) REFERENCES books (book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_oi_quantity   CHECK (quantity > 0),
    CONSTRAINT chk_oi_unitprice  CHECK (unit_price > 0),
    CONSTRAINT chk_oi_subtotal   CHECK (subtotal >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2.10 reviews
-- -----------------------------------------------------------
CREATE TABLE reviews (
    review_id    INT       NOT NULL AUTO_INCREMENT,
    customer_id  INT       NOT NULL,
    book_id      INT       NOT NULL,
    rating       TINYINT   NOT NULL,
    comment      TEXT      DEFAULT NULL,
    review_date  DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    UNIQUE KEY uq_review_customer_book (customer_id, book_id),
    CONSTRAINT fk_review_customer
        FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_review_book
        FOREIGN KEY (book_id) REFERENCES books (book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SECTION 3 — SAMPLE DATA
-- ============================================================

-- -----------------------------------------------------------
-- 3.1  publishers  (4 rows)
-- -----------------------------------------------------------
INSERT INTO publishers (name, address, website, email, phone, founded_year) VALUES
('O\'Reilly Media',
 '1005 Gravenstein Hwy N, Sebastopol, CA 95472, USA',
 'https://www.oreilly.com',
 'contact@oreilly.com', '+1-707-827-7000', 1978),

('Pearson Education',
 '221 River Street, Hoboken, NJ 07030, USA',
 'https://www.pearson.com',
 'info@pearson.com', '+1-201-236-7000', 1844),

('Penguin Random House',
 '1745 Broadway, New York, NY 10019, USA',
 'https://www.penguinrandomhouse.com',
 'customerservice@prh.com', '+1-212-782-9000', 1927),

('No Starch Press',
 '245 8th Street, San Francisco, CA 94103, USA',
 'https://nostarch.com',
 'info@nostarch.com', '+1-415-863-9900', 1994);

-- -----------------------------------------------------------
-- 3.2  authors  (6 rows)
-- -----------------------------------------------------------
INSERT INTO authors (first_name, last_name, biography, nationality, birth_date, email) VALUES
('Andrew', 'Hunt',
 'Co-author of The Pragmatic Programmer; software developer and author.',
 'American', '1964-03-15', 'andrew.hunt@example.com'),

('David', 'Thomas',
 'Co-author of The Pragmatic Programmer; software craftsman.',
 'British', '1956-07-22', 'david.thomas@example.com'),

('Robert', 'Martin',
 'Known as "Uncle Bob"; author of Clean Code and Clean Architecture.',
 'American', '1952-12-05', 'robert.martin@example.com'),

('Donald', 'Knuth',
 'Author of The Art of Computer Programming; Turing Award laureate.',
 'American', '1938-01-10', 'donald.knuth@example.com'),

('Yuval', 'Harari',
 'Author of Sapiens and Homo Deus; historian and professor at Hebrew University.',
 'Israeli', '1976-02-24', 'yuval.harari@example.com'),

('J.K.', 'Rowling',
 'Author of the Harry Potter series; one of the best-selling authors of all time.',
 'British', '1965-07-31', 'jk.rowling@example.com');

-- -----------------------------------------------------------
-- 3.3  categories  (5 rows, with one sub-category)
-- -----------------------------------------------------------
INSERT INTO categories (name, description, parent_id) VALUES
('Technology',    'Books about software, hardware, and computing.', NULL),
('Programming',   'Software development, algorithms, and coding practices.', 1),
('Fiction',       'Novels and short stories across all genres.', NULL),
('Science Fiction','Speculative fiction involving science and technology.', 3),
('History & Society', 'Non-fiction exploring human history and culture.', NULL);

-- -----------------------------------------------------------
-- 3.4  books  (8 rows)
-- -----------------------------------------------------------
INSERT INTO books (title, isbn, publisher_id, publication_date, edition, language, pages, price, stock, description) VALUES
('The Pragmatic Programmer: Your Journey to Mastery',
 '978-0-13-595705-9', 2, '2019-09-13', 2, 'English', 352, 49.99, 120,
 'A classic guide to software craftsmanship, now fully updated for modern development.'),

('Clean Code: A Handbook of Agile Software Craftsmanship',
 '978-0-13-235088-4', 2, '2008-08-01', 1, 'English', 431, 44.99, 85,
 'Robert Martin''s guide to writing clean, maintainable code.'),

('The Art of Computer Programming, Vol. 1',
 '978-0-20-188919-2', 2, '1997-07-04', 3, 'English', 672, 79.99, 40,
 'The definitive guide to algorithms and programming by Donald Knuth.'),

('Python Crash Course',
 '978-1-71-850196-5', 4, '2023-01-10', 3, 'English', 552, 39.99, 200,
 'A hands-on, project-based introduction to Python programming.'),

('Clean Architecture: A Craftsman\'s Guide to Software Structure',
 '978-0-13-468599-1', 2, '2017-09-12', 1, 'English', 432, 47.99, 70,
 'Robert Martin''s guide to software architecture principles.'),

('Sapiens: A Brief History of Humankind',
 '978-0-06-231610-4', 3, '2015-02-10', 1, 'English', 443, 18.99, 300,
 'A sweeping narrative of humanity''s creation and evolution.'),

('Homo Deus: A Brief History of Tomorrow',
 '978-0-06-246431-5', 3, '2017-03-21', 1, 'English', 449, 17.99, 250,
 'Harari explores the future of humanity, technology, and consciousness.'),

('Harry Potter and the Philosopher\'s Stone',
 '978-0-74-757301-6', 3, '1997-06-26', 1, 'English', 223, 12.99, 500,
 'The first book in the world-famous Harry Potter fantasy series.');

-- -----------------------------------------------------------
-- 3.5  book_authors
-- -----------------------------------------------------------
INSERT INTO book_authors (book_id, author_id, role) VALUES
(1, 1, 'primary'),    -- Pragmatic Programmer: Andrew Hunt
(1, 2, 'co-author'),  -- Pragmatic Programmer: David Thomas
(2, 3, 'primary'),    -- Clean Code: Robert Martin
(3, 4, 'primary'),    -- Art of Computer Programming: Donald Knuth
(4, 1, 'primary'),    -- Python Crash Course: (illustrative — using Hunt)
(5, 3, 'primary'),    -- Clean Architecture: Robert Martin
(6, 5, 'primary'),    -- Sapiens: Yuval Harari
(7, 5, 'primary'),    -- Homo Deus: Yuval Harari
(8, 6, 'primary');    -- Harry Potter: J.K. Rowling

-- -----------------------------------------------------------
-- 3.6  book_categories
-- -----------------------------------------------------------
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 1), (1, 2),   -- Pragmatic Programmer: Technology, Programming
(2, 1), (2, 2),   -- Clean Code: Technology, Programming
(3, 1), (3, 2),   -- Art of Computer Programming: Technology, Programming
(4, 1), (4, 2),   -- Python Crash Course: Technology, Programming
(5, 1), (5, 2),   -- Clean Architecture: Technology, Programming
(6, 5),           -- Sapiens: History & Society
(7, 5),           -- Homo Deus: History & Society
(8, 3);           -- Harry Potter: Fiction

-- -----------------------------------------------------------
-- 3.7  customers  (5 rows)
-- -----------------------------------------------------------
INSERT INTO customers (first_name, last_name, email, password_hash, phone, address, city, country) VALUES
('Nguyen', 'Van An',
 'van.an@email.com',
 '$2y$12$examplehash1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
 '0901234567', '12 Le Loi Street', 'Ho Chi Minh City', 'Vietnam'),

('Tran', 'Thi Bich',
 'thi.bich@email.com',
 '$2y$12$examplehash2xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
 '0912345678', '45 Hang Bai Street', 'Hanoi', 'Vietnam'),

('Pham', 'Quoc Cuong',
 'quoc.cuong@email.com',
 '$2y$12$examplehash3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
 '0923456789', '78 Tran Phu Street', 'Da Nang', 'Vietnam'),

('Le', 'Thi Dung',
 'thi.dung@email.com',
 '$2y$12$examplehash4xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
 '0934567890', '22 Nguyen Hue Boulevard', 'Ho Chi Minh City', 'Vietnam'),

('Hoang', 'Minh Em',
 'minh.em@email.com',
 '$2y$12$examplehash5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
 '0945678901', '5 Ba Trieu Street', 'Hanoi', 'Vietnam');

-- -----------------------------------------------------------
-- 3.8  orders  (6 rows)
-- -----------------------------------------------------------
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address, shipping_city, shipping_country) VALUES
(1, '2024-01-10 09:15:00', 'delivered',  94.98, '12 Le Loi Street',        'Ho Chi Minh City', 'Vietnam'),
(2, '2024-02-14 14:30:00', 'delivered',  79.99, '45 Hang Bai Street',      'Hanoi',            'Vietnam'),
(3, '2024-03-05 11:00:00', 'shipped',    62.98, '78 Tran Phu Street',      'Da Nang',          'Vietnam'),
(1, '2024-04-20 16:45:00', 'confirmed',  47.99, '12 Le Loi Street',        'Ho Chi Minh City', 'Vietnam'),
(4, '2024-05-03 10:20:00', 'delivered',  89.96, '22 Nguyen Hue Boulevard', 'Ho Chi Minh City', 'Vietnam'),
(5, '2024-06-18 08:55:00', 'pending',    30.98, '5 Ba Trieu Street',       'Hanoi',            'Vietnam');

-- -----------------------------------------------------------
-- 3.9  order_items  (13 rows — satisfies the 12+ requirement)
-- -----------------------------------------------------------
INSERT INTO order_items (order_id, book_id, quantity, unit_price, subtotal) VALUES
-- Order 1 (customer 1): Pragmatic Programmer + Clean Code = 94.98
(1, 1, 1, 49.99, 49.99),
(1, 2, 1, 44.99, 44.99),

-- Order 2 (customer 2): Art of Computer Programming = 79.99
(2, 3, 1, 79.99, 79.99),

-- Order 3 (customer 3): Python Crash Course + Sapiens + Harry Potter = 71.97
-- (note: order total_amount 62.98 stores a negotiated/coupon price snapshot)
(3, 4, 1, 39.99, 39.99),
(3, 6, 1, 11.99, 11.99),   -- Sapiens (promotional price)
(3, 8, 1, 11.00, 11.00),   -- Harry Potter (promotional price)  → total 62.98

-- Order 4 (customer 1 — second order): Clean Architecture = 47.99
(4, 5, 1, 47.99, 47.99),

-- Order 5 (customer 4): Sapiens + Homo Deus + Harry Potter + Pragmatic Programmer = 89.96
(5, 6, 1, 18.99, 18.99),
(5, 7, 1, 17.99, 17.99),
(5, 8, 1, 12.99, 12.99),
(5, 1, 1, 39.99, 39.99),   -- Pragmatic Programmer

-- Order 6 (customer 5): Homo Deus + Harry Potter = 30.98
(6, 7, 1, 17.99, 17.99),
(6, 8, 1, 12.99, 12.99);

-- -----------------------------------------------------------
-- 3.10 reviews  (10 rows)
-- -----------------------------------------------------------
INSERT INTO reviews (customer_id, book_id, rating, comment, review_date) VALUES
(1, 1, 5, 'Absolutely essential for any serious developer. Changed my approach to coding completely.',
 '2024-01-25 10:00:00'),
(1, 2, 5, 'Uncle Bob delivers again. Every page has something valuable.',
 '2024-01-26 11:30:00'),
(2, 3, 4, 'Incredibly thorough. Dense but rewarding for those willing to commit.',
 '2024-02-28 09:15:00'),
(3, 4, 5, 'Best Python book for beginners. Projects make it really stick.',
 '2024-03-20 14:00:00'),
(3, 6, 4, 'Fascinating perspective on human history. Well-written and thought-provoking.',
 '2024-03-21 15:30:00'),
(3, 8, 5, 'A magical story that captured my imagination from the first page.',
 '2024-03-22 16:00:00'),
(4, 6, 5, 'Sapiens is brilliant — required reading for understanding ourselves.',
 '2024-05-15 08:45:00'),
(4, 7, 4, 'Homo Deus is thought-provoking but slightly more speculative than Sapiens.',
 '2024-05-16 09:30:00'),
(4, 8, 5, 'Timeless classic. My kids love it too!',
 '2024-05-17 10:15:00'),
(5, 7, 3, 'Interesting ideas but some sections felt too long. Still worth reading.',
 '2024-06-25 12:00:00');

-- ============================================================
-- END OF FILE
-- ============================================================
