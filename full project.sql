select * from books
select * from public.branch
select * from public.employees
select * from public.issued_status
select * from public.members
select * from public.return_status


-- now guies we solve the task of these dataset.

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a
-- Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

select * from books

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) 
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

select * from public.members

update public.members
set member_address = '355 walnut st'
where member_id = 'C107';


-- Task 3: Delete a Record from the Issued Status Table -- Objective: 
-- Delete the record with issued_id = 'IS121' from the issued_status table.

select * from public.issued_status

delete from public.issued_status
where issued_id = 'IS121'

--  for check record is delete or not from table ,
-- select * from public.issued_status
-- where issued_id = 'IS121'


-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: 
-- Select all books issued by the employee with emp_id = 'E101'.

select * from public.issued_status
where issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.


select * from public.issued_status

select
issued_emp_id,
count(issued_book_name) total_books_issued
from public.issued_status
group by issued_emp_id
having count(issued_book_name) > 1

-- CTAS (Create Table As Select)

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based 
-- on query results - each book and total book_issued_cnt**

create table book_count
as
select 
b.isbn, -- (b matlab books wala table me se isbn , book title hi chaiye)
b.book_title,
count(ist.issued_id) as no_of_issued  --(count kar do ist.issued_id iska as no_of_issued )
from books as b
join issued_status as ist
ON ist.issued_book_isbn = b.isbn -- (humne yaha inner jion lagaya hai right join humne do table isued status aur books ko jodne ke liye lagaya hai )
group by 1,2; -- (1-isbn , 2- book_title)


select * from public.book_count


-- 4. Data Analysis & Findings
-- The following SQL queries were used to address specific questions:

-- Task 4. Retrieve All Books in a Specific Category:

select * from books
where category = 'Classic'

-- Task 5: Find Total Rental Income by Category:

select 
b.category,
sum(b.rental_price)
from books as b
join issued_status as ist
ON ist.issued_book_isbn = b.isbn -- (humne yaha inner jion lagaya hai right join humne do table isued status aur books ko jodne ke liye lagaya hai )
group by 1; 


-- Task 6: List Members Who Registered in the Last 180 Days:

-- Insert new sample members for testing:

select * from public.members

-- Insert new sample members for testing:
INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES 
('C120', 'Maya Singh', '777 Rose St', '2025-03-15'),
('C121', 'Ravi Verma', '888 Lotus St', '2025-04-20'),
('C122', 'Sneha Patel', '999 Lily St', '2025-05-10'),
('C123', 'Ankit Shah', '111 Tulip St', '2025-06-25'),
('C124', 'Neha Gupta', '222 Jasmine St', '2025-07-15');

select * from public.members
where
reg_date >= current_date - INTERVAL '180 day';


-- task 7 - List Employees with Their Branch Manager's Name and their 
-- branch details:

select * from public.employees
select * from public.branch

-- using inner join we add two tables here
select 
      e1.*,
	  b.manager_id,
	  e2.emp_name as manager
from public.branch as b
join 
employees as e1
on b.branch_id = e1.branch_id
-- hum yaha ek baar phir join laag rahe hain...
join 
employees as e2
on b.manager_id = e2.emp_id

--Task 8.Create a Table of Books with Rental Price Above a Certain Threshold 7usd:
select * from books

create table expensive_books as
select * from books
where rental_price > 7.00;

select * from expensive_books


-- task 9 Retrieve the List of Books Not Yet Returned
select * from public.issued_status
select * from public.return_status

select
       distinct ist.issued_book_name,
	   ist.issued_id
	   
from public.issued_status as ist
left join 
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null



-- now we solve some advance sql query 

/* task 1: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- we need four table for this query and make join on this, 
-- members = books = issued_status = return_status
-- then filter books which is return
-- overdue > 30 days

select * from books
select * from public.issued_status
select * from public.members
select * from public.return_status

select 
     ist.issued_member_id,
	 m.member_name,
	 bk.book_title,
	 ist.issued_date,
	 rs.return_date,
	 current_date - ist.issued_date as overdue_days
from public.issued_status as ist
join 
members as m
on 
m.member_id = ist.issued_member_id
join
books as bk
on
bk.isbn = ist.issued_book_isbn
left join
public.return_status as rs
on
rs.issued_id = ist.issued_id
where rs.return_date is null
and
 (current_date - ist.issued_date) > 30 

/* Task 02: Update Book Status on Return
 
Write a query to update the status of books in the books table to "Yes"
when they are returned (based on entries in the return_status table).
*/

select * from public.issued_status
where issued_book_isbn = '978-0-307-37840-1'

select * from books
where isbn = '978-0-307-37840-1'

update public.books
set status = 'yes'
where isbn = '978-0-307-37840-1'

select * from public.return_status
where issued_id = 'IS110'

select * from public.book_count

-- store procedure



CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

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
$$


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');


/* Task 03: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals. */

select * from public.branch
select * from public.issued_status
select * from public.employees
select * from books
select * from public.return_status

create table branch_reports as
select 
       b.branch_id,
	   b.manager_id,
	 count(ist.issued_id) as no_of_book_issued,
	 	 count(rs.return_id) as no_od_book_returned,
      sum(bk.rental_price) as total_revenue_generated 
from public.issued_status as ist
join
employees as e
on
ist.issued_emp_id = e.emp_id
join
branch as b
on
e.branch_id = b.branch_id
left join
public.return_status as rs
on 
ist.issued_id = rs.issued_id
join
books as bk
on
ist.issued_book_name = bk.book_title
group by 1, 2

select * from public.branch_reports

/* -- Task 04: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 16 months. */

create table active_member 
  as
select * from public.members

where member_id in (select 
       issued_member_id
from public.issued_status
where 
      issued_date >= current_date - interval '16 months'
)

select * from public.active_member


/* Task 05: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch. */


select * from public.employees
select * from public.issued_status

SELECT 
    e.emp_name,
    e.branch_id,
    COUNT(ist.issued_id) AS no_book_issued
FROM 
    public.issued_status AS ist
JOIN 
    public.employees AS e
ON 
    ist.issued_emp_id = e.emp_id
GROUP BY 
    1, 2
ORDER BY 
    no_book_issued DESC
LIMIT 3;

/* Task 06: Stored Procedure Objective:

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the 
library based on its issuance. The procedure should function as follows: The stored procedure should
take the book_id as an input parameter. The procedure should first check if the 
book is available (status = 'yes'). If the book is available, it should be issued, and the status 
in the books table should be updated to 'no'. If the book is not available (status = 'no'), the 
procedure should return an error message indicating that the book is currently not available. */

select * from public.books
select * from public.issued_status

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
        -- Insert issued record (note correct order of values)
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

-- testing function

select * from public.books
where isbn = '978-0-141-44171-6'
-- "978-0-553-29698-2" currently yes
-- "978-0-7432-7357-1"  currently no

select * from public.issued_status
where issued_book_isbn = '978-0-141-44171-6'

call issue_book('IS189', 'C109', '978-0-553-29698-2', 'E105')