select EmployeeID,format(orderdate,'yyyyMMMM')YearMonth,count(orderid)CountOrder from orders 
group by EmployeeID,format(orderdate,'yyyyMMMM')
order by 2,3 desc
-----------------------------
select employeeid,YearMonth,CountOrder from 
(
select EmployeeID,format(orderdate,'yyyyMM')YearMonth,count(orderid)CountOrder,
rank()over(partition by format(orderdate,'yyyyMM') order by count(orderid) desc )rnk
from orders
group by EmployeeID,format(orderdate,'yyyyMM')
)as tab where rnk=1 
order by 2,3 desc
-------------------------
select  Customerid,
format(orderdate,'yyyyMMMM')YearMonth,
count(ord.orderid)TotalOrder,
sum(ordd.Quantity*ordd.UnitPrice)TotalAmount from orders ord
inner join [Order Details] ordd on ordd.OrderID=ord.OrderID
group by Customerid,format(orderdate,'yyyyMMMM')
order by 4 desc
-----------------------
use AdventureWorks2022
WITH cte AS 
(
    SELECT 01 AS id, N'بهار' AS name
    UNION
    SELECT 02 AS id, N'بهار' AS name
    UNION
    SELECT 03 AS id, N'بهار' AS name
    UNION
    SELECT 04 AS id, N'تابستان' AS name
    UNION
    SELECT 05 AS id, N'تابستان' AS name
    UNION
    SELECT 06 AS id, N'تابستان' AS name
    UNION
    SELECT 07 AS id, N'پاییز' AS name
    UNION
    SELECT 08 AS id, N'پاییز' AS name
    UNION
    SELECT 09 AS id, N'پاییز' AS name
    UNION
    SELECT 10 AS id, N'زمستان' AS name
    UNION
    SELECT 11 AS id, N'زمستان' AS name
    UNION
    SELECT 12 AS id, N'زمستان' AS name
)
SELECT cte.name,YearSale, SUM(ord.sales) AS sales 
FROM cte
INNER JOIN 
(
    SELECT FORMAT(OrderDate, 'MM', 'fa') AS name,FORMAT(OrderDate, 'yyyy', 'fa') 'YearSale', COUNT(SalesOrderID) AS sales 
    FROM Sales.SalesOrderHeader
    GROUP BY FORMAT(OrderDate, 'MM', 'fa'),FORMAT(OrderDate, 'yyyy', 'fa')
) AS ord ON cte.id = ord.name
GROUP BY cte.name,YearSale
ORDER BY 
YearSale,
    CASE 
        WHEN cte.name = N'بهار' THEN 1
        WHEN cte.name = N'تابستان' THEN 2
        WHEN cte.name = N'پاییز' THEN 3
        WHEN cte.name = N'زمستان' THEN 4
    END;








use Northwind
go
SELECT 
    YEAR(orderdate) N'سال',
	format(orderdate,'MMMM','fa') N'ماه',
    SUM(CASE WHEN MONTH(orderdate) = MONTH(orderdate) THEN (quantity*unitprice) ELSE 0 END) AS N'فروش جاری',
	format(dateadd(month,-1,orderdate),'MMMM','fa') N'ماه قبل',
    SUM(CASE WHEN MONTH(orderdate) = MONTH(orderdate) - 1 THEN (quantity*unitprice) ELSE 0 END) AS N'فروش ماه قبل',
		format(dateadd(month,-2,orderdate),'MMMM','fa') N'دو ماه قبل',
    SUM(CASE WHEN MONTH(orderdate) = MONTH(orderdate) - 2 THEN (quantity*unitprice) ELSE 0 END) AS N'فروش دو ماه قبل',
    SUM(quantity*unitprice) AS N'مجموع فروش'
FROM 
    orders o
	inner join [order details] od on od.orderid=o.orderid
WHERE 
    orderdate >= (SELECT MIN(orderdate) FROM orders)
GROUP BY 
format(orderdate,'MMMM','fa'),format(dateadd(month,-1,orderdate),'MMMM','fa'),
format(dateadd(month,-2,orderdate),'MMMM','fa') ,  YEAR(orderdate)
order by 1


---------------
select cat.categoryid,ProductName,max(UnitPrice) from Products prod
inner join Categories cat on cat.CategoryID=prod.CategoryID
group by cat.categoryid,ProductName
order by 1,3 desc
;

select p1.categoryid,p1.productid,unitprice As MaxPrice from products p1
inner join (
select CategoryID,max(unitprice)MaxPrice from Products 
group by CategoryID
)p2 on p2.categoryid=p1.categoryid and p2.MaxPrice=p1.UnitPrice
order by 3 desc
---------------
select cat.Categoryname,prod.ProductID,prod.UnitPrice As MaxPrice from Categories cat
inner join  Products prod on cat.CategoryID=prod.CategoryID 
and prod.UnitPrice=(select max(unitprice) from Products where CategoryID=prod.CategoryID)
order by 3 desc
------------------
select categoryname,productid,unitprice As MaxPrice from(
select cat.categoryname,productid,unitprice,rank()over(partition by prod.categoryid order by unitprice desc) rnk from Products prod
inner join Categories cat on cat.CategoryID=prod.CategoryID)as tab where rnk=1
order by 3 desc