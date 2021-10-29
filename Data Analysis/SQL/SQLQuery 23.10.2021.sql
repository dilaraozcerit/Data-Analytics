select *
from sale.order_item


SELECT *
FROM sale.customer X
where not exists
		(
		SELECT *
		FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
		where A.product_id = B.product_id
		and B.order_id = C.order_id
		and c.customer_id = D.customer_id
		and A.product_name = 'Trek Remedy 9.8 - 2019'
		and X.state = D.state
		)


SELECT distinct state
FROM sale.customer X
where not exists
		(
		SELECT *
		FROM product.product A, sale.order_item B, sale.orders C, sale.customer D
		where A.product_id = B.product_id
		and B.order_id = C.order_id
		and c.customer_id = D.customer_id
		and A.product_name = 'Trek Remedy 9.8 - 2019'
		and X.state = D.state
		)


CREATE VIEW NEW_PRODUCTS AS
SELECT A.*
FROM product.product A
WHERE A.model_year >'2019'


select * from new_products

--ctes

with last_cust 
as 
(
    select top 1 o.order_date
    from sale.customer c join sale.orders o on c.customer_id=o.customer_id
    where first_name = 'Sharyn' and last_name = 'Hopkins'
)
select a.first_name, a.last_name
from sale.customer a join sale.orders b on a.customer_id=b.customer_id
where b.order_date < (select * from last_cust)


Select *
from sale.customer A, sale.orders B
where A.customer_id = B.customer_id
and A.first_name = 'Sharyn'
and A.last_name = 'Hopkins'




with T1 as
(
select max(order_date) last_purchase
from sale.customer A, sale.orders B
where A.customer_id = B.customer_id
and A.first_name = 'Sharyn'
and A.last_name = 'Hopkins'
)
select distinct A.order_date, A.order_id, B.customer_id, B.first_name, B.last_name, B.city
from sale.orders A, sale.customer B, T1
where A.customer_id = B.customer_id
and A.order_date < T1.last_purchase




WITH T1 AS
(
SELECT B.order_date purchase_date
FROM sale.customer A, sale.orders B
WHERE A.customer_id = B.customer_id
AND A. first_name = 'Abby'
AND A.last_name = 'Parks'
)
SELECT B.first_name, B.last_name, A.order_date
FROM sale.orders A, sale.customer B , T1
WHERE A.customer_id = B.customer_id
AND A.order_date = T1.purchase_date


with T1 as
(
select 1 as NUM
union ALL
select NUM + 1
from T1
where NUM < 9
) 
select *
from T1



-------------
---Set operators

select *
from sale.customer
where city='Sacramento'

select *
from sale.customer
where city='Monroe'


select last_name
from sale.customer
where city='Sacramento'
Union all
select last_name
from sale.customer
where city='Monroe'
order by last_name

---Union
select last_name
from sale.customer
where city='Sacramento'
Union
select last_name
from sale.customer
where city='Monroe'
order by last_name


-----

select first_name, last_name
from sale.customer
where first_name ='Carter'
Union all
select first_name, last_name
from sale.customer
where last_name ='Carter'



---intersect
select *
from product.product 

select brand_id
from product.product
where model_year = 2018
intersect
select brand_id
from product.product
where model_year = 2019




select A.brand_id, B. brand_name
from
(select brand_id
from product.product
where model_year = 2018
INTERSECT
select brand_id
from product.product
where model_year = 2019) as A join product.brand B on A.brand_id=B.brand_id


SELECT B.brand_id, B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id=B.brand_id AND A.model_year = 2018
INTERSECT
SELECT B.brand_id, B.brand_name
FROM product.product A, product.brand B
WHERE A.brand_id=B.brand_id AND A.model_year = 2019



SELECT A.first_name, A.last_name
FROM sale.customer A, sale.orders B
WHERE A.customer_id=B.customer_id AND B.order_date BETWEEN '2018-01-01' AND '2018-12-31'
INTERSECT
SELECT A.first_name, A.last_name
FROM sale.customer A, sale.orders B
WHERE A.customer_id=B.customer_id AND B.order_date BETWEEN '2019-01-01' AND '2019-12-31'
INTERSECT
SELECT A.first_name, A.last_name
FROM sale.customer A, sale.orders B
WHERE A.customer_id=B.customer_id AND B.order_date BETWEEN '2020-01-01' AND '2020-12-31'




