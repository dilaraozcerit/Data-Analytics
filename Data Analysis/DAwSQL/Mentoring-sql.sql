



--monthwise turnover analysis

SELECT * 
FROM
(
SELECT YEAR(order_date) order_year, MONTH(B.order_date) Order_Month, list_price
FROM sale.store A, sale.orders B, sale.order_item C
WHERE A.store_name = 'Buffalo Bikes'
AND A.store_id=B.store_id
AND	B.order_id = C.order_id
) A
PIVOT
(
SUM(list_price)
FOR order_month
IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) as piv
order by order_year


--daywise turnover analysis



SELECT * 
FROM
(
SELECT Datename(DW , order_date) order_day, datepart(WK, B.order_date) order_week, list_price
FROM sale.store A, sale.orders B, sale.order_item C
WHERE A.store_name = 'Buffalo Bikes'
AND A.store_id=B.store_id
AND	B.order_id = C.order_id
) A
PIVOT
(
SUM(list_price)
FOR order_day
IN ([Sunday],[Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday])
) as piv
order by order_week
