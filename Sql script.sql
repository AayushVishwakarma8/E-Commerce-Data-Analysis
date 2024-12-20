use ip;
select* from orders;

#Customer Purchase total and latest order
SELECT 
    c.FirstName,
    c.LastName,
    SUM(od.Quantity * p.Sale_Price) AS Total_Amount_Spent,
    MAX(o.OrderDate) AS Date_of_Latest_Order
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
GROUP BY 
    c.CustomerID, c.FirstName, c.LastName
ORDER BY 
    Total_Amount_Spent DESC,
    Date_of_Latest_Order DESC,
    c.LastName ASC,
    c.FirstName ASC;

#Product details of sub-categories All Purpose Cleaners, Bakeware
WITH FilteredProducts AS (
    SELECT *
    FROM Products
    WHERE Sub_Category IN ('All Purpose Cleaners', 'Bakeware')
)

SELECT *
FROM FilteredProducts
ORDER BY ProductID ASC;


# Number of suppliers
select Country, count(*)
from Suppliers
group by Country
order by Country;

# Date on which most numbers of order delivered
select DeliveryDate, count(*) as total
from Orders 
group by DeliveryDate
order by total desc
limit 1;

# Distinct Brand Names
select distinct Brand
from Products
order by Brand;

#Above 40 customers
select count(*)
from Customers
where DATEDIFF(CURRENT_DATE, Customers.Date_of_Birth)/365>=40;

# average discount on Bakeware brand
select brand,
round(avg((Market_Price-Sale_Price)/Market_Price*100)) as avg_discount
from Products
where Sub_category = 'Bakeware'
group by brand
order by avg_discount DESC;


#total number of orders placed by the customers of different countries which has atleast one product from the subcategory 'Skin Care' 
#and similarly for the subcategory 'Health & Medicine'.
SELECT 
    c.Country AS CountryName,
    SUM(CASE WHEN p.Sub_Category = 'Skin Care' THEN 1 ELSE 0 END) AS SkinCareOrders,
    SUM(CASE WHEN p.Sub_Category = 'Health & Medicine' THEN 1 ELSE 0 END) AS HealthAndMedicineOrders
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
WHERE 
    p.Sub_Category IN ('Skin Care', 'Health & Medicine')
GROUP BY 
    c.Country
ORDER BY 
    c.Country ASC;

# Top 4 cities that have placed order less than average order
with cityorder as(
select c.city, count(o.orderid) as num_orders
from customers c
join orders o on c.customerid =o.customerid
group by c.city
),
avgorder as(
select avg(num_orders)as avg_orders
from cityorder
)
select co.city, co.num_orders
from cityorder co, avgorder ao
where co.num_orders < ao.avg_orders
order by co.num_orders desc
limit 4;

# Total transaction value and total quantity shipped in different quarters of 2020 and 2021
select 
  year(o.shipdate) as year,
  quarter(o.shipdate) as quarter,
  sum(o.Total_order_amount)as toatl_transaction_value,
  sum(od.quantity) as total_quantity_shipped
from orders o
join orderdetails od on o.orderid =od.orderid
where year(o.shipdate) in (2020,2021)
group by year, quarter
order by year asc, quarter asc;

# orderdetails for those who placed order in 2020 and got delivery in 2021
WITH CTE_OrderDetails AS(
select od.*
from OrderDetails od
join Orders o on od.OrderID=o.OrderID
where OrderDate between '2020-01-01' and '2020-12-31'
and DeliveryDate between '2021-01-01' and '2021-12-31'
)
select *,OrderID
from CTE_OrderDetails
order by OrderDetailID;

# Total revenue by sales of products supplied different countries
select s.country,
sum(p.sale_price*od.quantity) as Revenue
from orderdetails od
join products p on od.productID=p.productID
join suppliers s on od.supplierID=s.supplierID
group by s.country
order by Revenue Desc;

# Popular sub-categories among people above 60
select p.sub_category,count(distinct od.orderid)as cnt
from customers c
join orders o on c.customerid= o.customerid
join orderdetails od on o.orderid = od.orderid
join products p on od.productid =p.productid
where timestampdiff(year,c.date_of_birth,o.orderdate)>60
group by p.sub_category
order by cnt desc
limit 10;

# products whose sale price are above than average sale price
select*
from products
where sale_price >(select avg(sale_price)from products);

#Products that are not sold
select p.type, count(*)as total_unsold_products
from products p
left join orderdetails od on p.productID=od.ProductID
where od.productID is null
group by p.type
order by total_unsold_products desc,p.type asc;

#Suppliers company that are established in the same country
select A.CompanyName as CompanyName, B.CompanyName as CompanyName, A.Country 
from Suppliers A
join Suppliers B on A.CompanyName <> B.CompanyName
where  A.Country = B.Country
order by A.CompanyName, B.CompanyName;

# categorizing orders
SELECT 
    CASE 
        WHEN Total_Order_Amount <= 10000 THEN 'Regular order'
        WHEN Total_Order_Amount > 10000 AND Total_Order_Amount <= 60000 THEN 'not so expensive order'
        WHEN Total_Order_Amount > 60000 THEN 'expensive order'
    END AS Order_Type,
    COUNT(Total_Order_Amount) AS Count
FROM Orders
GROUP BY 
    CASE 
        WHEN Total_Order_Amount <= 10000 THEN 'Regular order'
        WHEN Total_Order_Amount > 10000 AND Total_Order_Amount <= 60000 THEN 'not so expensive order'
        WHEN Total_Order_Amount > 60000 THEN 'expensive order'
    END
ORDER BY Count DESC;

# cumulative total order amount by customer
SELECT 
    o.OrderID,
    o.CustomerID,
    o.Total_order_amount,
    SUM(o.Total_order_amount) OVER (PARTITION BY o.CustomerID ORDER BY o.OrderID) AS cumulative_sum
FROM 
    Orders o
ORDER BY 
    o.CustomerID ASC, cumulative_sum ASC;
    
# Delayed shipment
SELECT 
    o.OrderID,
    od.ProductID,
    p.Product,
    DATEDIFF(o.ShipDate, o.OrderDate) AS days_taken_to_ship
FROM 
    Orders o
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
WHERE 
    DATEDIFF(o.ShipDate, o.OrderDate) >= 5
ORDER BY 
    o.OrderID ASC, 
    od.ProductID ASC;

# Customers Total order and Avg order
SELECT 
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS Total_Number_of_Orders,
    AVG(o.Total_order_amount) AS Average_Order_Value
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID, c.FirstName, c.LastName
ORDER BY 
    Average_Order_Value DESC,
    c.LastName ASC,
    c.FirstName ASC;


# Number of sub-category whose count is more than 300
WITH SubCategoryCounts AS (
    SELECT 
        Sub_Category,
        COUNT(*) AS Num_Products
    FROM 
        Products
    GROUP BY 
        Sub_Category
    HAVING 
        COUNT(*) > 300
),
RankedSubCategories AS (
    SELECT 
        Sub_Category,
        Num_Products,
        ROW_NUMBER() OVER (ORDER BY Num_Products DESC) AS S_No
    FROM 
        SubCategoryCounts
)
SELECT 
    S_No,
    Sub_Category,
    Num_Products
FROM 
    RankedSubCategories
ORDER BY 
    S_No ASC;

# Total sales by product and categories
SELECT 
    p.Product AS "Product Name",
    c.CategoryName AS "Category Name",
    SUM(od.Quantity) AS "Total Quantity Sold",
    SUM(od.Quantity * p.Sale_Price) AS "Total Sales Amount"
FROM 
    Products p
JOIN 
    Category c ON p.Category_ID = c.CategoryID
JOIN 
    OrderDetails od ON p.ProductID = od.ProductID
GROUP BY 
    p.Product, c.CategoryName
ORDER BY 
    c.CategoryName ASC, 
    "Total Sales Amount" DESC;

# Brands on which avg discount is greater than 50
SELECT 
    Brand,
    ROUND(AVG((Market_Price - Sale_Price) / Market_Price * 100)) AS Average_Discount
FROM 
    Products
GROUP BY 
    Brand
HAVING 
    Average_Discount > 50
ORDER BY 
    Brand ASC;
    
# Lowest total amount transacted in a city
select c.country, c.state, c.city, min(o.total_order_amount) as Minimum_amt
from customers c
join orders o on c.customerid = o.customerid
group by c.country, c.state, c.city
order by c.country asc, c.state desc , c.city;

# Months where order values was less than 100
select monthname(orderdate) as Months,
count(orderid) as Total
From orders
where total_order_amount <100
group by Months
order by 
total desc, months asc;

# Total amount spent by customers on their latest order

select c.firstname,c.lastname,
sum(od.quantity*p.sale_price) as ttl,
 max(o.orderdate) as ld
 from customers c
 join orders o on c.customerid=o.customerid
 join orderdetails od on o.orderid=od.orderid
 join products p on od.productid=p.productid  group by c.customerid, c.firstname,c.lastname
 order by ttl desc, ld desc, c.lastname asc, c.firstname asc;
 
 #Top 2 sale prices for each type
 WITH RankedProducts AS (
    SELECT 
        ProductID,
        Product,
        Category_ID,
        Sub_Category,
        Brand,
        Sale_Price,
        Market_Price,
        Type,
        DENSE_RANK() OVER (
            PARTITION BY Type 
            ORDER BY Sale_Price DESC
        ) AS rank_
    FROM Products
)
SELECT 
    ProductID,
    Product,
    Category_ID,
    Sub_Category,
    Brand,
    Sale_Price,
    Market_Price,
    Type,
    rank_
FROM RankedProducts
WHERE rank_ <= 2
ORDER BY Type ASC, rank_ ASC;

# customers from each country who placed the most expensive order
WITH RankedOrders AS (
    SELECT 
        o.OrderID,
        o.CustomerID,
        c.FirstName,
        c.LastName,
        o.Total_order_amount,
        c.Country,
        DENSE_RANK() OVER (
            PARTITION BY c.Country
            ORDER BY o.Total_order_amount DESC
        ) AS rank_
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
)
SELECT 
    OrderID,
    CustomerID,
    FirstName,
    LastName,
    Total_order_amount,
    Country,
    rank_
FROM RankedOrders
WHERE rank_ = 1
ORDER BY OrderID ASC;

# Top 5 customers monthly
WITH RankedOrders AS (
    SELECT 
        o.OrderID,
        o.CustomerID,
        MONTH(o.OrderDate) AS MonthNumber,
        o.Total_order_amount,
        RANK() OVER (PARTITION BY MONTH(o.OrderDate) ORDER BY o.Total_order_amount DESC) AS OrderRank
    FROM 
        Orders o
)
SELECT 
    OrderID,
    CustomerID,
    MonthNumber,
    Total_order_amount,
    OrderRank
FROM 
    RankedOrders
WHERE 
    OrderRank <= 5
ORDER BY 
    MonthNumber ASC,
    OrderRank ASC;
  
# City with most revenue
WITH CityRevenue AS (
SELECT c.Country, c.City, SUM(o.Total_order_amount) AS Revenue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Country, c.City
),
RankedCities AS (
SELECT Country, City, Revenue, ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Revenue DESC) AS Rak
FROM CityRevenue
)
SELECT Country, City, Revenue
FROM RankedCities
WHERE Rak = 1
ORDER BY Country ASC,
City ASC;

SELECT c.CustomerID, c.FirstName, c.LastName, c.Date_of_Birth, 
       MONTH(c.Date_of_Birth) AS BirthMonth, o.OrderDate,
       MONTH(o.OrderDate) AS OrderMonth
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
