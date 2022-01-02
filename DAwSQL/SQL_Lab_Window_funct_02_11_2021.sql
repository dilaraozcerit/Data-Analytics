----SQL LAB 02.11.2021-----


---1) Find the weekly order count for the city of San Angelo for the last year, and also the cumulative total.
---Desired output: [week_start, order_count, cuml_order_count]

select *
from sale.orders a, sale.store b
where a.store_id = b.store_id
	  and b.city = 'San Angelo'
	  and a.order_date between dateadd(week, -52, '2020-12-28') and '2020-12-28'

select max(order_date)
from sale.orders -->>> returns '2020-12-28'


