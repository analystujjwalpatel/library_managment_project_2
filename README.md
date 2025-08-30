# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. Set up the Library Management System Database: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.  
2. CRUD Operations: Perform Create, Read, Update, and Delete operations on the data.  
3. CTAS (Create Table As Select): Utilize CTAS to create new tables based on query results.  
4. Advanced SQL Queries: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- Database Creation: Created a database named `library_db`.  
- Table Creation: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(30),
    reg_date DATE
);

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);

-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

### 2. CRUD Operations

- Create: Inserted sample records into the `books` table.  
- Read: Retrieved and displayed data from various tables.  
- Update: Updated records in the `employees` table.  
- Delete: Removed records from the `members` table as needed.

```sql
select * from books;
select * from public.branch;
select * from public.employees;
select * from public.issued_status;
select * from public.members;
select * from public.return_status;
```

-- Now, guys we solve the tasks for this dataset.

Task 1. Create a New Book Record

```sql
-- Insert new book
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

Task 2: Update an Existing Member's Address

```sql
select * from public.members;

update public.members
set member_address = '355 walnut st'
where member_id = 'C107';
```

Task 3: Delete a Record from the Issued Status Table

```sql
select * from public.issued_status;

delete from public.issued_status
where issued_id = 'IS121';
```

Task 4: Retrieve All Books Issued by a Specific Employee

```sql
select * from public.issued_status
where issued_emp_id = 'E101';
```

Task 5: List Members Who Have Issued More Than One Book

```sql
select * from public.issued_status;

select
    issued_emp_id,
    count(issued_book_name) as total_books_issued
from public.issued_status
group by issued_emp_id
having count(issued_book_name) > 1;
```

CTAS (Create Table As Select)

Task 6: Create Summary Tables

```sql
create table book_count as
select 
    b.isbn,
    b.book_title,
    count(ist.issued_id) as no_of_issued
from books as b
join issued_status as ist
    ON ist.issued_book_isbn = b.isbn
group by 1,2;

select * from public.book_count;
```

4. Data Analysis & Findings

Task 4. Retrieve All Books in a Specific Category:

```sql
select * from books
where category = 'Classic';
```

Task 5: Find Total Rental Income by Category:

```sql
select 
    b.category,
    sum(b.rental_price)
from books as b
join issued_status as ist
    ON ist.issued_book_isbn = b.isbn
group by 1;
```

Task 6: List Members Who Registered in the Last 180 Days:

```sql
-- Insert new sample members for testing:
INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES 
('C120', 'Maya Singh', '777 Rose St', '2025-03-15'),
('C121', 'Ravi Verma', '888 Lotus St', '2025-04-20'),
('C122', 'Sneha Patel', '999 Lily St', '2025-05-10'),
('C123', 'Ankit Shah', '111 Tulip St', '2025-06-25'),
('C124', 'Neha Gupta', '222 Jasmine St', '2025-07-15');

select * from public.members
where reg_date >= current_date - INTERVAL '180 day';
```

Task 7: List Employees with Their Branch Manager's Name and Branch Details

```sql
select * from public.employees;
select * from public.branch;

select 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
from public.branch as b
join employees as e1
    on b.branch_id = e1.branch_id
join employees as e2
    on b.manager_id = e2.emp_id;
```

Task 8: Create a Table of Books with Rental Price Above a Certain Threshold (7.00 USD)

```sql
select * from books;

create table expensive_books as
select * from books
where rental_price > 7.00;

select * from expensive_books;
```

Task 9: Retrieve the List of Books Not Yet Returned

```sql
select * from public.issued_status;
select * from public.return_status;

select
    distinct ist.issued_book_name,
    ist.issued_id
from public.issued_status as ist
left join return_status as rs
    on ist.issued_id = rs.issued_id
where rs.return_id is null;
```

## Advanced SQL Operations

Task 1: Identify Members with Overdue Books

Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's id, member's name, book title, issue date, and days overdue.

```sql
select * from books;
select * from public.issued_status;
select * from public.members;
select * from public.return_status;

select 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    rs.return_date,
    current_date - ist.issued_date as overdue_days
from public.issued_status as ist
join members as m
    on m.member_id = ist.issued_member_id
join books as bk
    on bk.isbn = ist.issued_book_isbn
left join public.return_status as rs
    on rs.issued_id = ist.issued_id
where rs.return_date is null
  and (current_date - ist.issued_date) > 30;
```

Task 2: Update Book Status on Return

Write a query to update the status of books in the books table to "yes" when they are returned (based on entries in the return_status table).

```sql
select * from public.issued_status
where issued_book_isbn = '978-0-307-37840-1';

select * from books
where isbn = '978-0-307-37840-1';

update public.books
set status = 'yes'
where isbn = '978-0-307-37840-1';

select * from public.return_status
where issued_id = 'IS110';

select * from public.book_count;
```

Stored procedure: add_return_records

```sql
CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id VARCHAR(10),
    p_issued_id VARCHAR(10),
    p_book_quality VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
    INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;
```

Testing procedure and related selects:

```sql
-- Testing FUNCTION add_return_records
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

CALL add_return_records('RS138', 'IS135', 'Good');
CALL add_return_records('RS148', 'IS140', 'Good');
```

Task 3: Branch Performance Report

```sql
select * from public.branch;
select * from public.issued_status;
select * from public.employees;
select * from books;
select * from public.return_status;

create table branch_reports as
select 
    b.branch_id,
    b.manager_id,
    count(ist.issued_id) as no_of_book_issued,
    count(rs.return_id) as no_od_book_returned,
    sum(bk.rental_price) as total_revenue_generated 
from public.issued_status as ist
join employees as e
    on ist.issued_emp_id = e.emp_id
join branch as b
    on e.branch_id = b.branch_id
left join public.return_status as rs
    on ist.issued_id = rs.issued_id
join books as bk
    on ist.issued_book_name = bk.book_title
group by 1, 2;

select * from public.branch_reports;
SELECT * FROM branch_reports;
```

Task 4: CTAS: Create a Table of Active Members

```sql
create table active_member as
select * from public.members
where member_id in (
    select issued_member_id
    from public.issued_status
    where issued_date >= current_date - interval '16 months'
);

select * from public.active_member;
```

Task 5: Find Employees with the Most Book Issues Processed

```sql
select * from public.employees;
select * from public.issued_status;

SELECT 
    e.emp_name,
    e.branch_id,
    COUNT(ist.issued_id) AS no_book_issued
FROM public.issued_status AS ist
JOIN public.employees AS e
    ON ist.issued_emp_id = e.emp_id
GROUP BY 1, 2
ORDER BY no_book_issued DESC
LIMIT 3;
```

Task 6: Stored Procedure to Issue a Book

```sql
select * from public.books;
select * from public.issued_status;

CREATE OR REPLACE PROCEDURE issue_book(
    p_issued_id          VARCHAR(30),
    p_issued_member_id   VARCHAR(30),
    p_issued_book_isbn   VARCHAR(50),
    p_issued_emp_id      VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(10);
BEGIN
    -- Get current status of the book (lock row to avoid race if you want)
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn
    FOR UPDATE;   -- optional but recommended to prevent concurrent issues

    IF v_status IS NULL THEN
        -- ISBN not found
        RAISE NOTICE 'Book with isbn % not found', p_issued_book_isbn;
    ELSIF v_status = 'yes' THEN
        -- Insert issued record
        INSERT INTO issued_status (
            issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id
        ) VALUES (
            p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id
        );

        -- Update book status to not available
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book record added successfully for book isbn: %', p_issued_book_isbn;
    ELSE
        -- status is 'no' or other value
        RAISE NOTICE 'Sorry, the book you requested is currently not available. Book isbn: %', p_issued_book_isbn;
    END IF;
END;
$$;

-- testing procedure
select * from public.books
where isbn = '978-0-141-44171-6';

call issue_book('IS189', 'C109', '978-0-553-29698-2', 'E105');
```

## Reports

- Database Schema: Detailed table structures and relationships.  
- Data Analysis: Insights into book categories, employee salaries, member registration trends, and issued books.  
- Summary Reports: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. Clone the Repository:
```sh
git clone https://github.com/najirh/Library-System-Management---P2.git
```

2. Set Up the Database: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.  
3. Run the Queries: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.  
4. Explore and Modify: Customize the queries as needed to explore different aspects of the data or answer additional questions.

---

This README is formatted for clear GitHub preview with syntax highlighting. I preserved all your SQL code exactly as you provided — only reorganized and wrapped it in appropriate fenced code blocks and cleaned up headings and spacing. If you want, I can also:

- Add a table of contents.
- Add badges (Postgres, SQL, License).
- Produce a short one-page project summary (200–300 words) for the repo homepage.

Which of those would you like next?
