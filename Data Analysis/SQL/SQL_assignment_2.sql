--a.	Create above table (Actions) and insert values,

create table Actions(
    Visitor_ID int,
    Adv_Type Varchar(15),
    Action_ Varchar(15)
    )
insert table Actions (Visitor_ID, Adv_Type, Action_)
values
(1,'A','Left'),
(2,'A','Order'),
(3,'B','Left'),
(4,'A','Order'),
(5,'A','Review'),
(6,'A','Left'),
(7,'B','Left'),
(8,'B','Order'),
(9,'B','Review'),
(10,'A','Review');


select *
from actions




---b.	Retrieve count of total Actions, and Orders for each Advertisement Type,
select b.adv_type, a.total_action, b.orders
from
(select adv_type, count(action_) as total_action
from actions
group by adv_type) as a
inner join 
(select adv_type, count(action_) as orders
from actions
where action_ = 'Order'
group by adv_type) as b
on a.adv_type = b.adv_type)



---c.	Calculate Orders (Conversion) rates for each Advertisement Type by 
--dividing by total count of actions casting as float by multiplying by 1.0.

SELECT Adv_Type, ROUND(CAST( num_order as float)/CAST (num_action as float), 2)  AS Conversion_Rate
​
FROM

(SELECT  Adv_Type, COUNT(Action_) as num_action,
SUM(CASE When Action_ = 'Order' THEN 1 ELSE 0 END ) as num_order 
FROM Actions
WHERE Adv_Type = 'A'
GROUP BY Adv_Type
​
UNION
​
SELECT  Adv_Type, COUNT(Action_) as num_action,
SUM(CASE When Action_ = 'Order' THEN 1 ELSE 0 END ) as num_order 
FROM Actions
WHERE Adv_Type = 'B'
GROUP BY Adv_Type
) new_table

--The CAST() function converts a value (of any type) into a specified datatype.
-- bkz. SELECT CAST('2017-08-25' AS datetime);