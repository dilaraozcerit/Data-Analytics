--SQL TEAMWORK 11.09.2021--

--0.Answer the following questions according to bikestore database

-- What is the sales quantity of product according to the brands and sort them highest-lowest
select b.brand_name, sum(s.quantity) quantity
from sale.order_item s, product.product p, product.brand b
where s.product_id = p.product_id and p.brand_id = b.brand_id
group by b.brand_name
order by quantity desc



-- Select the top 5 most expensive products
select top 5 product_name, list_price
from product.product
order by list_price desc




-- What are the categories that each brand has
select b.brand_name, c.category_name
from product.brand b, product.product p, product.category c
where b.brand_id = p.product_id and p.category_id = c.category_id
order by brand_name



-- Select the avg prices according to brands and categories
select b.[brand_name], c.[category_name], avg(p.[list_price]) as [Avg Price]
from [product].[brand] b
inner join [product].[product] p
on b.brand_id = p.brand_id
inner join [product].[category] c
on p.category_id = c.category_id
group by b.brand_name, c.category_name




-- Select the annual amount of product produced according to brands
select b.brand_name, p.model_year, count(p.product_id) amount
from product.product p, product.brand b
where p.brand_id = b.brand_id
group by b.brand_name, p.model_year



-- Select the least 3 products in stock according to stores.
SELECT	*
FROM	(
		select ss.store_name, p.product_name, SUM(s.quantity) product_quantity,
		row_number() over(partition by ss.store_name order by SUM(s.quantity) ASC) least_3
		from sale.store ss
		inner join product.stock s
		on ss.store_id=s.store_id
		inner join product.product p
		on s.product_id=p.product_id
		GROUP BY ss.store_name, p.product_name
		HAVING SUM(s.quantity) > 0
		) A
WHERE	A.least_3 <= 3




-- Select the store which has the most sales quantity in 2018
select top 1 s.store_name, sum(i.quantity) sales_quantity
from sale.store s
inner join sale.orders o on s.store_id = o.store_id
inner join sale.order_item i on o.order_id = i.order_id
where year(o.order_date) = '2018' 
group by s.store_name 
order by sum(i.quantity) desc;



-- Select the store which has the most sales amount in 2016
select top 1 s.store_name, sum(i.list_price) as sales_amount_2016
from sale.store s
inner join sale.orders o
on s.store_id = o.store_id
inner join sale.order_item i
on o.order_id = i.order_id
where  year(o.order_date) = '2018' -- year(o.[order_date])
group by s.store_name 
order by sum(i.list_price) desc;



--Select the personnel which has the most sales amount in 2018
select top 1 s.[first_name], s.[last_name], sum(i.[list_price]) as sales_amount_2018
from [sale].[staff] s
inner join [sale].[orders] o
on s.staff_id = o.staff_id
inner join [sale].[order_item] i
on o.order_id = i.order_id
where  datename(year, o.[order_date]) = '2018'
group by s.[first_name], s.[last_name] 
order by sum(i.[list_price]) desc;



-- Select the least 3 sold products in 2016 and 2017 according to city.
;with temp2_cte
as(
select p.[product_name], datename(year, o.[order_date]) as order_date,
row_number() over(partition by datename(year, o.[order_date]) order by datename(year, o.[order_date])) as [row number]
from [product].[product] p
inner join [sale].[order_item] i
on p.product_id = i.product_id
inner join [sale].[orders] o
on o.order_id = i.order_id
where  datename(year, o.[order_date]) in ('2018', '2019')
)
select * from temp2_cte
where [row number] < 4



--1. Find the customers who placed at least two orders per year.
select c.customer_id, first_name, last_name, year(order_date) [year], count(o.order_id) orders
from sale.customer c, sale.orders o
where c.customer_id = o.customer_id
group by year(order_date), c.customer_id, first_name, last_name
having count(o.order_id) >= 2



--2. Find the total amount of each order which are placed in 2020.
--Then categorize them according to limits stated below.(You can use case when statements here)
/*If the total amount of order    

    less then 500 then "very low"
    between 500 - 1000 then "low"
    between 1000 - 5000 then "medium"
    between 5000 - 10000 then "high"
    more then 10000 then "very high" */
select   o.order_id, sum(quantity * list_price) as total,
			(case when sum(quantity * list_price) < 500 then 'very low'
				 when 500 < sum(quantity * list_price) and sum(quantity * list_price) < 1000 then 'low'
				 when 1000 < sum(quantity * list_price) and sum(quantity * list_price) < 5000 then 'medium'
				 when 5000 < sum(quantity * list_price) and sum(quantity * list_price) < 10000 then 'high'
				 when sum(i.quantity * i.list_price) > 10000 then 'very high'
			 end) as category
from sale.orders o, sale.order_item i
where o.order_id = i.order_id and
year(order_date) = 2020  
group by o.order_id




--3. By using Exists Statement find all customers who have placed more than two orders.
SELECT customer_id,first_name,last_name
FROM sale.customer c
WHERE
    EXISTS (
        SELECT
            COUNT (*)
        FROM sale.orders o
        WHERE customer_id = c.customer_id
        GROUP BY customer_id
        HAVING  COUNT (*) > 2 )
ORDER BY first_name, last_name;



--4. Show all the products and their list price, that were sold with more than two units in a sales order.
SELECT product_name, list_price
FROM  product.product
WHERE product_id = ANY (   SELECT product_id
						   FROM  sale.order_item
						   WHERE  quantity >= 2 )
ORDER BY product_name;




--5. Show the total count of orders per product for all times. (Every product will be shown in one line and the total order count will be shown besides it)
SELECT product_name, count(distinct order_id) aa
FROM product.product p
left JOIN sale.order_item o ON o.product_id = p.product_id
group by product_name
ORDER BY aa;



--6. Find the products whose list prices are more than the average list price of products of all brands
SELECT product_name,list_price
FROM product.product
WHERE list_price > ALL (
			SELECT AVG (list_price) avg_list_price
			FROM  product.product
			GROUP BY brand_id  )
ORDER BY list_price;