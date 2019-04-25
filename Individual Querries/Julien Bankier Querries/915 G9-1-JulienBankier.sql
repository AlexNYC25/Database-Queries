-- Julien Bankier Querries
-- SIMPLE - 5

-- Get products discontinued by supplier and how much they were selling Simple 1
SELECT o.Quantity
	,p.ProductName
	,p.SupplierID
FROM Sales.OrderDetail o
LEFT JOIN Production.Product p ON o.ProductId = p.ProductId
WHERE Discontinued = 1
ORDER BY o.Quantity DESC

-- Supplier company per product Simple 2
SELECT s.SupplierCompanyName
	,p.ProductName
FROM Production.Supplier s
INNER JOIN Production.Product p ON s.SupplierId = p.SupplierId

-- Product name and category description Simple 3
SELECT p.ProductName
	,c.[Description] AS 'Description'
FROM Production.Product p
INNER JOIN Production.Category c ON p.CategoryId = c.CategoryId
ORDER BY 'Description'

-- Country and date of items being shipped to France ordered by shipper company Simple 4
SELECT o.ShipToCountry AS Country
	,o.ShipToDate AS DateShipped
	,s.ShipperCompanyName AS ShipperCompany
FROM Sales.[Order] o
LEFT JOIN Sales.Shipper s ON o.ShipperId = s.ShipperId
WHERE o.ShipToCountry = 'France'
ORDER BY ShipperCompany


--Order id per employer last name and first name Simple 5
SELECT o.orderID
	,e.EmployeeLastName
	,e.EmployeeFirstName
FROM Sales.[Order] o
LEFT JOIN HumanResources.Employee e ON o.EmployeeId = e.EmployeeId

-- MEDIUM
-- Total discount amount per total quantity ordered on date per orderID Medium 1
SELECT o.OrderId
	,MAX(o.OrderDate) AS orderDate
	,SUM(od.Quantity) AS tQuantity
	,SUM(od.DiscountPercentage) AS tDiscount
FROM Sales.[Order] o
INNER JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
GROUP BY o.OrderId

-- Most units sold in an order Medium 2
SELECT o.OrderId AS OrderID
	,SUM(od.Quantity) AS QuantitySold
	,e.EmployeeLastName
	,MAX(o.OrderDate) AS orderDate
FROM Sales.[Order] o
INNER JOIN Sales.OrderDetail od ON o.Orderid = od.Orderid
INNER JOIN HumanResources.Employee e ON o.EmployeeId = e.EmployeeId
GROUP BY e.EmployeeLastName
	,o.OrderId
ORDER BY QuantitySold DESC

-- Total freight going to one country by asecnding Medium 3
SELECT Sum(o.Freight) AS TotalFrieght
	,sh.ShipperCompanyName
FROM Sales.[Order] o
INNER JOIN Sales.Shipper sh ON o.ShipperId = sh.ShipperId
GROUP BY sh.ShipperCompanyName
ORDER BY TotalFrieght DESC

-- Customer companies with the least total orders Medium 4
SELECT c.CustomerCompanyName
	,SUM(od.Quantity) AS TotalOrderQuantity --, o.OrderDate
FROM Sales.[Order] o
LEFT JOIN Sales.Customer c ON o.CustomerId = c.CustomerId
LEFT JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
GROUP BY c.CustomerCompanyName
ORDER BY TotalOrderQuantity

-- Most popular product per city that is not currently discontinued Medium 5
SELECT SUM(od.Quantity) AS 'Total Quanity'
	,o.ShipToCity AS City
	,p.productID AS ProductID
	,c.[Description] AS 'Product Type'
FROM Sales.OrderDetail od
INNER JOIN Production.Product p ON od.ProductId = p.ProductId
INNER JOIN Sales.[Order] o ON od.OrderId = o.OrderId
LEFT JOIN Production.Category c ON p.CategoryId = c.CategoryId
WHERE Discontinued = 0
GROUP BY o.ShipToCity
	,c.[Description]
	,p.ProductId
ORDER BY 'Total Quanity' DESC

-- Discontinued Products and per category Medium 6
SELECT c.CategoryName
	,COUNT(*) AS DiscontinuedUnitCount
FROM Sales.OrderDetail s
LEFT JOIN Production.Product p ON s.ProductId = p.ProductId
LEFT JOIN Production.Category c ON p.CategoryId = c.CategoryId
WHERE Discontinued = 1
GROUP BY c.CategoryName

-- Employee shipping the most to each country Medium 7
SELECT o.ShipToCountry AS Country
	,SUM(od.Quantity) AS Quantity
	,e.EmployeeLastName AS LastName
FROM Sales.[Order] o
LEFT JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
INNER JOIN HumanResources.Employee e ON o.EmployeeId = e.EmployeeID
GROUP BY o.ShipToCountry
	,e.EmployeeLastName
ORDER BY Quantity DESC

-- Order per day Medium 8
SELECT o.OrderDate
	,COUNT(od.OrderId) AS unitsSoldPerOrder
FROM Sales.[Order] o
LEFT JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
GROUP BY o.OrderDate
ORDER BY o.OrderDate

--COMPLEX - 7
-- Total sales per employee after discount Complex 1
SELECT SUM(Sales.udfSalesAfterDiscount(od.Quantity, od.UnitPrice, od.DiscountPercentage)) AS TotalSalesAfterDiscount
	,SUM(Sales.udfSalesAfterDiscount(od.Quantity, od.UnitPrice, 0)) AS TotalSalesWithoutDiscount
	,e.EmployeeLastName
	,e.EmployeeID
FROM Sales.[Order] o
LEFT JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
LEFT JOIN HumanResources.Employee e ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID
	,e.EmployeeLastName
ORDER BY TotalSalesAfterDiscount DESC

-- total cost, margin per unit, and profit Complex 2
SELECT p.UnitPrice AS UnitCost
	,od.UnitPrice AS UnitSales
	,od.UnitPrice - p.UnitPrice AS MarginPerUnit
	,od.Quantity
	,Sales.udfSalesAfterDiscount(p.UnitPrice, od.Quantity, 0) AS TotalCost
	,Sales.udfSalesAfterDiscount(od.UnitPrice, od.Quantity, SUM(od.DiscountPercentage)) AS TotalSales
	,od.ProductID
	,s.SupplierCompanyName AS SupplierCompanyName
	,Sales.udfSalesAfterDiscount(od.UnitPrice, od.Quantity, SUM(od.DiscountPercentage)) - Sales.udfSalesAfterDiscount(p.UnitPrice, od.Quantity, 0) AS TotalRevenue
FROM Production.Product p
LEFT JOIN Sales.OrderDetail od ON p.ProductID = od.productID
LEFT JOIN Production.Supplier s ON p.SupplierId = s.SupplierId
GROUP BY od.ProductID
	,p.unitPrice
	,od.unitPrice
	,od.Quantity
	,s.SupplierCompanyName

-- Percent of freight represented by which shipping company Complex 3
SELECT SUM(o.Freight) AS TotalFreight
	,Sales.udfPercent(Sum(o.Freight), 64942.69) AS percentageOfFreight
	,sh.ShipperCompanyName
FROM Sales.[Order] o
INNER JOIN Sales.Shipper sh ON o.ShipperID = sh.ShipperID
GROUP BY sh.ShipperCompanyName

-- Net sales of particular employees after discount Complex 4
SELECT SUM(Sales.udfSalesAfterDiscount(od.UnitPrice, od.Quantity, od.DiscountPercentage)) AS Sales
	,e.EmployeeLastName
	,e.EmployeeId
FROM Sales.[Order] o
INNER JOIN Sales.OrderDetail od ON o.OrderId = od.Orderid
INNER JOIN HumanResources.Employee e ON o.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeLastName
	,e.EmployeeId
ORDER BY Sales DESC

--Top Sales in France, what they are, and when it happened Complex 5
SELECT od.Quantity
	,od.UnitPrice
	,SUM(Sales.udfSalesAfterDiscount(od.Quantity, od.UnitPrice, od.DiscountPercentage)) AS 'Total Sales'
	,o.OrderId
	,o.OrderDate
	,o.ShipToCountry
	,c.[Description]
FROM Sales.[Order] o
INNER JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
INNER JOIN Production.Product p ON od.ProductId = p.ProductId
INNER JOIN Production.Category c ON p.CategoryId = c.CategoryId
WHERE o.ShipToCountry = 'France'
GROUP BY o.ShipToCountry
	,od.Quantity
	,od.UnitPrice
	,c.[Description]
	,o.OrderId
	,o.OrderDate
ORDER BY 'Total Sales' DESC

--customer ranked by sales after discount with Contact name, number, and country if not discontinued Complex 6
SELECT SUM(Sales.udfSalesAfterDiscount(od.Quantity, od.UnitPrice, od.DiscountPercentage)) AS 'Total Sales'
	,c.CustomerCompanyName AS 'Company Name'
	,c.CustomerContactName AS 'Contact Name'
	,c.CustomerPhoneNumber AS 'Contact Number'
	,c.CustomerCountry
FROM Sales.[Order] o
INNER JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
INNER JOIN Production.Product p ON od.ProductId = p.ProductId
INNER JOIN Sales.Customer c ON o.CustomerID = c.CustomerID
WHERE p.Discontinued = 0
GROUP BY c.CustomerCompanyName
	,c.CustomerContactName
	,c.CustomerPhoneNumber
	,c.CustomerCountry
ORDER BY 'Total Sales' DESC

-- Cheese , where its being sold too, who is selling it,
-- the amount of revenue we are making on it (not discontinued),
-- the company it's being sold to and contact information
-- Complex 7
SELECT p.ProductName
	,s.SupplierCompanyName
	,Sales.udfPercent(Sum(od.Quantity), 366) AS 'Percent of Total Cheese Sold'
	,SUM(Sales.udfSalesAfterDiscount(od.Quantity, od.UnitPrice, od.DiscountPercentage)) AS 'Total Cheese Sales'
	,cu.CustomerCompanyName
	,cu.CustomerContactName
	,cu.CustomerPhoneNumber
	,cu.CustomerCountry
FROM Sales.[Order] o
INNER JOIN Sales.OrderDetail od ON o.OrderId = od.OrderId
INNER JOIN Production.Product p ON od.ProductId = p.ProductId
INNER JOIN Production.Category c ON p.CategoryId = c.CategoryId
INNER JOIN Production.Supplier s ON p.SupplierId = s.SupplierId
INNER JOIN Sales.Customer cu ON o.CustomerId = cu.CustomerId
WHERE p.Discontinued = 0
	AND c.[Description] = 'Cheeses'
GROUP BY s.SupplierCompanyName
	,p.ProductName
	,cu.CustomerCompanyName
	,cu.CustomerContactName
	,cu.CustomerPhoneNumber
	,cu.CustomerCountry
ORDER BY 'Percent of Total Cheese Sold' DESC

-- Fixes of my three worst ones
-- Simple 1 Fix
SELECT SUM(o.Quantity) AS 'Total Sold of Discontinued Product'
	,p.ProductName
FROM Sales.OrderDetail o
LEFT JOIN Production.Product p ON o.ProductId = p.ProductId
WHERE Discontinued = 1
GROUP BY p.ProductName
ORDER BY 'Total Sold of Discontinued Product' DESC

-- Simple 5 Fix
SELECT o.orderID
	,CONCAT (
		e.EmployeeLastName
		,e.EmployeeFirstName
		) AS EmployeeFirstAndLastName
	,e.EmployeeId
FROM Sales.[Order] o
LEFT JOIN HumanResources.Employee e ON o.EmployeeId = e.EmployeeId
ORDER BY o.orderID

--Medium 2 Fix
SELECT o.OrderId AS OrderID
	,SUM(od.Quantity) AS QuantitySold
	,SUM(Sales.udfSalesAfterDiscount(od.Quantity, od.UnitPrice, od.DiscountPercentage)) AS 'Total Sales'
	,e.EmployeeLastName
	,MAX(o.OrderDate) AS orderDate
FROM Sales.[Order] o
INNER JOIN Sales.OrderDetail od ON o.Orderid = od.Orderid
INNER JOIN HumanResources.Employee e ON o.EmployeeId = e.EmployeeId
GROUP BY e.EmployeeLastName
	,o.OrderId
ORDER BY QuantitySold DESC

