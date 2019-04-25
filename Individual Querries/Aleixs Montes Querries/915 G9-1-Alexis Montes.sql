-- Not really useful and dosen't display the actuall employee name or any other details
-- Proposition  (Simple 1): Find the list of employees born before the year 2000
USE AdventureWorks2014

SELECT NationalIDNumber
	,JobTitle
	,DATEPART(year, BirthDate) AS [Year Born]
FROM HumanResources.Employee
WHERE DATEPART(year, BirthDate) < 2000;

-- Proposition (Simple 2): Find the employees that were salesperson last year and have sales year to date made more then the previous year
USE AdventureWorks2014

SELECT BusinessEntityID
	,SalesYTD
	,SalesLastYear
FROM Sales.SalesPerson
WHERE SalesYTD > SalesLastYear
	AND SalesLastYear != 0.00;

-- Proposition (Simple 3): Find the number of employees that are employed as a Tehinician
USE AdventureWorks2014

SELECT COUNT(NationalIDNumber) AS [Number of Technicians]
FROM HumanResources.Employee
WHERE JobTitle LIKE '%Technician%';

-- Proposition (Simple 4): Find the list of Employees that are paid over $20 and more then once a week
USE AdventureWorks2014

SELECT BusinessEntityID
	,Rate
	,PayFrequency
FROM HumanResources.EmployeePayHistory
WHERE Rate > 20
	AND PayFrequency > 1;

-- Proposition (Simple 5): Create a list matching the store id and the number of customers that store has.
USE AdventureWorks2014

SELECT StoreID
	,COUNT(CustomerID) AS [Number of Customers per store]
FROM Sales.Customer
WHERE (StoreID IS NOT NULL)
GROUP BY StoreID
ORDER BY StoreID;

-- Proposition (Simple 6): Show the list of Discounts available sorted by their end date in decending order so the first to end is the first result
USE AdventureWorks2014

SELECT [Description]
	,[Type]
	,DiscountPct AS [Discount Percent]
	,EndDate
FROM Sales.SpecialOffer
ORDER BY EndDate DESC;

-- Proposition (Simple 7):  Display the list of Products that have reviewe and display thier reviewr(person), thier rating and the date it was reviewd
USE AdventureWorks2014

SELECT P.ProductID
	,P.[Name]
	,P.ListPrice
	,PR.ReviewerName
	,PR.Rating
	,PR.Comments
	,PR.ReviewDate
FROM Production.Product AS P
INNER JOIN Production.ProductReview AS PR ON P.ProductID = PR.ProductID;

-- BAD 1 not really reliable or useful
-- Proposition (Simple 8): Sort the list of employes by last modified date
USE AdventureWorks2014

SELECT BusinessEntityID
	,FirstName
	,LastName
	,ModifiedDate
FROM Person.Person
ORDER BY ModifiedDate;

-- Proposition (Simple 9): Create a list of Products that have reached their end of sell date, so that it creates a list of discontinued products
USE AdventureWorks2014

SELECT ProductID
	,[Name]
	,SellEndDate
FROM Production.Product
WHERE SellEndDate < SYSDATETIME();

-- Production (Simple 10): Find How many products use a specific photo file, that the company uses
USE AdventureWorks2014

SELECT COUNT(PPP.ProductPhotoID) AS [Number of Products]
	,PPP.ProductPhotoID
	,PP.ThumbnailPhotoFileName
FROM Production.ProductProductPhoto AS PPP
INNER JOIN Production.ProductPhoto AS PP ON PPP.ProductPhotoID = PP.ProductPhotoID
GROUP BY PPP.ProductPhotoID
	,PP.ThumbnailPhotoFileName;

-- Proposition (Simple 11): Find the top 10 Products that have the most quantity in thier inventory
USE AdventureWorks2014

SELECT TOP (10) ProductID
	,Quantity
FROM Production.ProductInventory
ORDER BY Quantity DESC;

-- Propositon (simple 12): Create a column using a case statment based on if the product has quantiry in the inventory, so that we can see if the product is in stock or not
USE AdventureWorks2014

SELECT ProductID
	,CASE 
		WHEN Quantity = 0
			THEN 'Out Of Stock'
		ELSE 'In Stock'
		END AS [Status]
FROM Production.ProductInventory
ORDER BY ProductID;


-- Bad could be more simpler
-- Proposition (Medium 1): Find in the list of employees all employess who have birthdays in march
USE AdventureWorks2014

SELECT HumanResources.Employee.BusinessEntityID
	,BirthDate
	,Person.Person.FirstName
	,Person.Person.LastName
FROM HumanResources.Employee
INNER JOIN Person.Person ON Person.Person.BusinessEntityID = HumanResources.Employee.BusinessEntityID
WHERE DATEPART(month, BirthDate) = 3
GROUP BY HumanResources.Employee.BusinessEntityID
	,Person.Person.FirstName
	,Person.Person.LastName
	,BirthDate;


-- Proposition (Medium 2): Create a list of our products and how much we profit by comparing how much they cost to manufacture and how much we sell them for at thier list price
USE AdventureWorks2014

SELECT P.ProductID
	,P.Name
	,ProductNumber
	,ROUND(P.ListPrice - PCH.StandardCost, 2) AS [Total Profit]
FROM Production.Product AS P
INNER JOIN Production.ProductCostHistory AS PCH ON PCH.ProductID = P.ProductID
GROUP BY P.ProductID
	,P.Name
	,ProductNumber
	,P.ListPrice
	,PCH.StandardCost
ORDER BY [Total Profit] DESC;

-- Proposition(Medium 3): Show ths list of employees, with the date of thier end of 2 week probation and if they are still under probation, by finding the date 2 weeks from thier hire date
USE AdventureWorks2014

SELECT E.BusinessEntityID
	,P.FirstName
	,P.LastName
	,E.JobTitle
	,E.HireDate
	,DATEADD(week, 2, E.HireDate) AS [End of Propation Date]
	,CASE 
		WHEN DATEADD(week, 2, E.HireDate) < SYSDATETIME()
			THEN 'Passed'
		ELSE 'Still Under'
		END AS [Status]
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS P ON P.BusinessEntityID = E.BusinessEntityID
GROUP BY E.BusinessEntityID
	,P.FirstName
	,P.LastName
	,E.JobTitle
	,E.HireDate;

-- Proposition (Medium 4): Create a summery table of Sales Persons from within the company, creating a coloumn that uses a case statment where it cheks to see if that salesperson has exceeded what thier quota was
USE AdventureWorks2014

SELECT SP.BusinessEntityID
	,P.FirstName
	,P.MiddleName
	,P.LastName
	,SP.SalesQuota
	,SP.Bonus
	,ROUND(SP.SalesYTD, 2) AS [Sales YTD]
	,ROUND(SP.SalesLastYear, 2) AS [Sales Last Year]
	,CASE 
		WHEN SalesYTD > SalesQuota
			THEN 'Quota Met'
		ELSE 'Quota not yet met'
		END AS [Quota Status]
FROM Sales.SalesPerson AS SP
INNER JOIN Person.Person AS P ON SP.BusinessEntityID = P.BusinessEntityID
WHERE SP.SalesQuota IS NOT NULL
	AND SP.SalesLastYear IS NOT NULL
	AND SP.SalesLastYear != 0.00;

-- Proposition (Medium 5): Find how much products was losed during production on items we sell and the reason it was scraped and how much in potential revenue was lost
SELECT WO.ProductID
	,WO.OrderQty
	,WO.ScrappedQty
	,WO.ScrapReasonID
	,SR.[Name]
	,P.ListPrice
	,ROUND((P.ListPrice * WO.ScrappedQty), 2) AS [Total Loss]
FROM Production.WorkOrder AS WO
INNER JOIN Production.ScrapReason AS SR ON WO.ScrapReasonID = SR.ScrapReasonID
INNER JOIN Production.Product AS P ON WO.ProductID = P.ProductID
WHERE WO.ScrappedQty > 0
	AND P.ListPrice != 0.00;

-- Bad is unnecesary can be replaced by using built in function
-- Proposiiton (Complex 1) -- CREATE A SUMMERY OF EMPLOYES WITH THIER FULL NAME BY A FUNCTION< NOT SEPERATED AND THIER CURENT JOB TITLE, DEPT ID , DEPT Name, and how many times they have been promoted.
CREATE FUNCTION getFullName (
	@firstName VARCHAR(250)
	,@middleName VARCHAR(250)
	,@lastName VARCHAR(250)
	)
RETURNS VARCHAR(250)
AS
BEGIN
	IF @middleName IS NOT NULL
	BEGIN
		RETURN CONCAT (
				@firstName
				,' '
				,@middleName
				,' '
				,@lastName
				)
	END

	RETURN CONCAT (
			@firstName
			,' '
			,@lastName
			)
END;
GO



USE AdventureWorks2014

SELECT P.FirstName
	,P.LastName
	, dbo.getFullName(P.FirstName, P.MiddleName, P.LastName) as FullName
	,E.JobTitle
	,EDH.DepartmentID
	,D.Name AS [Current Department]
	,P.EmailPromotion AS [Number of Promotions given]
FROM Person.Person AS P
INNER JOIN HumanResources.Employee AS E ON P.BusinessEntityID = E.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS EDH ON P.BusinessEntityID = EDH.BusinessEntityID
INNER JOIN HumanResources.Department AS D ON EDH.DepartmentID = D.DepartmentID
WHERE EDH.EndDate IS NULL
GROUP BY P.FirstName
	,P.MiddleName
	,P.LastName
	,E.JobTitle
	,EDH.DepartmentID
	,D.Name
	,P.EmailPromotion;

-- HARD (Complex 2) Get a summery of salespersons, thier sales last year, this year, and if they have reached thier quota plus and aditional 15%

USE AdventureWorks2014

SELECT SP.BusinessEntityID
	,ROUND(SP.SalesLastYear, 2) AS [Sales Last Year]
	,ROUND(SP.SalesYTD, 2) AS [This Years Sales]
	,dbo.goodSalesPerson(ROUND(SP.SalesLastYear, 2), ROUND(SP.SalesYTD, 2)) AS [Is He/She a good salesperson]
	,SP.TerritoryID
	,ST.Name AS [Territory Name]
	,ST.CountryRegionCode
	,CR.Name AS [Country Name]
FROM Sales.SalesPerson AS SP
INNER JOIN Sales.SalesTerritory AS ST ON SP.TerritoryID = ST.TerritoryID
INNER JOIN Person.CountryRegion AS CR ON ST.CountryRegionCode = CR.CountryRegionCode
WHERE SP.SalesLastYear != 0.00
GROUP BY SP.BusinessEntityID
	,SP.SalesLastYear
	,SP.SalesYTD
	,SP.TerritoryID
	,ST.Name
	,ST.CountryRegionCode
	,CR.Name
ORDER BY SP.TerritoryID;

CREATE FUNCTION goodSalesPerson (
	@lastYear DECIMAL(10, 2)
	,@thisYear DECIMAL(10, 2)
	)
RETURNS VARCHAR(250)
AS
BEGIN
	IF (@lastYear * 1.15 >= @thisYear)
	BEGIN
		RETURN 'Excelent'
	END

	RETURN 'Work In Progress'
END;

-- Proposition (Complex 3) Create a string representation that displays hew much the total sale was in the foreign currency, and other details of the sales.
CREATE
	OR

ALTER FUNCTION getTotalValue (
	@id INT
	,@total DECIMAL(10, 2)
	)
RETURNS VARCHAR(250)
AS
BEGIN
	DECLARE @toRate DECIMAL(10, 2)
		,@finalAmt DECIMAL(10, 2)
		,@CName VARCHAR(250)

	SET @toRate = CAST((
				SELECT AverageRate
				FROM Sales.CurrencyRate
				WHERE CurrencyRateID = @id
				) AS INT);
	SET @finalAmt = @total * @toRate;
	SET @CName = (
			SELECT ToCurrencyCode
			FROM Sales.CurrencyRate
			WHERE @id = CurrencyRateID
			)

	RETURN CONCAT (
			CAST(@finalAmt AS VARCHAR(250))
			,' '
			,CAST((
					SELECT NAME
					FROM Sales.Currency
					WHERE @CName = CurrencyCode
					) AS VARCHAR(250))
			,'s'
			)
END;

USE AdventureWorks2014

SELECT SOH.SalesOrderID
	,SOH.SalesOrderNumber
	,SOH.TerritoryID
	,SOH.CurrencyRateID
	,SOH.TotalDue AS [Total Due in Dollars]
	,CR.ToCurrencyCode
	,C.Name
	,dbo.getTotalValue(CAST(SOH.CurrencyRateID AS INT), CAST(SOH.TotalDue AS DECIMAL(10, 2))) AS [Total in foregn currency]
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.CurrencyRate AS CR ON SOH.CurrencyRateID = CR.CurrencyRateID
INNER JOIN Sales.Currency AS C ON C.CurrencyCode = CR.ToCurrencyCode;