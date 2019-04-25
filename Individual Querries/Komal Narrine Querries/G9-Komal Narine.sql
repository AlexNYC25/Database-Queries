USE WideWorldImportersDW
--1
--City and Orders made in the State of New York
SELECT C.City AS City
	,O.Description AS Description
FROM Dimension.City AS C
INNER JOIN Fact.[Order] AS O ON C.[City Key] = O.[City Key]
WHERE C.[State Province] = 'New York';
USE WideWorldImportersDW
--2
--Name of Item and the amount that has been moved.
SELECT S.[Stock Item] AS ItemName
	,M.Quantity AS Amount
FROM Dimension.[Stock Item] AS S
INNER JOIN Fact.[Movement] AS M ON S.[Stock Item Key] = M.[Stock Item Key];
USE WideWorldImportersDW
--3
--City and Description of order, made from that city.
SELECT C.City AS City
	,O.Description AS Description
FROM Dimension.City AS C
INNER JOIN Fact.[Order] AS O ON C.[City Key] = O.[City Key];
USE WideWorldImportersDW
--4
--Customer and category exclusively in Dimension.Customer and not in Fact.Sale
SELECT *
FROM Dimension.Customer AS C
LEFT JOIN Fact.Sale AS S ON C.[Customer Key] = S.[Customer Key]
WHERE S.[Customer Key] IS NULL;
USE WideWorldImportersDW
--5
--All sales made by all employees
SELECT *
FROM Dimension.Employee AS E
INNER JOIN Fact.Sale AS S ON E.[Employee Key] = S.[Salesperson Key];
USE WideWorldImportersDW
--Moderate
--1
--Total Sales made by each Employee
SELECT E.Employee
	,Count(S.[Sale Key]) AS Sales
FROM Dimension.Employee AS E
INNER JOIN Fact.Sale AS S ON E.[Employee Key] = S.[Salesperson Key]
GROUP BY E.Employee;
USE WideWorldImportersDW
--2
--The name of the Customer, Category,and Post Code of Customers who made transactions with EFT
SELECT C.Customer
	,C.Category
	,C.[Postal Code]
	,Count(C.[Customer Key]) AS Transactions
FROM Dimension.[Payment Method] AS P
INNER JOIN Fact.[Transaction] AS T ON P.[Payment Method Key] = T.[Payment Method Key]
INNER JOIN Dimension.Customer AS C ON C.[Customer Key] = T.[Customer Key]
WHERE P.[Payment Method] = 'EFT'
	AND C.Customer != 'Unknown'
GROUP BY C.Customer
	,C.Category
	,C.[Postal Code];
USE WideWorldImportersDW
--3
--Name and Quantity of Items sold in Total.
SELECT S.[Stock Item] AS Item
	,Sum(O.Quantity) AS Amount
FROM Dimension.[Stock Item] AS S
INNER JOIN Fact.[Order] AS O ON S.[Stock Item Key] = O.[Stock Item Key]
GROUP BY S.[Stock Item];
USE WideWorldImportersDW
--4
--Number of Customers in a given City
SELECT C.City AS City
	,Count(O.[Customer Key]) AS NumberofCustomers
FROM Dimension.City AS C
INNER JOIN Fact.[Order] AS O ON C.[City Key] = O.[City Key]
GROUP BY C.City;
USE WideWorldImportersDW
--5
--The Item and Average Amount of that Item that is moved
SELECT S.[Stock Item] AS ItemName
	,AVG(M.Quantity) AS AverageAmount
FROM Dimension.[Stock Item] AS S
INNER JOIN Fact.[Movement] AS M ON S.[Stock Item Key] = M.[Stock Item Key]
GROUP BY S.[Stock Item];

USE AdventureWorksDW2016

--6
--Products and the largest order of each
SELECT P.EnglishProductName AS Name
	,Max(S.OrderQuantity) AS LargestOrder
FROM dbo.DimProduct AS P
INNER JOIN dbo.FactResellerSales AS S ON P.ProductKey = S.ProductKey
GROUP BY P.EnglishProductName;
USE AdventureWorksDW2016
--7
--Employee,Department,Country,Group, Region, and Sales in each SalesTerritory,and all sales made by employee
SELECT CONCAT (
		E.FirstName
		,E.LastName
		) AS Name
	,E.DepartmentName
	,T.SalesTerritoryCountry AS Country
	,T.SalesTerritoryGroup AS [Group]
	,T.SalesTerritoryRegion AS Region
	,Sum(SalesAmount) AS TotalSales
FROM dbo.DimEmployee AS E
INNER JOIN dbo.FactResellerSales AS S ON E.EmployeeKey = S.EmployeeKey
INNER JOIN dbo.DimSalesTerritory AS T ON S.SalesTerritoryKey = T.SalesTerritoryKey
GROUP BY CONCAT (
		E.FirstName
		,E.LastName
		)
	,E.DepartmentName
	,T.SalesTerritoryCountry
	,T.SalesTerritoryGroup
	,T.SalesTerritoryRegion;
USE AdventureWorksDW2016
--8
--Products that haven't been sold by Reseller, Key and Name of Product
SELECT DISTINCT P.ProductKey
	,Pd.EnglishProductName AS Name
FROM dbo.FactProductInventory AS P
LEFT JOIN dbo.FactResellerSales AS S ON P.ProductKey = S.ProductKey
INNER JOIN dbo.DimProduct AS Pd ON P.ProductKey = Pd.ProductKey
WHERE S.ProductKey IS NULL
ORDER BY P.ProductKey;
USE AdventureWorksDW2016
--Complex
--1
--First and Last Name, with initial of customer, and how much they’ve spent on orders.
SELECT FirstName
	,LastName
	,dbo.Initials(FirstName, LastName) AS Initials
	,SUM(S.SalesAmount) AS TotalCostInPurchases
FROM dbo.DimCustomer AS C
INNER JOIN dbo.FactInternetSales AS S ON S.CustomerKey = C.CustomerKey
INNER JOIN dbo.DimPromotion AS P ON P.PromotionKey = S.PromotionKey
WHERE S.PromotionKey != 1
GROUP BY FirstName
	,LastName
	,dbo.Initials(FirstName, LastName);
USE AdventureWorksDW2016
--2 Name, Date they’ve started working, years worked,the regions they sell in, and the amount of sales they make in that region
SELECT E.FirstName
	,E.StartDate
	,dbo.YearsWorking(E.StartDate, E.EndDate) AS YearsWorking
	,T.SalesTerritoryGroup
	,Count(S.ProductKey) AS Sales
FROM dbo.DimEmployee AS E
INNER JOIN dbo.FactResellerSales AS S ON E.EmployeeKey = S.EmployeeKey
INNER JOIN dbo.DimSalesTerritory AS T ON S.SalesTerritoryKey = T.SalesTerritoryKey
GROUP BY E.FirstName
	,E.StartDate
	,E.EndDate
	,T.SalesTerritoryGroup
ORDER BY E.StartDate
	,YearsWorking
	,T.SalesTerritoryGroup;
USE AdventureWorksDW2016
--3
--Reseller, Initial of the Employee who sold to reseller, and their largest order.
SELECT R.ResellerName AS NameofReseller
	,dbo.Initials(E.FirstName, E.LastName) AS EmployeeInitials
	,Max(S.OrderQuantity) AS LargestOrder
FROM dbo.DimReseller AS R
INNER JOIN dbo.FactResellerSales AS S ON R.ResellerKey = S.ResellerKey
RIGHT JOIN dbo.DimEmployee AS E ON E.EmployeeKey = S.EmployeeKey
GROUP BY R.ResellerName
	,E.FirstName
	,E.LastName;
USE AdventureWorksDW2016
--4, Reseller, Employee initial, and their largest order
SELECT R.ResellerName AS NameofReseller
	,dbo.Initials(E.FirstName, E.LastName) AS EmployeeInitials
	,Max(S.OrderQuantity) AS LargestOrder
FROM dbo.DimReseller AS R
INNER JOIN dbo.FactResellerSales AS S ON R.ResellerKey = S.ResellerKey
INNER JOIN dbo.DimEmployee AS E ON E.EmployeeKey = S.EmployeeKey
WHERE dbo.IS_MALE(E.Gender) = 1
GROUP BY R.ResellerName
	,E.FirstName
	,E.LastName
ORDER BY LargestOrder DESC;
USE AdventureWorksDW2016
--5,Product by key, Date moved, the amount, and name of the product.
SELECT P.ProductKey
	,P.MovementDate AS DateMoved
	,Count(Pd.ProductKey) AS AmountMoved
	,Pd.EnglishProductName AS Name
FROM dbo.FactProductInventory AS P
INNER JOIN dbo.FactResellerSales AS S ON P.ProductKey = S.ProductKey
INNER JOIN dbo.DimProduct AS Pd ON P.ProductKey = Pd.ProductKey
WHERE dbo.In_Year(P.MovementDate, 2011) = 1
GROUP BY P.ProductKey
	,P.MovementDate
	,Pd.EnglishProductName;
USE AdventureWorksDW2016
--6, Customer Initials and Total spent on purchases
SELECT dbo.Initials(C.FirstName, C.LastName) AS CustomerInitials
	,Sum(P.StandardCost) AS TotalCostOfProductsBought
FROM dbo.DimCustomer AS C
INNER JOIN dbo.FactInternetSales AS S ON S.CustomerKey = C.CustomerKey
INNER JOIN dbo.DimProduct AS P ON P.ProductKey = S.ProductKey
GROUP BY FirstName
	,LastName
ORDER BY TotalCostOfProductsBought DESC;
USE AdventureWorksDW2016
--7,Customer Initials and Total spent of only FEMALES
SELECT dbo.Initials(C.FirstName, C.LastName) AS CustomerInitials
	,Sum(P.StandardCost) AS TotalCostOfProductsBought
FROM dbo.DimCustomer AS C
INNER JOIN dbo.FactInternetSales AS S ON S.CustomerKey = C.CustomerKey
INNER JOIN dbo.DimProduct AS P ON P.ProductKey = S.ProductKey
WHERE dbo.IS_MALE(C.Gender) = 0
GROUP BY FirstName
	,LastName
ORDER BY TotalCostOfProductsBought DESC;