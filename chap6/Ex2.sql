CREATE DATABASE library_db;
USE library_db;

CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publication_year YEAR,
    publisher VARCHAR(150)
);

CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    join_date DATE NOT NULL
        DEFAULT (CURRENT_DATE)
);

CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(150) NOT NULL,
    birth_date DATE
);

CREATE TABLE Book_Authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id)
        REFERENCES Books(book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (author_id)
        REFERENCES Authors(author_id)
        ON DELETE CASCADE
);

CREATE TABLE Borrowings (
    borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL
        DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id)
        REFERENCES Books(book_id),
    FOREIGN KEY (member_id)
        REFERENCES Members(member_id),
    CHECK (due_date >= borrow_date),
    CHECK (
        return_date IS NULL
        OR return_date >= borrow_date
    )
);