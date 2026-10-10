-- ============================================================================
-- FILE    : university_queries.sql
-- NAME    : Hoang Thu Hang
-- STUDENT : 23070601
-- COURSE  : INS3064 — Web Development
-- ASSIGN  : Homework 05 — SQL Queries
-- DATE    : October 2026
-- DESC    : 10 SQL queries against the university_db database created in
--           Homework 04.  Topics covered: basic SELECT, WHERE (comparison,
--           AND/OR), ORDER BY, LIMIT, LIKE, aggregate (COUNT/SUM), GROUP BY
--           with HAVING, two-table JOIN, and multi-table JOIN.
-- ============================================================================

USE university_db;

-- ============================================================================
-- Query 1: Basic SELECT — All Students
-- ============================================================================
/*
 * Query 1: All Students
 * Description: Retrieves every column from the students table to get a
 *              complete overview of all enrolled students in the university.
 * Expected Output: 6 rows, one per student, showing all 12 columns.
 */
SELECT *
FROM students;
/*
 * +------------+--------------+-------------+----------+----------------------------------------+-----------+--------+--------------+------+---------------+-----------------+---------------------+
 * | student_id | student_code | first_name  | last_name| email                                  | phone      | gender | date_of_birth| gpa  | department_id | enrollment_year | created_at          |
 * +------------+--------------+-------------+----------+----------------------------------------+-----------+--------+--------------+------+---------------+-----------------+---------------------+
 * |          1 | 23070601     | Minh Trí    | Hoàng    | tri.hoang23@student.univ.edu.vn        | 0381112223 | Male   | 2004-05-14   | 3.65 |             1 |            2023 | 2026-10-10 ...      |
 * |          2 | 23070602     | Phương Thảo | Đỗ       | thao.do23@student.univ.edu.vn          | 0382223334 | Female | 2004-11-20   | 3.80 |             2 |            2023 | 2026-10-10 ...      |
 * |          3 | 23070603     | Quốc Anh    | Nguyễn   | anh.nguyen23@student.univ.edu.vn       | 0383334445 | Male   | 2004-03-08   | 3.20 |             3 |            2023 | 2026-10-10 ...      |
 * |          4 | 23070604     | Hải Yến     | Vũ Thị   | yen.vu23@student.univ.edu.vn           | 0384445556 | Female | 2004-09-25   | 3.50 |             4 |            2023 | 2026-10-10 ...      |
 * |          5 | 23070605     | Tiến Dũng   | Bùi      | dung.bui23@student.univ.edu.vn         | 0385556667 | Male   | 2004-12-12   | 3.40 |             5 |            2023 | 2026-10-10 ...      |
 * |          6 | 23070606     | Khánh Linh  | Trần     | linh.tran23@student.univ.edu.vn        | 0386667778 | Female | 2004-07-04   | 3.90 |             1 |            2023 | 2026-10-10 ...      |
 * +------------+--------------+-------------+----------+----------------------------------------+-----------+--------+--------------+------+---------------+-----------------+---------------------+
 * (6 rows)
 */


-- ============================================================================
-- Query 2: WHERE with Comparison — High-GPA Students
-- ============================================================================
/*
 * Query 2: High-GPA Students (GPA > 3.5)
 * Description: Filters the students table to return only students whose GPA
 *              is strictly above 3.50, identifying academically strong
 *              performers.
 * Expected Output: 3 rows — Minh Trí (3.65), Phương Thảo (3.80), and
 *                  Khánh Linh (3.90).
 */
SELECT
    student_id,
    student_code,
    CONCAT(last_name, ' ', first_name) AS full_name,
    gpa
FROM students
WHERE gpa > 3.50;
/*
 * +------------+--------------+------------------------------+------+
 * | student_id | student_code | full_name                    | gpa  |
 * +------------+--------------+------------------------------+------+
 * |          1 | 23070601     | Hoàng Minh Trí               | 3.65 |
 * |          2 | 23070602     | Đỗ Phương Thảo               | 3.80 |
 * |          6 | 23070606     | Trần Khánh Linh              | 3.90 |
 * +------------+--------------+------------------------------+------+
 * (3 rows)
 */


-- ============================================================================
-- Query 3: WHERE with AND/OR — IT Department Courses with Credits Filter
-- ============================================================================
/*
 * Query 3: FIT Courses with 3 or More Credits
 * Description: Retrieves courses that belong to the Faculty of Information
 *              Technology (department_id = 1) AND have at least 3 credits,
 *              OR any course that has more than 3 credits regardless of
 *              department.  This demonstrates combining AND / OR conditions.
 * Expected Output: INS3064, INS2011 (FIT, 3 credits each) and FDS3001
 *                  (4 credits).
 */
SELECT
    course_id,
    course_code,
    course_name,
    credits,
    department_id
FROM courses
WHERE (department_id = 1 AND credits >= 3)
   OR credits > 3;
/*
 * +-----------+-------------+------------------------+---------+---------------+
 * | course_id | course_code | course_name            | credits | department_id |
 * +-----------+-------------+------------------------+---------+---------------+
 * |         1 | INS3064     | Web Development        |       3 |             1 |
 * |         2 | INS2011     | Database Systems       |       3 |             1 |
 * |         6 | FDS3001     | Applied Machine Learning|      4 |             5 |
 * +-----------+-------------+------------------------+---------+---------------+
 * (3 rows)
 */


-- ============================================================================
-- Query 4: ORDER BY — Students Sorted by Last Name then First Name
-- ============================================================================
/*
 * Query 4: Students Ordered by Last Name Ascending
 * Description: Retrieves student names and GPAs, sorted alphabetically by
 *              last_name ascending, then by first_name ascending as a
 *              tiebreaker — useful for generating class rosters.
 * Expected Output: 6 rows sorted by last name A→Z.
 */
SELECT
    student_code,
    last_name,
    first_name,
    gender,
    gpa
FROM students
ORDER BY last_name ASC, first_name ASC;
/*
 * +--------------+----------+-------------+--------+------+
 * | student_code | last_name| first_name  | gender | gpa  |
 * +--------------+----------+-------------+--------+------+
 * | 23070605     | Bùi      | Tiến Dũng   | Male   | 3.40 |
 * | 23070602     | Đỗ       | Phương Thảo | Female | 3.80 |
 * | 23070601     | Hoàng    | Minh Trí    | Male   | 3.65 |
 * | 23070603     | Nguyễn   | Quốc Anh    | Male   | 3.20 |
 * | 23070606     | Trần     | Khánh Linh  | Female | 3.90 |
 * | 23070604     | Vũ Thị   | Hải Yến     | Female | 3.50 |
 * +--------------+----------+-------------+--------+------+
 * (6 rows)
 */


-- ============================================================================
-- Query 5: LIMIT — Top 3 Highest-Scored Completed Enrollments
-- ============================================================================
/*
 * Query 5: Top 3 Highest-Scored Enrollments
 * Description: Retrieves the three enrollments with the highest numeric_score
 *              among completed records.  Uses ORDER BY DESC combined with
 *              LIMIT to surface top performers.
 * Expected Output: enrollment_ids 7 (9.80), 3 (9.50), 1 (9.20).
 */
SELECT
    enrollment_id,
    student_id,
    course_id,
    numeric_score,
    letter_grade,
    status
FROM enrollments
WHERE status = 'Completed'
ORDER BY numeric_score DESC
LIMIT 3;
/*
 * +---------------+------------+-----------+---------------+--------------+-----------+
 * | enrollment_id | student_id | course_id | numeric_score | letter_grade | status    |
 * +---------------+------------+-----------+---------------+--------------+-----------+
 * |             7 |          6 |         1 |          9.80 | A+           | Completed |
 * |             3 |          2 |         3 |          9.50 | A+           | Completed |
 * |             1 |          1 |         1 |          9.20 | A+           | Completed |
 * +---------------+------------+-----------+---------------+--------------+-----------+
 * (3 rows)
 */


-- ============================================================================
-- Query 6: LIKE — Instructors Whose Last Name Starts with 'Ng'
-- ============================================================================
/*
 * Query 6: Instructors with Last Name Starting with 'Ng'
 * Description: Searches the instructors table using a LIKE pattern to find
 *              all instructors whose last_name begins with the prefix 'Ng' —
 *              a common Vietnamese surname pattern (Nguyễn, Ngô, Nghiêm…).
 * Expected Output: 1 row — Nguyễn Văn Hùng.
 */
SELECT
    instructor_id,
    instructor_code,
    CONCAT(last_name, ' ', first_name) AS instructor_name,
    email,
    gender
FROM instructors
WHERE last_name LIKE 'Ng%';
/*
 * +---------------+-----------------+---------------------+---------------------------+--------+
 * | instructor_id | instructor_code | instructor_name     | email                     | gender |
 * +---------------+-----------------+---------------------+---------------------------+--------+
 * |             1 | INS001          | Nguyễn Văn Hùng     | hung.nguyen@univ.edu.vn   | Male   |
 * +---------------+-----------------+---------------------+---------------------------+--------+
 * (1 row)
 */


-- ============================================================================
-- Query 7: Aggregate — COUNT per Department and SUM of Credits per Department
-- ============================================================================
/*
 * Query 7: Course Count and Total Credits per Department
 * Description: Uses COUNT() to tally how many courses each department offers
 *              and SUM() to compute the total credit load, grouped by
 *              department.  Gives a quick snapshot of department course loads.
 * Expected Output: 5 rows, one per department, showing course count and
 *                  total credits.
 */
SELECT
    d.department_code,
    d.department_name,
    COUNT(c.course_id)  AS total_courses,
    SUM(c.credits)      AS total_credits
FROM departments d
LEFT JOIN courses c ON d.department_id = c.department_id
GROUP BY d.department_id, d.department_code, d.department_name
ORDER BY total_courses DESC;
/*
 * +-----------------+-------------------------------------+---------------+---------------+
 * | department_code | department_name                     | total_courses | total_credits |
 * +-----------------+-------------------------------------+---------------+---------------+
 * | FIT             | Faculty of Information Technology   |             2 |             6 |
 * | FBF             | Faculty of Banking and Finance      |             1 |             3 |
 * | FBA             | Faculty of Business Administration  |             1 |             3 |
 * | FEL             | Faculty of English Language         |             1 |             2 |
 * | FDS             | Faculty of Data Science and AI      |             1 |             4 |
 * +-----------------+-------------------------------------+---------------+---------------+
 * (5 rows)
 */


-- ============================================================================
-- Query 8: Aggregate with GROUP BY + HAVING — Students Enrolled in 2+ Courses
-- ============================================================================
/*
 * Query 8: Students with 2 or More Enrollments
 * Description: Groups enrollments by student, counts how many courses each
 *              student is enrolled in across all semesters, then uses HAVING
 *              to keep only students with 2 or more enrollments.
 * Expected Output: 3 rows — students 1 (3 enrollments), 2 (2 enrollments),
 *                  and 6 (2 enrollments).
 */
SELECT
    s.student_code,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name,
    COUNT(e.enrollment_id) AS enrollment_count
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_code, s.last_name, s.first_name
HAVING enrollment_count >= 2
ORDER BY enrollment_count DESC;
/*
 * +--------------+---------------------+------------------+
 * | student_code | student_name        | enrollment_count |
 * +--------------+---------------------+------------------+
 * | 23070601     | Hoàng Minh Trí      |                3 |
 * | 23070602     | Đỗ Phương Thảo      |                2 |
 * | 23070606     | Trần Khánh Linh     |                2 |
 * +--------------+---------------------+------------------+
 * (3 rows)
 */


-- ============================================================================
-- Query 9: JOIN Two Tables — Courses with Instructor Names
-- ============================================================================
/*
 * Query 9: Courses with Instructor Names
 * Description: Joins the courses table with the instructors table on
 *              instructor_id to display each course's code and name alongside
 *              the full name of the assigned instructor.  Uses LEFT JOIN so
 *              courses without an assigned instructor still appear.
 * Expected Output: 6 rows, one per course, with instructor name shown.
 */
SELECT
    c.course_code,
    c.course_name                              AS course_title,
    c.credits,
    CONCAT(i.last_name, ' ', i.first_name)    AS instructor_name
FROM courses c
LEFT JOIN instructors i ON c.instructor_id = i.instructor_id
ORDER BY c.course_code;
/*
 * +-------------+---------------------------+---------+-------------------+
 * | course_code | course_title              | credits | instructor_name   |
 * +-------------+---------------------------+---------+-------------------+
 * | FBA1005     | Principles of Management  |       3 | Lê Hoàng Nam      |
 * | FBF2001     | Corporate Finance         |       3 | Trần Thị Mai      |
 * | FDS3001     | Applied Machine Learning  |       4 | Vũ Đức Anh        |
 * | FEL1001     | Academic English          |       2 | Phạm Thị Thu      |
 * | INS2011     | Database Systems          |       3 | Nguyễn Văn Hùng   |
 * | INS3064     | Web Development           |       3 | Nguyễn Văn Hùng   |
 * +-------------+---------------------------+---------+-------------------+
 * (6 rows)
 */


-- ============================================================================
-- Query 10: JOIN Three Tables — Full Enrollment Report
-- ============================================================================
/*
 * Query 10: Full Enrollment Report (Student + Course + Semester + Grade)
 * Description: Joins four tables — enrollments, students, courses, and
 *              semesters — to produce a comprehensive report showing the
 *              student name, course title, semester, numeric score, letter
 *              grade, and enrollment status for every registration record.
 *              This is the most complex query in the file and mirrors a
 *              real-world academic transcript view.
 * Expected Output: 12 rows covering all enrollment records across semesters.
 */
SELECT
    e.enrollment_id                             AS enroll_id,
    CONCAT(s.last_name, ' ', s.first_name)      AS student_name,
    s.student_code,
    c.course_code,
    c.course_name                               AS course_title,
    sem.semester_name,
    sem.academic_year,
    e.numeric_score                             AS score,
    e.letter_grade                              AS grade,
    e.status
FROM enrollments e
JOIN students  s   ON e.student_id  = s.student_id
JOIN courses   c   ON e.course_id   = c.course_id
JOIN semesters sem ON e.semester_id = sem.semester_id
ORDER BY sem.semester_id, s.student_code;
/*
 * +-----------+---------------------+--------------+-------------+---------------------------+-------------+-------------+-------+-------+-----------+
 * | enroll_id | student_name        | student_code | course_code | course_title              | semester    | acad_year   | score | grade | status    |
 * +-----------+---------------------+--------------+-------------+---------------------------+-------------+-------------+-------+-------+-----------+
 * |         1 | Hoàng Minh Trí      | 23070601     | INS3064     | Web Development           | Fall 2024   | 2024-2025   |  9.20 | A+    | Completed |
 * |         2 | Hoàng Minh Trí      | 23070601     | INS2011     | Database Systems          | Fall 2024   | 2024-2025   |  8.50 | A     | Completed |
 * |         3 | Đỗ Phương Thảo      | 23070602     | FBF2001     | Corporate Finance         | Fall 2024   | 2024-2025   |  9.50 | A+    | Completed |
 * |         4 | Nguyễn Quốc Anh     | 23070603     | FBA1005     | Principles of Management  | Fall 2024   | 2024-2025   |  7.80 | B+    | Completed |
 * |         5 | Vũ Thị Hải Yến      | 23070604     | FEL1001     | Academic English          | Fall 2024   | 2024-2025   |  8.80 | A     | Completed |
 * |         6 | Bùi Tiến Dũng       | 23070605     | FDS3001     | Applied Machine Learning  | Fall 2024   | 2024-2025   |  8.20 | B+    | Completed |
 * |         7 | Trần Khánh Linh     | 23070606     | INS3064     | Web Development           | Fall 2024   | 2024-2025   |  9.80 | A+    | Completed |
 * |         8 | Hoàng Minh Trí      | 23070601     | FDS3001     | Applied Machine Learning  | Spring 2025 | 2024-2025   |  8.70 | A     | Completed |
 * |         9 | Đỗ Phương Thảo      | 23070602     | FEL1001     | Academic English          | Spring 2025 | 2024-2025   |  9.10 | A+    | Completed |
 * |        10 | Nguyễn Quốc Anh     | 23070603     | INS3064     | Web Development           | Spring 2025 | 2024-2025   |  7.50 | B     | Completed |
 * |        11 | Hoàng Minh Trí      | 23070601     | FBA1005     | Principles of Management  | Fall 2025   | 2025-2026   |  NULL | NULL  | Enrolled  |
 * |        12 | Trần Khánh Linh     | 23070606     | INS2011     | Database Systems          | Fall 2025   | 2025-2026   |  NULL | NULL  | Enrolled  |
 * +-----------+---------------------+--------------+-------------+---------------------------+-------------+-------------+-------+-------+-----------+
 * (12 rows)
 */
