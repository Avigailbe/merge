--****************************************CURSOR***************************************

--1. print all db names that are 6 chars long:
use master
go

Declare @str varchar(20)
Declare Mycursor cursor
for select name from sys.databases where LEN(name) = 6
open Mycursor
Fetch next from Mycursor into @str
while @@FETCH_STATUS=0
begin 
Print @str
Fetch next from Mycursor into @str
end 
close Mycursor
Deallocate Mycursor

go

--2. show product names and prices ordered by dearest to cheapest
use northwind
go

Declare @name varchar(20), @price int
Declare Mycursor cursor
for select ProductName, UnitPrice from Products order by UnitPrice desc
open Mycursor
Fetch next from Mycursor into @name, @price
while @@FETCH_STATUS=0
begin 
Print 'Product Name:'+@name+', Price:'+cast(@price as char(10))
Fetch next from Mycursor into @name, @price
end 
close Mycursor
Deallocate Mycursor

go

--3. show contact name from customers table in 2 columns by their space between

use northwind
go

Declare @Name varchar(20), @FirstName varchar(20), @LastName varchar(20)
Declare Mycursor cursor
for select ContactName from Customers
open Mycursor
Fetch next from Mycursor into @Name
while @@FETCH_STATUS=0
begin 
set @FirstName = left(@Name, charindex(' ', @Name) - 1)
set @LastName =  SUBSTRING(@Name, CHARINDEX(' ', @Name) +1, DATALENGTH(@Name) - CHARINDEX(' ', @Name) +1 )
Print 'First Name:'+@FirstName+', Last Name:'+@LastName + ',    original: '+@Name
Fetch next from Mycursor into @name
end 
close Mycursor
Deallocate Mycursor

go


--4. create new table as Products.
-- insert just productname, productid column data
-- insert prices where price*1.1 more than original
CREATE TABLE [dbo].[ProductsHighPrice](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](40) NULL,
	[SupplierID] [int] NULL,
	[CategoryID] [int] NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NULL
	)

--first insert key
SET IDENTITY_INSERT [ProductsHighPrice] off
INSERT INTO [ProductsHighPrice] ([ProductID])
SELECT [ProductID] FROM [Products]

--insert with cursor product name from original table
Declare @productname varchar(20), @ProductID int
Declare Mycursor cursor
for select  p.ProductName, p.ProductID from Products p, ProductsHighPrice php where p.ProductID = php.ProductID
open Mycursor
Fetch next from Mycursor into @productname, @ProductID
while @@FETCH_STATUS=0
begin 
Update ProductsHighPrice 
        Set ProductName=@productname 
        where ProductsHighPrice.ProductID=@ProductID
Fetch next from Mycursor into @productname, @ProductID
end 
close Mycursor
Deallocate Mycursor

go

--update unitPrice to be 10% more expensive than products table
Declare @ProductID int, @unitPrice int
Declare Mycursor cursor
for select  p.ProductID, p.UnitPrice from Products p, ProductsHighPrice php where p.ProductID = php.ProductID
open Mycursor
Fetch next from Mycursor into @ProductID, @unitPrice
while @@FETCH_STATUS=0
begin 
Update ProductsHighPrice 
        Set UnitPrice=@unitPrice*1.1 
        where ProductsHighPrice.ProductID=@ProductID
Fetch next from Mycursor into @ProductID, @unitPrice
end 
close Mycursor
Deallocate Mycursor

go



--****************************************MERGE***************************************

--5 merge adventureworks with northwind
--a. first name last name, address and telephone
--b. same code, northwind firstname stays same and lastname gets updated by adventureworks
--   code in adventureworks but not in northwind, names updated from adventureworks
--   code in northwind not in adventureworks stay same

merge into northwind.dbo.employees_new as target 
	using adventureworks2017.person.person as source
	on (target.EmployeeID = source.BusinessEntityID)
	when matched then
		update set lastname = source.Lastname
	when not matched by target then
		insert (FirstName,lastname )
		values (source.firstname, source.Lastname)
	OUTPUT $action, inserted.EmployeeID ,  deleted.EmployeeID, inserted.FirstName ,  deleted.FirstName, inserted.lastName ,  deleted.lastName;

--SET IDENTITY_INSERT northwind_new.dbo.new_employees off
--SET IDENTITY_INSERT northwind_new.dbo.employees off
Declare @address varchar (60) , @phoneNumber varchar (60), @Firstname varchar (60), @Lastname varchar (60)
Declare Addcursor cursor
for select distinct ad.addressLine1, ph.phonenumber		
				from adventureworks2017.person.address ad, adventureworks2017.person.businessEntityAddress bad, 
				adventureworks2017.person.person per, adventureworks2017.person.personphone ph, northwind.dbo.employees emp
				where ad.addressid = bad.addressid
				and bad.businessEntityId = per.businessEntityId
				and per.businessEntityId = ph.businessentityid
				--and per.FirstName = emp.FirstName
				--and per.LastName = emp.LastName
				and per.PersonType = 'SC'
open Addcursor
Fetch next from Addcursor into @address, @phoneNumber
while @@FETCH_STATUS=0
begin 
	merge into northwind.dbo.employees_new as target 
	using adventureworks2017.person.person as source
	on (target.firstname = source.firstname and target.LastName = source.LastName)
	when NOT matched then
		INSERT (FIRSTNAME, LASTNAME, Address, homephone)VALUES (source.firstname, source.LastName, @address, @phoneNumber)
	OUTPUT $action, inserted.address,  deleted.address, inserted.homephone, deleted.homephone;
Fetch next from Addcursor into @address, @phoneNumber
end 
close Addcursor
Deallocate Addcursor

----****
delete from employees where birthdate is null
select * from employees

				
				

delete from employees where birthdate is null


C.
SELECT distinct  Department_ID  
FROM Employees where SALARY>any(SELECT AVG(SALARY) 
FROM Employees 
GROUP BY Department_ID )

D.
SELECT Department_ID  
FROM Employees 
WHERE SALARY >ALL(SELECT AVG(SALARY) 
FROM Employees
GROUP BY Department_ID ) 

E.
SELECT FirstName 
FROM Employees
WHERE SALARY>ANY (select MAX(SALARY)
FROM Employees 
GROUP BY Department_ID ) 

--6
--1
USE
	tempdb;
GO


CREATE TABLE
	dbo.LearnInsert
(
	LineID	INT		IDENTITY(1,1)	NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL,
	AnotherName NVARCHAR(50) NOT NULL 
);
GO

DECLARE @i AS int = 0;
WHILE @i < 5
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.LearnInsert
(name, AnotherName)
VALUES
(CAST(NEWID() AS CHAR(36)), 'b');
END;

select * from dbo.LearnInsert
 
 --2
insert into dbo.LearnInsert
select top 5 name, name from sys.databases
go 

--3

select * into dbo.LearnInsert2
from dbo.LearnInsert

--4
delete top(1) from dbo.LearnInsert2
select * from dbo.LearnInsert2

--5
delete from dbo.LearnInsert2
where lineid=107

--6
delete from dbo.LearnInsert2

--7
SET IDENTITY_INSERT dbo.LearnInsert2 off
insert into dbo.LearnInsert2 (name, AnotherName)
select name, AnotherName from dbo.LearnInsert

--8
delete from dbo.LearnInsert

DECLARE @i AS int = 0;
WHILE @i < 5
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.LearnInsert
(name, AnotherName)
VALUES
(CAST(NEWID() AS CHAR(36)), 'b');
END;

select * from dbo.LearnInsert

--value = 111 is inserted

--9

truncate table dbo.LearnInsert

DECLARE @i AS int = 0;
WHILE @i < 5
BEGIN
SET @i = @i + 1;
INSERT INTO dbo.LearnInsert
(name, AnotherName)
VALUES
(CAST(NEWID() AS CHAR(36)), 'b');
END;

select * from dbo.LearnInsert

--value = 1
--started from the begining because counter is reset on truncate