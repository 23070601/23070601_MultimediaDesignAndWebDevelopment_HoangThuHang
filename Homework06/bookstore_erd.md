# Bookstore Database — Entity-Relationship Diagram

## Legend

```
PK  = Primary Key
FK  = Foreign Key
NN  = NOT NULL
UQ  = UNIQUE
AI  = AUTO_INCREMENT

Cardinality notation (Crow's Foot text style):
  ||     exactly one
  |<     one or many  (1:N side)
  >|     many to one
  >|<    many to many
```

---

## Entities & Attributes

### publishers
| Column          | Type          | Constraints     |
|-----------------|---------------|-----------------|
| publisher_id    | INT           | PK, AI, NN      |
| name            | VARCHAR(150)  | NN              |
| address         | VARCHAR(255)  |                 |
| website         | VARCHAR(255)  |                 |
| email           | VARCHAR(150)  |                 |
| phone           | VARCHAR(30)   |                 |
| founded_year    | YEAR          |                 |

---

### authors
| Column       | Type          | Constraints     |
|--------------|---------------|-----------------|
| author_id    | INT           | PK, AI, NN      |
| first_name   | VARCHAR(80)   | NN              |
| last_name    | VARCHAR(80)   | NN              |
| biography    | TEXT          |                 |
| nationality  | VARCHAR(60)   |                 |
| birth_date   | DATE          |                 |
| email        | VARCHAR(150)  | UQ              |

---

### categories
| Column        | Type          | Constraints          |
|---------------|---------------|----------------------|
| category_id   | INT           | PK, AI, NN           |
| name          | VARCHAR(100)  | NN                   |
| description   | TEXT          |                      |
| parent_id     | INT           | FK → categories(category_id) |

*Self-referencing FK allows sub-genres (e.g., "Science Fiction" → parent "Fiction").*

---

### books
| Column           | Type           | Constraints                       |
|------------------|----------------|-----------------------------------|
| book_id          | INT            | PK, AI, NN                        |
| title            | VARCHAR(255)   | NN                                |
| isbn             | VARCHAR(20)    | UQ, NN                            |
| publisher_id     | INT            | FK → publishers(publisher_id), NN |
| publication_date | DATE           |                                   |
| edition          | SMALLINT       | DEFAULT 1                         |
| language         | VARCHAR(50)    | DEFAULT 'English'                 |
| pages            | SMALLINT       | CHECK (pages > 0)                 |
| price            | DECIMAL(10,2)  | NN, CHECK (price > 0)             |
| stock            | INT            | NN, DEFAULT 0, CHECK (stock >= 0) |
| description      | TEXT           |                                   |
| cover_image_url  | VARCHAR(255)   |                                   |
| created_at       | DATETIME       | DEFAULT CURRENT_TIMESTAMP         |

---

### book_authors  *(junction — resolves Books ↔ Authors M:N)*
| Column      | Type | Constraints                    |
|-------------|------|--------------------------------|
| book_id     | INT  | PK (composite), FK → books     |
| author_id   | INT  | PK (composite), FK → authors   |
| role        | ENUM | 'primary','co-author','editor' |

---

### book_categories  *(junction — resolves Books ↔ Categories M:N)*
| Column       | Type | Constraints                        |
|--------------|------|------------------------------------|
| book_id      | INT  | PK (composite), FK → books         |
| category_id  | INT  | PK (composite), FK → categories    |

---

### customers
| Column          | Type          | Constraints              |
|-----------------|---------------|--------------------------|
| customer_id     | INT           | PK, AI, NN               |
| first_name      | VARCHAR(80)   | NN                       |
| last_name       | VARCHAR(80)   | NN                       |
| email           | VARCHAR(150)  | UQ, NN                   |
| password_hash   | VARCHAR(255)  | NN                       |
| phone           | VARCHAR(30)   |                          |
| address         | VARCHAR(255)  |                          |
| city            | VARCHAR(100)  |                          |
| country         | VARCHAR(80)   | DEFAULT 'Vietnam'        |
| created_at      | DATETIME      | DEFAULT CURRENT_TIMESTAMP|

---

### orders
| Column           | Type           | Constraints                                    |
|------------------|----------------|------------------------------------------------|
| order_id         | INT            | PK, AI, NN                                     |
| customer_id      | INT            | FK → customers(customer_id), NN                |
| order_date       | DATETIME       | DEFAULT CURRENT_TIMESTAMP                      |
| status           | ENUM           | 'pending','confirmed','shipped','delivered','cancelled' DEFAULT 'pending' |
| total_amount     | DECIMAL(12,2)  | NN, CHECK (total_amount >= 0)                  |
| shipping_address | VARCHAR(255)   | NN                                             |
| shipping_city    | VARCHAR(100)   | NN                                             |
| shipping_country | VARCHAR(80)    | DEFAULT 'Vietnam'                              |
| notes            | TEXT           |                                                |

---

### order_items
| Column       | Type           | Constraints                               |
|--------------|----------------|-------------------------------------------|
| item_id      | INT            | PK, AI, NN                                |
| order_id     | INT            | FK → orders(order_id), NN                 |
| book_id      | INT            | FK → books(book_id), NN                   |
| quantity     | SMALLINT       | NN, CHECK (quantity > 0)                  |
| unit_price   | DECIMAL(10,2)  | NN, CHECK (unit_price > 0)                |
| subtotal     | DECIMAL(12,2)  | NN (= quantity × unit_price)              |
| UNIQUE(order_id, book_id) |       |                                           |

---

### reviews
| Column       | Type      | Constraints                                       |
|--------------|-----------|---------------------------------------------------|
| review_id    | INT       | PK, AI, NN                                        |
| customer_id  | INT       | FK → customers(customer_id), NN                   |
| book_id      | INT       | FK → books(book_id), NN                           |
| rating       | TINYINT   | NN, CHECK (rating BETWEEN 1 AND 5)                |
| comment      | TEXT      |                                                   |
| review_date  | DATETIME  | DEFAULT CURRENT_TIMESTAMP                         |
| UNIQUE(customer_id, book_id) |   | one review per customer per book                  |

---

## Relationship Diagram (Crow's Foot ASCII)

```
publishers ||-----|< books
                     |
          >|---------|< categories
          |
        book_categories
          |
          |>---------- categories (self-ref: parent_id)

books >|---------|< authors
         book_authors

customers ||-----|< orders
orders ||-----|< order_items >|-----|| books
customers ||-----|< reviews >|-----|| books
```

### Detailed Cardinality

```
publishers  ─── 1:N ───  books
               (one publisher publishes many books;
                each book has exactly one publisher)

books  ─── M:N ───  authors
               resolved by book_authors junction table
               (a book can have many authors;
                an author can write many books)

books  ─── M:N ───  categories
               resolved by book_categories junction table
               (a book belongs to many categories;
                a category contains many books)

categories ─── 1:N ─── categories
               self-referencing parent_id for sub-genres

customers  ─── 1:N ───  orders
               (one customer places many orders)

orders  ─── 1:N ───  order_items  ─── N:1 ───  books
               (one order has many line items;
                each item references one book)

customers  ─── 1:N ───  reviews  ─── N:1 ───  books
               (one customer writes many reviews;
                one book receives many reviews)
```

---

## Full ER Diagram (Text Box Notation)

```
┌─────────────────────────────┐          ┌──────────────────────────────┐
│         publishers          │          │            authors            │
├─────────────────────────────┤          ├──────────────────────────────┤
│ PK publisher_id  INT        │          │ PK author_id    INT          │
│    name          VARCHAR    │          │    first_name   VARCHAR      │
│    address       VARCHAR    │          │    last_name    VARCHAR      │
│    website       VARCHAR    │          │    biography    TEXT         │
│    email         VARCHAR    │          │    nationality  VARCHAR      │
│    phone         VARCHAR    │          │    birth_date   DATE         │
│    founded_year  YEAR       │          │    email        VARCHAR UQ   │
└──────────┬──────────────────┘          └────────────────┬─────────────┘
           │ 1                                            │
           │                                             M│
           │ N          ┌─────────────────────┐          │
           └────────────┤       books         ├──────────┘
                        ├─────────────────────┤
                        │ PK book_id      INT │─────── book_authors (junction)
                        │    title    VARCHAR │         ┌──────────────────────┐
                        │ UQ isbn     VARCHAR │         │    book_authors       │
                        │ FK publisher_id INT │         ├──────────────────────┤
                        │    pub_date  DATE   │         │ PK,FK book_id    INT │
                        │    edition  SMALL   │         │ PK,FK author_id  INT │
                        │    language VARCHAR │         │    role          ENUM│
                        │    pages    SMALL   │         └──────────────────────┘
                        │    price    DECIMAL │
                        │    stock    INT     │─────── book_categories (junction)
                        │    description TEXT │         ┌──────────────────────┐
                        └────────┬────────────┘         │  book_categories     │
                                 │                      ├──────────────────────┤
                                 │ M                    │ PK,FK book_id    INT │
                                 │                      │ PK,FK category_id INT│
                        ┌────────┴────────────┐         └──────────────────────┘
                        │      categories     │
                        ├─────────────────────┤
                        │ PK category_id  INT │◄──┐ (self-ref)
                        │    name     VARCHAR │   │
                        │    description TEXT │   │
                        │ FK parent_id    INT │───┘
                        └─────────────────────┘

┌────────────────────────────┐
│         customers          │
├────────────────────────────┤
│ PK customer_id  INT        │
│    first_name   VARCHAR    │
│    last_name    VARCHAR    │
│ UQ email        VARCHAR    │
│    password_hash VARCHAR   │
│    phone        VARCHAR    │
│    address      VARCHAR    │
│    city         VARCHAR    │
│    country      VARCHAR    │
│    created_at   DATETIME   │
└────────┬────────┬──────────┘
         │ 1      │ 1
         │        └─────────────────────────────────┐
         │ N                                        │ N
         │                                          │
┌────────┴────────────────┐             ┌───────────┴──────────────────┐
│         orders          │             │           reviews             │
├─────────────────────────┤             ├──────────────────────────────┤
│ PK order_id     INT     │             │ PK review_id   INT           │
│ FK customer_id  INT     │             │ FK customer_id INT           │
│    order_date   DATETIME│             │ FK book_id     INT  ────N:1──► books
│    status       ENUM    │             │    rating      TINYINT       │
│    total_amount DECIMAL │             │    comment     TEXT          │
│    ship_address VARCHAR │             │    review_date DATETIME      │
│    ship_city    VARCHAR │             │ UQ(customer_id, book_id)     │
│    ship_country VARCHAR │             └──────────────────────────────┘
│    notes        TEXT    │
└────────┬────────────────┘
         │ 1
         │ N
┌────────┴────────────────┐
│       order_items       │
├─────────────────────────┤
│ PK item_id      INT     │
│ FK order_id     INT     │
│ FK book_id      INT ────┼──── N:1 ──► books
│    quantity     SMALL   │
│    unit_price   DECIMAL │
│    subtotal     DECIMAL │
│ UQ(order_id, book_id)   │
└─────────────────────────┘
```

---

## Normalization Summary

### 1NF — First Normal Form
All columns store **atomic (indivisible) values**. No repeating groups or arrays exist. For example, a book's multiple authors are not stored as a comma-separated list inside `books`; instead they are broken out into the `book_authors` junction table.

### 2NF — Second Normal Form
All non-key attributes depend on the **entire** primary key, not just part of it. In `book_authors` (composite PK = `book_id` + `author_id`), the only extra attribute is `role`, which is a property of the *relationship* between a specific book and a specific author — not of either alone. Similarly, `order_items.unit_price` is a property of a specific (order, book) pair (the price at time of purchase), not of the book alone.

### 3NF — Third Normal Form
No non-key column depends on another non-key column (no transitive dependencies). For example:
- Publisher details (name, address, website) live in the `publishers` table; `books` only stores `publisher_id`. This avoids a transitive dependency chain `book_id → publisher_id → publisher_name`.
- `orders.total_amount` is stored (denormalized for audit), but all other customer fields are in `customers`, reached via `customer_id`.
- `categories.parent_id` is a self-referencing FK, not a transitive dependency on a non-key attribute.
