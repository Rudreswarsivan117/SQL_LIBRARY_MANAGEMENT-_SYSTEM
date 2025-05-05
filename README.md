 # LIBRARY MANAGEMENT SYSTEM PROJECT

 ## PROJECT OVERVIEW:
 **Project Title:** Library Management System    
 **Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

 ## Project Structure

 ### 1. Database Setup
 
```sql

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
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1: Create a New Book record.**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```
Task 13: **Identify Members with Overdue Books:(30 DAYS IS RETURN PERIOD):**
```sql
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
```
Task 14: **Branch Performance Report:**
```sql
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
```    
Task 15: **CTAS: Create a Table of Active Members :(MEMEBERS WHO ARE ISSUED WITH BOOKS FOR PAST 2 MONTHS SHOULD BE CONSIDERED AS ACTIVE MEMBERS):**
```sql
CREATE TABLE ACTIVE_MEMBERS AS 
SELECT *FROM members
WHERE member_id IN (SELECT DISTINCT(issued_member_id)
			      FROM issued_status
				  where issued_date>= CURDATE()-INTERVAL 13 MONTH)
SELECT*FROM ACTIVE_MEMBERS                  
```
Task 16: **Find Employees with the Most Book Issued Processed:**
```sql
SELECT e.emp_id,
e.emp_name,e.position,
b.*,COUNT(ist.issued_id) as no_of_books_issued
FROM issued_status as ist
JOIN employees as e on ist.issued_emp_id = e.emp_id
JOIN branch as b on e.branch_id = b.branch_id
GROUP BY e.emp_id
```
 Task 18: **Identify Members Issuing High-Risk Books:**
 ```sql
 SELECT emp_id,e.emp_name,bk.book_title,COUNT(ist.issued_id) as no_of_damaged_bk_issued
 from issued_status as ist
 join employees as e on ist.issued_emp_id=e.emp_id
 join books as bk on ist.issued_book_isbn=bk.isbn
 WHERE bk.status = 'no'
 GROUP BY e.emp_id
 HAVING COUNT(ist.issued_id) >= 1;
```
## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.






