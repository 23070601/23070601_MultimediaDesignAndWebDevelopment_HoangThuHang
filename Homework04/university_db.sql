-- ============================================================================
-- UNIVERSITY COURSE REGISTRATION SYSTEM - DATABASE SCHEMA & SAMPLE DATA
-- Assignment: Homework 04 - INS3064 Web Development
-- Database System: MySQL 8.0+ / MariaDB (phpMyAdmin Compatible)
-- Author: Hoang Thu Hang (Student ID: 23070601)
-- Date: October 2026
-- Description: Idempotent SQL script creating database, tables, constraints,
--              foreign key relationships, and initial realistic sample data.
-- ============================================================================

-- Step 1: Idempotent Database Initialization
DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE university_db;

-- ============================================================================
-- TABLE CREATION (ORDERED BY DEPENDENCY)
-- ============================================================================

-- Table 1: DEPARTMENTS
-- Purpose: Stores information about academic departments within the university.
-- Primary Key: department_id (AUTO_INCREMENT)
-- Constraints: UNIQUE department_name and department_code.
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_code VARCHAR(10) NOT NULL UNIQUE COMMENT 'Short code like FIT, FBF, FBA',
    department_name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Full department title',
    building_location VARCHAR(100) NOT NULL DEFAULT 'Main Campus' COMMENT 'Campus building/office area',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Academic departments';

-- Table 2: INSTRUCTORS
-- Purpose: Stores faculty members, linked to their parent department.
-- Foreign Key: department_id -> departments(department_id)
-- Constraints: UNIQUE email and instructor_code; ENUM gender.
CREATE TABLE instructors (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Faculty employee ID',
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Institutional email address',
    phone VARCHAR(20) DEFAULT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL DEFAULT 'Other',
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_instructors_department 
        FOREIGN KEY (department_id) REFERENCES departments(department_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Faculty members and course instructors';

-- Table 3: STUDENTS
-- Purpose: Stores enrolled student details and their declared major department.
-- Foreign Key: department_id -> departments(department_id) (Major)
-- Constraints: UNIQUE email and student_code; CHECK gpa between 0.00 and 4.00.
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Official student ID number',
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) DEFAULT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    date_of_birth DATE NOT NULL,
    gpa DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    department_id INT NOT NULL COMMENT 'Student major department',
    enrollment_year INT NOT NULL DEFAULT 2024,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_students_department 
        FOREIGN KEY (department_id) REFERENCES departments(department_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_student_gpa 
        CHECK (gpa >= 0.00 AND gpa <= 4.00)
) ENGINE=InnoDB COMMENT='Registered university students';

-- Table 4: COURSES
-- Purpose: Catalog of academic courses offered by departments and assigned instructors.
-- Foreign Keys: department_id -> departments(department_id), instructor_id -> instructors(instructor_id)
-- Constraints: UNIQUE course_code; CHECK credits > 0 and credits <= 10.
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(15) NOT NULL UNIQUE COMMENT 'Course code like INS3064, INS2011',
    course_name VARCHAR(150) NOT NULL,
    credits INT NOT NULL DEFAULT 3,
    description TEXT DEFAULT NULL,
    department_id INT NOT NULL,
    instructor_id INT DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_courses_department 
        FOREIGN KEY (department_id) REFERENCES departments(department_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_courses_instructor 
        FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_course_credits 
        CHECK (credits > 0 AND credits <= 10)
) ENGINE=InnoDB COMMENT='University course catalog';

-- Table 5: SEMESTERS
-- Purpose: Academic terms (e.g., Fall 2024, Spring 2025).
-- Constraints: UNIQUE combination of semester_name + academic_year; CHECK end_date > start_date.
CREATE TABLE semesters (
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(50) NOT NULL COMMENT 'e.g., Fall 2024, Spring 2025',
    academic_year VARCHAR(20) NOT NULL COMMENT 'e.g., 2024-2025',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_semester_term 
        UNIQUE (semester_name, academic_year),
    CONSTRAINT chk_semester_dates 
        CHECK (end_date > start_date)
) ENGINE=InnoDB COMMENT='Academic semester periods';

-- Table 6: ENROLLMENTS (Junction / Relationship Table)
-- Purpose: Many-to-Many junction linking students to courses per semester with grades.
-- Foreign Keys: student_id, course_id, semester_id
-- Constraints: Composite UNIQUE (student_id, course_id, semester_id); CHECK score 0-10; ENUM grades.
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester_id INT NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    numeric_score DECIMAL(4,2) DEFAULT NULL COMMENT 'Score on a 0.00 to 10.00 scale',
    letter_grade ENUM('A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F') DEFAULT NULL,
    status ENUM('Enrolled', 'Completed', 'Dropped', 'Withdrawn') NOT NULL DEFAULT 'Enrolled',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_enrollments_student 
        FOREIGN KEY (student_id) REFERENCES students(student_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_course 
        FOREIGN KEY (course_id) REFERENCES courses(course_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enrollments_semester 
        FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_student_course_semester 
        UNIQUE (student_id, course_id, semester_id),
    CONSTRAINT chk_numeric_score 
        CHECK (numeric_score IS NULL OR (numeric_score >= 0.00 AND numeric_score <= 10.00))
) ENGINE=InnoDB COMMENT='Student course registrations and grades per semester';

-- ============================================================================
-- INITIAL SAMPLE DATA INSERTION
-- ============================================================================

-- 1. Insert Departments (5 records)
INSERT INTO departments (department_code, department_name, building_location) VALUES
('FIT', 'Faculty of Information Technology', 'Building A - Tech Hub'),
('FBF', 'Faculty of Banking and Finance', 'Building B - Economics Wing'),
('FBA', 'Faculty of Business Administration', 'Building B - Business Center'),
('FEL', 'Faculty of English Language', 'Building C - Humanities'),
('FDS', 'Faculty of Data Science and AI', 'Building A - Innovation Lab');

-- 2. Insert Instructors (5 records - Realistic Vietnamese Names)
INSERT INTO instructors (instructor_code, first_name, last_name, email, phone, gender, hire_date, department_id) VALUES
('INS001', 'Văn Hùng', 'Nguyễn', 'hung.nguyen@univ.edu.vn', '0912345678', 'Male', '2018-09-01', 1),
('INS002', 'Thị Mai', 'Trần', 'mai.tran@univ.edu.vn', '0923456789', 'Female', '2019-02-15', 2),
('INS003', 'Hoàng Nam', 'Lê', 'nam.le@univ.edu.vn', '0934567890', 'Male', '2020-08-20', 3),
('INS004', 'Thị Thu', 'Phạm', 'thu.pham@univ.edu.vn', '0945678901', 'Female', '2021-01-10', 4),
('INS005', 'Đức Anh', 'Vũ', 'anh.vu@univ.edu.vn', '0956789012', 'Male', '2022-09-01', 5);

-- 3. Insert Students (6 records - Realistic Vietnamese Student Data)
INSERT INTO students (student_code, first_name, last_name, email, phone, gender, date_of_birth, gpa, department_id, enrollment_year) VALUES
('23070601', 'Minh Trí', 'Hoàng', 'tri.hoang23@student.univ.edu.vn', '0381112223', 'Male', '2004-05-14', 3.65, 1, 2023),
('23070602', 'Phương Thảo', 'Đỗ', 'thao.do23@student.univ.edu.vn', '0382223334', 'Female', '2004-11-20', 3.80, 2, 2023),
('23070603', 'Quốc Anh', 'Nguyễn', 'anh.nguyen23@student.univ.edu.vn', '0383334445', 'Male', '2004-03-08', 3.20, 3, 2023),
('23070604', 'Hải Yến', 'Vũ Thị', 'yen.vu23@student.univ.edu.vn', '0384445556', 'Female', '2004-09-25', 3.50, 4, 2023),
('23070605', 'Tiến Dũng', 'Bùi', 'dung.bui23@student.univ.edu.vn', '0385556667', 'Male', '2004-12-12', 3.40, 5, 2023),
('23070606', 'Khánh Linh', 'Trần', 'linh.tran23@student.univ.edu.vn', '0386667778', 'Female', '2004-07-04', 3.90, 1, 2023);

-- 4. Insert Courses (6 records)
INSERT INTO courses (course_code, course_name, credits, description, department_id, instructor_id) VALUES
('INS3064', 'Web Development', 3, 'Full-stack web development with HTML, CSS, PHP, and MySQL.', 1, 1),
('INS2011', 'Database Systems', 3, 'Relational database design, SQL querying, normalization, and indexing.', 1, 1),
('FBF2001', 'Corporate Finance', 3, 'Financial management, capital budgeting, and risk analysis.', 2, 2),
('FBA1005', 'Principles of Management', 3, 'Foundational organizational management and leadership strategies.', 3, 3),
('FEL1001', 'Academic English', 2, 'Advanced writing, critical reading, and academic presentation skills.', 4, 4),
('FDS3001', 'Applied Machine Learning', 4, 'Supervised and unsupervised learning techniques with Python.', 5, 5);

-- 5. Insert Semesters (5 records)
INSERT INTO semesters (semester_name, academic_year, start_date, end_date) VALUES
('Fall 2024', '2024-2025', '2024-09-01', '2025-01-15'),
('Spring 2025', '2024-2025', '2025-02-01', '2025-06-15'),
('Summer 2025', '2024-2025', '2025-07-01', '2025-08-25'),
('Fall 2025', '2025-2026', '2025-09-01', '2026-01-15'),
('Spring 2026', '2025-2026', '2026-02-01', '2026-06-15');

-- 6. Insert Enrollments (12 records - Various combinations & grades)
INSERT INTO enrollments (student_id, course_id, semester_id, enrollment_date, numeric_score, letter_grade, status) VALUES
(1, 1, 1, '2024-09-02', 9.20, 'A+', 'Completed'),
(1, 2, 1, '2024-09-02', 8.50, 'A',  'Completed'),
(2, 3, 1, '2024-09-03', 9.50, 'A+', 'Completed'),
(3, 4, 1, '2024-09-03', 7.80, 'B+', 'Completed'),
(4, 5, 1, '2024-09-04', 8.80, 'A',  'Completed'),
(5, 6, 1, '2024-09-04', 8.20, 'B+', 'Completed'),
(6, 1, 1, '2024-09-02', 9.80, 'A+', 'Completed'),

-- Semester 2 Enrollments (Spring 2025)
(1, 6, 2, '2025-02-02', 8.70, 'A',  'Completed'),
(2, 5, 2, '2025-02-02', 9.10, 'A+', 'Completed'),
(3, 1, 2, '2025-02-03', 7.50, 'B',  'Completed'),

-- Current / Active Semester Enrollments (Fall 2025)
(1, 4, 4, '2025-09-02', NULL, NULL, 'Enrolled'),
(6, 2, 4, '2025-09-02', NULL, NULL, 'Enrolled');

-- ============================================================================
-- VERIFICATION QUERY SAMPLES (Uncomment to execute tests)
-- ============================================================================
-- SELECT 'Departments Count' AS Test, COUNT(*) AS Total FROM departments;
-- SELECT 'Instructors Count' AS Test, COUNT(*) AS Total FROM instructors;
-- SELECT 'Students Count' AS Test, COUNT(*) AS Total FROM students;
-- SELECT 'Courses Count' AS Test, COUNT(*) AS Total FROM courses;
-- SELECT 'Semesters Count' AS Test, COUNT(*) AS Total FROM semesters;
-- SELECT 'Enrollments Count' AS Test, COUNT(*) AS Total FROM enrollments;

-- Detailed Joined View of Enrollments
-- SELECT 
--     e.enrollment_id,
--     CONCAT(s.last_name, ' ', s.first_name) AS student_name,
--     s.student_code,
--     c.course_code,
--     c.course_name,
--     sem.semester_name,
--     CONCAT(i.last_name, ' ', i.first_name) AS instructor_name,
--     e.numeric_score,
--     e.letter_grade,
--     e.status
-- FROM enrollments e
-- JOIN students s ON e.student_id = s.student_id
-- JOIN courses c ON e.course_id = c.course_id
-- JOIN semesters sem ON e.semester_id = sem.semester_id
-- LEFT JOIN instructors i ON c.instructor_id = i.instructor_id
-- ORDER BY sem.semester_id, s.student_code;
