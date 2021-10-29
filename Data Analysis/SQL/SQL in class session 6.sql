--- SQL session-6 ( Date & String Functions )


CREATE TABLE [dbo].[t_date_time](
	[A_time] [time](7) NULL,
	[A_date] [date] NULL,
	[A_smalldatetime] [smalldatetime] NULL,
	[A_datetime] [datetime] NULL,
	[A_datetime2] [datetime2](7) NULL,
	[A_datetimeoffset] [datetimeoffset](7) NULL
)



INSERT t_date_time
VALUES (GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE())
---------------------

select A_time, A_date, GETDATE(),
		DATEDIFF(MINUTE, A_time, GETDATE() )
		DATEDIFF(Week, A_date, '2021-11-30') AS WEEK_DIFF
from t_date_time



------------ DATEDIFF ----------------------

select ABS(DATEDIFF(DAY, shipped_date, order_date)) DATE_DIFF, order_date, shipped_date
from sale.orders


select DATEDIFF(DAY, shipped_date, order_date) DATE_DIFF, order_date, shipped_date
from sale.orders


-----------DATEADD------------------

select order_date,
	dateadd(year, 5, order_date) --- her bir yýla +5 yýl ekledik
	dateadd(day, 10, order_date  --- her bir güne +5 gün ekledik
from sale.orders

select getdate(), dateadd(hour, 5, getdate())   ---5 saat ekledik þimdiki zamanýmýza



---EOMONTH

select eomonth(getdate()), eomonth(Getdate(),2)




------

select isdate('2021-10-01')


select isdate ('select')



-----
--Orders tablosuna sipariþlerin teslimat hýzýyla ilgili bir alan ekleyin.
--Bu alanda eðer teslimat gerçekleþmemiþse 'Not Shipped',
--Eðer sipariþ günü teslim edilmiþse 'Fast',
--Eðer sipariþten sonraki iki gün içinde teslim edilmiþse 'Normal'
--2 günden geç teslim edilenler ise 'Slow'
--olarak her bir sipariþi etiketleyin.

WITH T1 AS
(
SELECT *,
		DATEDIFF(DAY, order_date, shipped_date) DIFF_SHIPPED_AND_ORDER
FROM	sale.orders
)
SELECT ORDER_DATE,
		shipped_date,
		CASE WHEN DIFF_SHIPPED_AND_ORDER IS NULL THEN 'Not Shipped'
			 WHEN DIFF_SHIPPED_AND_ORDER = 0 THEN 'Fast'
			 WHEN DIFF_SHIPPED_AND_ORDER <= 2 THEN 'Normal'
			 WHEN DIFF_SHIPPED_AND_ORDER > 2 THEN 'Slow'
		END AS Order_Label
FROM	T1




---2 günden geç teslim edilen sipariþlerin bilgisini getiriniz.

select * 
from 
sale.orders o join 
(select order_id, datediff(day, order_date, shipped_date) as gun
from sale.orders
where datediff(day, order_date, shipped_date) > 2) as a 
on o.order_id=a.order_id

SELECT *, DATEDIFF(DAY, Order_date, shipped_date) DAY_DIFF 
FROM sale.orders
WHERE DATEDIFF(DAY, Order_date, shipped_date) > 2



--- haftanýn günlerine göre daðýlýmý

SELECT	SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Monday' THEN 1 END) MONDAY,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Tuesday' THEN 1 END) Tuesday,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Wednesday' THEN 1 END) Wednesday,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Thursday' THEN 1 END) Thursday,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Friday' THEN 1 END) Friday,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Saturday' THEN 1 END) Saturday,
		SUM(CASE WHEN DATENAME(WEEKDAY, order_date) = 'Sunday' THEN 1 END) Sunday
FROM	sale.orders
WHERE	DATEDIFF(DAY, order_date, shipped_date) > 2





-------String Functions

select len('welcomeee')


---charindex

select CHARINDEX('C', 'Character')


select Charindex('C', 'Character', 2)


----Patindex

select patindex('R', 'character')

select patindex('%R%', 'character')

select patindex('___R%', 'character')


----right

select right('character', 1)

select right('character', 3)


---substring
select SUBSTRING('character', 1,3)

select SUBSTRING('character', -1,3)

select SUBSTRING('character', 1,3)


---Lower

select lower('cHAracter')


---title

SELECT UPPER(LEFT('character',1))+LOWER(SUBSTRING('character',2,LEN('character')))


-------------
---string_split
select * from string_split ('Ali, Mehmet, Ayþe', ',')



----Trim, Ltrim, Rtrim

select trim('  chara  cter ')


select trim('    chara  cter ')


SELECT LTRIM('     CHARA CTER ')


SELECT RTRIM('     CHARA CTER ')