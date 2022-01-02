
-----------------Workshop 31.10.2021--------------------------



--- List the staff that Jane Destrey is the manager of

select staff_id, first_name, last_name, manager_id 
from sale.staff 
where manager_id =
                (select staff_id 
                from sale.staff 
                where first_name = 'Jane' and last_name = 'Destrey')




--- List bikes that are more expensive than the “Trek CrossRip – 2020” bike.

select * from product.product

select *
from product.product 
where list_price > 
                (select max(list_price) as urun
                from product.product
                where product_name like 'Trek CrossRip%')
order by list_price desc




-- List customers whose order dates are before Arla Ellis.

with t1 as 
(
select c.first_name, c.last_name, o.order_date
from sale.orders o join sale.customer c on o.customer_id=c.customer_id)

select first_name, last_name, order_date 
from t1
where order_date <
                    (select order_date
                    from t1
                    where first_name = 'Arla' and last_name = 'Ellis')




---List all customers who orders on the same dates as Abby Parks.

with t1 as 
(
select c.first_name, c.last_name, o.order_date
from sale.orders o join sale.customer c on o.customer_id=c.customer_id)

select first_name, last_name, order_date
from t1 
where order_date in
                (select order_date 
                from t1 
                where first_name = 'Abby' and last_name = 'Parks')




---List products in categories other than Cruisers Bicycles, Mountain Bikes, or Road Bikes in 2018.

select p.product_name, p.list_price
from product.product p join product.category c on p.category_id=c.category_id
where c.category_name not in ('Cruisers Bicycles', 'Mountain Bikes', 'Road Bikes') and p.model_year = 2018;

select p.product_name, p.list_price, c.category_name
from product.product p join product.category c on p.category_id=c.category_id
where p.model_year = 2018
except
select p.product_name, p.list_price, c.category_name
from product.product p join product.category c on p.category_id=c.category_id
where c.category_name in ('Cruisers Bicycles', 'Mountain Bikes', 'Road Bikes') and p.model_year = 2018;




--- List bikes that have a model year equal to 2020 and have prices more than all electric bikes.

select p.product_name, p.model_year, p.list_price
from product.product p join product.category c on p.category_id=c.category_id
where p.model_year = 2020 and p.list_price > all 
                                            (select p.list_price
                                            from product.product p join product.category c on p.category_id=c.category_id
                                            where c.category_name = 'Electric Bikes')
order by p.list_price desc




---List bikes that model model year equal to 2020 and its prices more than any electric bikes.

select p.product_name, p.model_year, p.list_price
from product.product p join product.category c on p.category_id=c.category_id
where p.model_year = 2020 and p.list_price > any 
                                            (select p.list_price
                                            from product.product p join product.category c on p.category_id=c.category_id
                                            where c.category_name = 'Electric Bikes')
order by p.list_price



--- Write a query that returns the state where “Trek Remedy 9.8 – 2019” product is not ordered.

select distinct state 
from sale.customer 
where state not in
                (select c.state
                from sale.customer c join sale.orders o on c.customer_id=o.customer_id
                join sale.order_item oo on o.order_id=oo.order_id join product.product p on p.product_id=oo.product_id
                where p.product_name = 'Trek Remedy 9.8 - 2019')




--- List customers who have an order prior to the last order of a customer 
---named Sharyn Hopkins and are residents of the city of San Diego.

select c.customer_id, c.first_name, c.last_name, c.city, o.order_date
from sale.customer c join sale.orders o on c.customer_id=o.customer_id
where o.order_date <  
                (select max(o.order_date)
                from sale.customer c join sale.orders o on c.customer_id=o.customer_id
                where c.first_name = 'Sharyn' and c.last_name = 'Hopkins') and c.city = 'San Diego'


with combined as 
(
    select c.customer_id, c.first_name, c.last_name, c.city, o.order_date
    from sale.customer c join sale.orders o on c.customer_id=o.customer_id 
)
select customer_id, first_name, last_name, city, order_date
from combined 
where order_date <
                (select max(order_date)
                from combined 
                where first_name = 'Sharyn' and last_name = 'Hopkins') and city='San Diego'





--- Create a table with a number in each row in ascending order from 0 to 9.

with tt as 
(
    select 1 as num
    union all
    select num + 1
    from tt 
    where num < 10
)
select * from tt

with tt as 
(
    select 1 as num, 2 as num2
    union all
    select 1 + num, num * num2
    from tt 
    where num < 10
)
select * from tt




---Soru_11: Write a query that returns customers whose first name is “Carter” or last name is “Carter.” (Do not use “or”)

select first_name, last_name 
from sale.customer 
where first_name = 'Carter' or last_name = 'Carter'

select first_name, last_name 
from sale.customer 
where first_name = 'Carter'
union 
select first_name, last_name 
from sale.customer 
where last_name = 'Carter'




---Write a query that returns brands that have products for both 2018 and 2019.

with tt as (
select b.brand_id, b.brand_name, p.product_id, p.product_name, p.model_year
from product.brand b join product.product p on b.brand_id=p.brand_id)

select brand_id, brand_name
from tt 
where model_year = 2018 
intersect 
select brand_id, brand_name
from tt 
where model_year = 2019



--- Write a query that returns customers who have orders for both 2018, 2019, and 2020.

with tt as (
    select o.order_id, c.customer_id, c.first_name, c.last_name, o.order_date
    from sale.orders o join sale.customer c on c.customer_id=o.customer_id
)
select customer_id, first_name, last_name
from tt 
where year(order_date) = 2018
intersect 
select customer_id, first_name, last_name 
from tt 
where year(order_date) = 2019
intersect
select customer_id, first_name, last_name
from tt 
where year(order_date) = 2020
order by last_name




--- Write a query that returns brands that have a 2018 model product but not a 2019 model product.

with tt as (
    select p.product_id, p.product_name, p.model_year, b.brand_id, b.brand_name
    from product.brand b join product.product p on b.brand_id=p.brand_id
)
select brand_id, brand_name
from tt 
where model_year = 2018
except
select brand_id, brand_name
from tt 
where model_year = 2019




--- Write a query that returns only products ordered in 2019 (not ordered in other years).

with tt as (
    select o.order_id, p.product_id, p.product_name, oo.order_date
    from sale.order_item o join product.product p on p.product_id=o.product_id
    join sale.orders oo on oo.order_id=o.order_id
)

select product_id, product_name 
from tt 
where year(order_date) = 2019
except 
select product_id, product_name
from tt 
where year(order_date) <> 2019
order by product_id




---Add a column to the sales.staffs table containing the store names of the employees.
---1. Sacramento Bikes, 2. Buffalo Bikes, 3. San Angelo Bikes

select st.first_name, st.last_name, s.store_id, 
case when s.store_id = 1 then 'Sacramento Bikes'
when s.store_id = 2 then 'Buffalo Bikes'
when s.store_id = 3 then 'San Angelo Bikes' end as Store_Name
from sale.staff st join sale.store s on st.store_id=s.store_id



---List customers who bought both “Electric Bikes” and “Comfort Bicycles” and “Children Bicycles” in the same order.

select first_name, last_name 
from sale.customer
where customer_id in
            (select customer_id 
            from sale.orders 
            where order_id in 
                   (select t1.order_id
                   from
                        (select distinct oo.order_id, c.category_id
                        from product.category c join product.product p on c.category_id=p.category_id
                        join sale.order_item o on o.product_id=p.product_id join
                        sale.orders oo on oo.order_id=o.order_id
                        where c.category_name in ('Electric Bikes', 'Comfort Bicycles', 'Children Bicycles')) as t1 
                        group by t1.order_id
                        having count(t1.category_id) = 3))
order by last_name

--- Create a new column that contains labels of the shipping speed of products.


select order_date, shipped_date, 
case when datediff(day, order_date, shipped_date) is null then 'Not Shipped'
when datediff(day, order_date, shipped_date) = 0 then 'Fast'
when datediff(day, order_date, shipped_date) >= 1 and 
datediff(day, order_date, shipped_date) <= 2 then 'Normal'
when datediff(day, order_date, shipped_date) >= 3 then 'Slow' end as Shipping_Speed
from sale.orders

--- Write a query that returns orders that are shipped more than two days after the ordered date.

select *
from
(select *, 
case when datediff(day, order_date, shipped_date) is null then 'Not Shipped'
when datediff(day, order_date, shipped_date) = 0 then 'Fast'
when datediff(day, order_date, shipped_date) >= 1 and 
datediff(day, order_date, shipped_date) <= 2 then 'Normal'
when datediff(day, order_date, shipped_date) >= 3 then 'Slow' end as Shipping_Speed
from sale.orders) as t1 
where t1.Shipping_Speed = 'Slow'


---Write a query that returns the number of distributions of the orders 
---in the previous query result, according to the days of the week.

select
sum(case when datename(weekday, t2.order_date) = 'Monday' then 1 else 0 end) Mo,
sum(case when datename(weekday, t2.order_date) = 'Tuesday' then 1 else 0 end) Tu,
sum(case when datename(weekday, t2.order_date) = 'Wednesday' then 1 else 0 end) We,
sum(case when datename(weekday, t2.order_date) = 'Thursday' then 1 else 0 end) Th,
sum(case when datename(weekday, t2.order_date) = 'Friday' then 1 else 0 end) Fr,
sum(case when datename(weekday, t2.order_date) = 'Saturday' then 1 else 0 end) Sa,
sum(case when datename(weekday, t2.order_date) = 'Sunday' then 1 else 0 end) Su        
from
    (select *
    from
    (select *, 
    case when datediff(day, order_date, shipped_date) is null then 'Not Shipped'
    when datediff(day, order_date, shipped_date) = 0 then 'Fast'
    when datediff(day, order_date, shipped_date) >= 1 and 
    datediff(day, order_date, shipped_date) <= 2 then 'Normal'
    when datediff(day, order_date, shipped_date) >= 3 then 'Slow' end as Shipping_Speed
    from sale.orders) as t1 
    where t1.Shipping_Speed = 'Slow') as t2



--- Write a query that returns the order numbers of the states by months.

select c.state, year(o.order_date), month(o.order_date), count(o.order_id) as num
from sale.orders o join sale.customer c on o.customer_id=c.customer_id
group by c.state, year(o.order_date), month(o.order_date)
order by c.state, year(o.order_date), month(o.order_date)




--- How many yahoo mails in customer’s email column? Use Case expression and Patindex function.

select
sum(case when patindex('%@yahoo%', email) <> 0 and patindex('%@yahoo%', email) is not null then 1 else 0 end) as yahoo
from sale.customer

---Soru_23: Write a query that returns the characters before the “.” character in the email column.

select email, substring(email, 1, charindex('.', email) - 1) as characters
from sale.customer



---Add a new column to the customers table that contains the customer’s contact information. 
---If the phone is available, the phone information will be printed, if not, the email information will be printed.

select customer_id, first_name, last_name, phone, email, 
case when phone is not null then phone else email end as contact 
from sale.customer



--- Write a query that returns streets. The third character of the streets is numerical.

select street,
case when isnumeric(substring(street, 3, 1)) = 1 then substring(street, 3, 1) else substring(street, 1, 1) end as third_char
from sale.customer




---Split the values in the email column into two parts with “@”

select email,
substring(email, 1, charindex('@', email) - 1) as left_part, 
substring(email, charindex('@', email) + 1, len(email)) as right_part
from sale.customer