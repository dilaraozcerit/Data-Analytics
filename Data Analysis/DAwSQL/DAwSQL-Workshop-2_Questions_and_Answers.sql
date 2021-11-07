-- DAwSQL - Workship-2 Notes

-- Window Functions, partition by, order by, aggregate window functions, window frames

select product_id, model_year, list_price,
sum(list_price) over() as total_price,
sum(list_price) over(partition by model_year) as price_by_year,
sum(list_price) over(partition by model_year order by product_id) as cumulative,
sum(list_price) over(partition by model_year order by product_id rows between 1 preceding and 1 following) as window
from product.product;

select product_id, model_year, sum(list_price) as total_price 
from product.product 
group by product_id, list_price, model_year

--------------------------
-- Lead, lag, first_value, last_value, nth_value 

-- First_value, Last_value

select list_price,
first_value(list_price) over(order by list_price) as first_value_by_listprice,
-- first_value(list_price) over(partition by model_year order by list_price) as first_value_by_modelyear,
last_value(list_price) over(order by list_price) as last_price_by_listprice,
first_value(list_price) over(order by list_price rows between 3 preceding and 3 following) first_by_3window,
last_value(list_price) over(order by list_price rows between 3 preceding and 3 following) as last_by_3window
from product.product;

select list_price 
from product.product 
where model_year = 2018
order by list_price;

select list_price,
first_value(list_price) over(partition by model_year order by list_price) as first_value_by_modelyear,
last_value(list_price) over(partition by model_year order by list_price) as last_price_by_listprice,
first_value(list_price) over(partition by model_year order by list_price rows between 3 preceding and 3 following) first_by_3window,
last_value(list_price) over(partition by model_year order by list_price rows between 3 preceding and 3 following) as last_by_3window
from product.product;

-- Lead, lag

select product_id, list_price,
sum(list_price) over() as total,
sum(list_price) over(order by product_id) as cumulative,
lag(list_price, 2) over(order by product_id) as iki_oncesi,
lead(list_price, 3) over(order by product_id) as bir_sonrasi,
sum(list_price) over(order by product_id rows between 1 preceding and 1 following) as uclu
from product.product
order by product_id;

-----------------------------
-- Row_number, rank, dense_rank, cume_dist, percent_rank, ntile

select product_id, model_year, list_price, 
row_number() over(order by product_id) as row_1,
row_number() over(partition by model_year order by product_id) as row_2
from product.product

select model_year, list_price,
rank() over(order by list_price) as ranked,
dense_rank() over(order by list_price) as dense_ranked
from product.product

select product_id,
cume_dist() over(order by product_id) as cume_disted,
percent_rank() over(order by product_id) as p_ranked
from product.product

select product_id, list_price, model_year,
ntile(10) over(partition by model_year order by list_price desc) as tiled
from product.product

----------------------------------
-- Question-1
-- Find the weekly order count for the city of San Angelo for the last 52 weeks, and also the cumulative total.
-- Desired output: [week_number, order_count, cuml_order_count]

select distinct datename(week, o.order_date) as week_number,
count(o.order_id) over(partition by datename(week, o.order_date)) as total,
count(o.order_id) over(order by datename(week, o.order_date)) as weekly_cumulative
from sale.orders o join sale.store ss on o.store_id=ss.store_id
where ss.city = 'San Angelo' and
o.order_date between dateadd(year, -1, (select max(order_date) from sale.orders)) and (select max(order_date) from sale.orders);
----
select distinct cast(datename(week, o.order_date) as integer) as week_number,
count(o.order_id) over(partition by cast(datename(week, o.order_date) as integer)) as total,
count(o.order_id) over(order by cast(datename(week, o.order_date) as integer)) as weekly_cumulative
from sale.orders o join sale.store ss on o.store_id=ss.store_id
where ss.city = 'San Angelo' and
o.order_date between dateadd(year, -1, (select max(order_date) from sale.orders)) and (select max(order_date) from sale.orders);

----------------------------------
-- Question-2
-- Calculate 7-day moving average of the number of products sold between '2018-03-12' and '2018-04-12'

select t.order_date, t.sum_q,
-- avg(t.sum_q) over (order by t.order_date) as moving,
avg(t.sum_q) over (order by t.order_date rows between 6 preceding and current row) as moving
from 
    (select distinct o.order_date,
    sum(i.quantity) over(partition by o.order_date) as sum_q
    from sale.orders o join sale.order_item i on o.order_id=i.order_id
    where o.order_date between '2018-03-12' and '2018-04-12') as t

----------------------------------
-- Question-3
-- Identify the bikes by gender and find the total counts and average prices of bikes by gender
-- [gender, count_bikes_by_gender, average_price_by_gender]

select distinct product_id, product_name,
case when tt.women_girl = 1 then 'Women' else 'Men' end as gender,
case when tt.women_girl = 1 then sum(tt.women_girl) over() else count(tt.women_girl) over() - sum(tt.women_girl) over() end as count_bikes_by_gender,
avg(tt.list_price) over(partition by tt.women_girl) as average_price_by_gender
from
    (select product_id, product_name, list_price,
    case when patindex('%irl%', product_name) <> 0 or patindex('%omen%', product_name) <> 0  or patindex('%adies%', product_name) <> 0 then 1 else 0 end as women_girl
    from product.product) as tt
order by product_id

select product_name 
from product.product

---------------------------------
-- Question-4
-- List the staff information in the ascending order according to their performance.
-- Determine their performance according to how long they waited to receive their next order.
-- [staff_id, first_name, last_name, previous_order, next_order, days_waited, cumulative_days, average_days]

select t.staff_id, t.first_name, t.last_name, t.previous_order, t.next_order, t.days,
sum(t.days) over (partition by t.staff_id order by(t.next_order)) as cumulative,
avg(t.days) over (partition by t.staff_id) as avg_days
from
    (select st.staff_id, st.first_name, st.last_name, o.order_date as previous_order,
    lead(o.order_date) over(partition by st.staff_id order by o.order_date) as next_order,
    datediff(day, o.order_date, lead(o.order_date) over(partition by st.staff_id order by o.order_date)) as days
    from sale.staff st join sale.orders o on st.staff_id=o.staff_id) as t
order by avg_days

----------------------------------
-- Question-5
-- In the street column, clear the string characters that were accidentally added to the end of the initial numeric expression.

select t1.street, 
case when isnumeric(right(t1.subs, 1)) = 0 then substring(t1.subs, 1, len(t1.subs) - 1) else t1.subs end as [target],
case when isnumeric(right(t1.subs, 1)) = 0 then substring(t1.subs, 1, len(t1.subs) - 1) else t1.subs end
 + ' ' + substring(street, charindex(' ', street) + 1, len(street)) as new_street_name
from 
	(select street, substring(street, 1, charindex(' ', street) - 1) as subs
	from sale.customer) as t1
-- where isnumeric(right(t1.subs, 1)) = 0

-----------------------------------
-- Question-6
-- Let's talk a little bit about recursive CTEs

with recur as 
(
    select 1 as num, 1 as num_2 
    union all 
    select num + 1, num_2 * 2 
    from recur 
    where num < 10
)
select * from recur

--

WITH Recursive_CTE AS (
    
    SELECT 10 AS counter
    UNION ALL
    SELECT counter - 1
    FROM Recursive_CTE
    WHERE counter > 0
)
SELECT REPLICATE('* ', counter)
FROM Recursive_CTE

--

WITH Recursive_CTE AS (
    
    SELECT 1 AS c1, 10 AS c2, 1 AS c3, 10 AS c4
    UNION ALL
    SELECT c1 + 1, c2 - 1, c3 + 1, c4 - 1
    FROM Recursive_CTE
    WHERE c1 < 10
)
SELECT REPLICATE('1', c1), REPLICATE('2', c2), REPLICATE('3', c3), REPLICATE('4', c4),
REPLICATE('1', c1) + '-' + REPLICATE('2', c2) + '-' + REPLICATE('3', c3) + '-' + REPLICATE('4', c4)
FROM Recursive_CTE

--
-- If we want to select order_ids three by three
with recur as 
(
    select 1 as num 
    union all 
    select num + 3
    from recur 
    where num < 100
)
select num, t.order_id, t.order_date, t.shipped_date 
from recur join (select * from sale.orders) as t on recur.num=t.order_id

-------------------------------------
-- Question-7
-- List order_id, product_id and list_price of the first order of each day

select t.order_id, t.product_name, t.order_date, t.indexing, t.list_price
from
    (select o.order_id, p.product_name, o.order_date, p.list_price, 
    row_number() over(partition by o.order_date order by o.order_id, p.list_price) as indexing
    from sale.orders o join sale.order_item so on o.order_id=so.order_id join product.product p on p.product_id=so.product_id) as t 
where t.indexing = 1

-------------------------------------
-- Question-8
-- How can we join two tables that do not have shared columns?

select brand_id, brand_name from product.brand
select staff_id, first_name, last_name, email from sale.staff

select * 
from
(select brand_id, brand_name, row_number () over(order by brand_id) as index_1 from product.brand) as T1 join
(select staff_id, first_name, last_name, email, row_number() over(order by staff_id) as index_2 from sale.staff) as T2 on T1.index_1=T2.index_2

-------------------------------------
-- Question-9
-- Calculate the stores' weekly cumulative number of orders for 2018

select distinct s.store_id, s.store_name, datepart(week, o.order_date) as week,
count(o.order_id) over (partition by s.store_id, datepart(week, o.order_date)) as weekly_sum,
count(o.order_id) over (partition by s.store_id order by datepart(week, o.order_date)) as cum_sum
from sale.orders o join sale.store s on o.store_id=s.store_id
where year(o.order_date) = 2018
order by s.store_id, week

-------------------------------------
-- Question-10

-- Write a query that returns both of the followings:
-- - The average product price of orders
-- - Average net amounts of orders

select distinct o.order_id, p.list_price,
avg(p.list_price) over(partition by o.order_id) as avg_price,
avg(p.list_price * oo.quantity * (1-oo.discount)) over () as avg_net_amount
from sale.orders o join sale.order_item oo on o.order_id=oo.order_id 
join product.product p on p.product_id=oo.product_id

--------------------------------------

-- Question-11 
-- Rearrange the email addresses of customers
-- last_name.name >> if yahoo, change to hotmail; if gmail, change to yahoo; if hotmail, change to gmail; if otherwise, change to clarusway

select email,
substring(substring(email, 1, charindex('@', email) - 1), 1, charindex('.', substring(email, 1, charindex('@', email) - 1)) - 1) as first,
substring(substring(email, 1, charindex('@', email) - 1), charindex('.', substring(email, 1, charindex('@', email) - 1)) + 1, 
len(substring(email, 1, charindex('@', email) - 1))) as last,
substring(substring(email, 1, charindex('@', email) - 1), charindex('.', substring(email, 1, charindex('@', email) - 1)) + 1, 
len(substring(email, 1, charindex('@', email) - 1))) + '.' + 
substring(substring(email, 1, charindex('@', email) - 1), 1, charindex('.', substring(email, 1, charindex('@', email) - 1)) - 1) + '@' +
case 
when patindex('%@yahoo%', email) <> 0 then 'hotmail.com'
when patindex('%@gmail%', email) <> 0 then 'yahoo.com'
when patindex('%@hotmail%', email) <> 0 then 'gmail.com' 
else 'clarusway.com' end as newmail
from sale.customer

----------------------------------------
-- Question-12

-- Is there store-level differences in the shopping attiudes of the customers who drive more to buy bicycles than drive less
-- [distance, store_state, store_name, total_sum_by_distance, avg_by_store, total_sum_by_store]

select distinct t.close_to_store, t.store_state, t.store_name,
sum(t.list_price) over(partition by t.close_to_store, t.store_name) as drive_level_sum,
avg(t.list_price) over(partition by t.close_to_store, t.store_name) as drive_level_avg,
sum(t.list_price) over(partition by t.store_name) as store_level
from
(select o.order_id, c.zip_code as zip_home, c.state as home_state, st.zip_code as zip_store, st.state as store_state, p.list_price, st.store_name,
case when c.zip_code = st.zip_code then 1 else 0 end as close_to_store
from sale.customer c join sale.orders o on c.customer_id=o.customer_id join sale.store st on st.store_id=o.store_id
join sale.order_item oo on o.order_id=oo.order_id join product.product p on p.product_id=oo.product_id) as t
order by t.store_state, t.store_name;

--group by versiyonu
select t.close_to_store, t.store_name, sum(t.list_price), avg(t.list_price)
from
(select o.order_id, c.zip_code as zip_home, c.state as home_state, st.zip_code as zip_store, st.state as store_state, p.list_price, st.store_name,
case when c.zip_code = st.zip_code then 1 else 0 end as close_to_store
from sale.customer c join sale.orders o on c.customer_id=o.customer_id join sale.store st on st.store_id=o.store_id
join sale.order_item oo on o.order_id=oo.order_id join product.product p on p.product_id=oo.product_id) as t
group by t.close_to_store, t.store_name

-------------------------------------
