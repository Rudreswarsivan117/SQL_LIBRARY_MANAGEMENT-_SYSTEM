

CREATE TABLE EMPLOYEES(
emp_id	VARCHAR(5) PRIMARY KEY,
emp_name VARCHAR(16),
position VARCHAR(9),	
salary	INT,
branch_id VARCHAR(5)
);    
CREATE TABLE ISSUED_STATUS (
issued_id	VARCHAR(6) PRIMARY KEY,
issued_member_id VARCHAR(6),
issued_book_name VARCHAR(54),
issued_date	DATE,
issued_book_isbn VARCHAR(17),
issued_emp_id VARCHAR(6)
);
CREATE TABLE MEMBERS (
member_id VARCHAR(6) PRIMARY KEY,
member_name VARCHAR(15),
member_address VARCHAR(15),
reg_date DATE
);
CREATE TABLE RETURN_STATUS (
return_id VARCHAR(6) PRIMARY KEY,
issued_id VARCHAR(10),
return_book_name VARCHAR(5),
return_date	DATE,
return_book_isbn VARCHAR(10)
);

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_MEMBER_ID
foreign key (issued_member_id) 
REFERENCES members(member_id)

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_ISBN
foreign key (issued_book_isbn) 
REFERENCES books(isbn)

ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_EMPLOYYE_ID
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id)

ALTER TABLE EMPLOYEES
ADD CONSTRAINT FK_BRANCH_ID
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id)

ALTER TABLE RETURN_STATUS
ADD CONSTRAINT FK_ISSUED_STATUS
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);
 SET SQL_SAFE_UPDATES=1
 
----------------------------------------------------------------------------------------------------

SELECT*FROM BOOKS
SELECT*FROM BRANCH
SELECT*FROM EMPLOYEES
SELECT*FROM ISSUED_STATUS
SELECT*FROM MEMBERS
SELECT*FROM RETURN_STATUS;

------PROJECT TASK------
--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
 INSERT INTO BOOKS(isbn,book_title, category, rental_price, status, author, publisher)
 VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co')
 
 --Task 2: Update an Existing Member's Address':
 UPDATE MEMBERS 
 SET member_address='990,ELM Street' 
 where member_id='C102'

Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM ISSUED_STATUS
WHERE ISSUED_ID ='IS121'

Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM ISSUED_STATUS
WHERE issued_emp_id='E101';

Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_emp_id as members,COUNT(issued_id) from issued_status
group by issued_emp_id
HAVING COUNT(issued_id)>1;

Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE books_summary AS
SELECT
isbn,book_title,COUNT(issued_id) 
FROM BOOKS
JOIN issued_status on books.isbn=issued_status.issued_book_isbn
GROUP BY book_title
;
select* from books_summary;

Task 7. Retrieve All Books in a Specific Category:{Category= Classic}
SELECT * FROM BOOKS
WHERE category = 'Classic'

Task 8: Find Total Rental Income by Category:
SELECT DISTINCT(category) AS Categories , SUM(rental_price) as Total_Rental_Income,COUNT(issued_id) as no_of_rents
FROM BOOKS
JOIN issued_status ON books.isbn = issued_book_isbn
GROUP BY Categories
ORDER BY Total_Rental_Income DESC;

Task 9: List Members Who Registered in the Last 8 months:
SELECT * 
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 8 month;

Task 10: List Employees with Their Branch Managers Name and their branch details:

SELECT e1.emp_id,e1.emp_name,e1.position,e1.salary,
	   branch.manager_id,e2.emp_name as manager_name
from employees as e1
join branch on e1.branch_id=branch.branch_id      
join employees as e2 on branch.manager_id=e2.emp_id;

Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE EXPENSIVE_BOOKS AS 
SELECT*FROM BOOKS
WHERE rental_price>7
ORDER BY rental_price asc;
    SELECT * FROM EXPENSIVE_BOOKS
    
 Task 12: Retrieve the List of Books Not Yet Returned

SELECT*FROM ISSUED_STATUS as i_s
LEFT JOIN return_status as r_s on i_s.issued_id=r_s.issued_id
where return_id is null  ; 

Task 13: Identify Members with Overdue Books:(30 DAYS IS RETURN PERIOD):
 WITH OVERDUE_DETAILS AS (
 SELECT ist.issued_member_id,m.member_name,b.book_title,ist.issued_date,rs.return_date,DATEDIFF(curdate(),ist.issued_date) as over_due_days
 FROM issued_status as ist 
 join members as m on ist.issued_member_id=m.member_id
 join books as b on ist.issued_book_isbn = b.isbn
 LEFT join return_status as rs on ist.issued_id=rs.issued_id
 where DATEDIFF(CURDATE(),ist.issued_date)>30 and rs.return_id is null
 order by over_due_days desc
 )
 SELECT*FROM OVERDUE_DETAILS
 
 Task 14: Branch Performance Report
 CREATE TABLE BRANCH_PERFORMANCE
SELECT 
b.branch_id,b.manager_id,e.emp_name,COUNT(ist.issued_id) as number_of_books_issued,
COUNT(rs.return_id) as number_of_books_returned,SUM(bk.rental_price) as total_revenue_per_branch
FROM 
issued_status as ist
join employees as e on ist.issued_emp_id=e.emp_id
JOIN branch as b on e.branch_id=b.branch_id
left join return_status as rs on ist.issued_id=rs.issued_id
join books as bk on ist.issued_book_isbn=bk.isbn
GROUP BY 1
order by total_revenue_per_branch desc ;
    SELECT*FROM BRANCH_PERFORMANCE;
    
Task 15: CTAS: Create a Table of Active Members :(MEMEBERS WHO ARE ISSUED WITH BOOKS FOR PAST 2 MONTHS SHOULD BE CONSIDERED AS ACTIVE MEMBERS)

CREATE TABLE ACTIVE_MEMBERS AS 
SELECT *FROM members
WHERE member_id IN (SELECT DISTINCT(issued_member_id)
			      FROM issued_status
				  where issued_date>= CURDATE()-INTERVAL 13 MONTH)
SELECT*FROM ACTIVE_MEMBERS                  

Task 16: Find Employees with the Most Book Issued Processed
SELECT e.emp_id,
e.emp_name,e.position,
b.*,COUNT(ist.issued_id) as no_of_books_issued
FROM issued_status as ist
JOIN employees as e on ist.issued_emp_id = e.emp_id
JOIN branch as b on e.branch_id = b.branch_id
GROUP BY e.emp_id

 Task 18: Identify Members Issuing High-Risk Books:
 
 SELECT emp_id,e.emp_name,bk.book_title,COUNT(ist.issued_id) as no_of_damaged_bk_issued
 from issued_status as ist
 join employees as e on ist.issued_emp_id=e.emp_id
 join books as bk on ist.issued_book_isbn=bk.isbn
 WHERE bk.status = 'no'
 GROUP BY e.emp_id
 HAVING COUNT(ist.issued_id) >= 1;


