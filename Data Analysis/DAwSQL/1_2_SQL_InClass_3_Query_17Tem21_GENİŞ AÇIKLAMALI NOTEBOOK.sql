------DAwSQL 17.07.2021 Session 3 (Organize Complex Queries)-------

-- Bir tabloda meydana gelen sonucu ba�ka bir tablo veya i�lem i�in kullanmak i�in 3 y�ntem:
	-- Subqueries
	-- Views
	-- Common Table Expression (CTE's)

-- subqueries, SELECT, FROM ve WHERE sat�rlar�nda kullan�labiliyor.
	-- WHERE'de subquery sonucunda d�nen ifadelere g�re ana tablo �zerinden bir filtreleme yapaca��n anlam�na geliyor.
		--WHERE'in her zaman ana tablo �zerinde filtreleme yapt���n� unutma!
	-- SELECT'te subquery i�indeki de�eri SELECT sat�r�nda d�nd�rmek i�in kullan�l�yor
	-- SELECT sat�r�ndaki subquery TEK B�R S�TUN VEYA SATIR D�ND�RMEK ZORUNDA! (sadece bir de�er d�nd�rmeli)
	-- FROM da subquery bir tablo getirmesi laz�m. ba�ka k�staslara g�re bir tablo olu�uruyor ve bunu Fromda kullanmak �zere getiriyor.

	-- SUBQUERY �E��TLER�
		-- Single-row  : Tek bir sat�r d�nd�r�r. SELECT'te kullan�lan gibi. 
		-- Multiple-row: Birden fazla de�er d�nd�ren subquery
		-- Correlated : �stteki sorgu ile alltaki sorgunun birbiri ile e�lenerek ba�lant� kuruldu�u subquery

	-- SINGLE-ROW SUBQUERY
		-- =, <, >, >=, <=, <>, != operat�rleri ile �zellikle WHERE sat�r�nda kullan�lan subquerylerdir.


-------------- PIVOT -----------

-- Pivot, sat�r bazl� analiz sonucunu s�tun baz�na d�n��t�r�lmesini sa�l�yor. 
	-- group by gibi bir gruplama yap�yor. dolay�s�la group by kullanm�yoruz, pivota �zel bir syntax kullan�yoruz
	-- bu syntax i�erisinde aggregate i�lemi yap�p ilgili s�tunlardaki kategorilere g�re bir pivot table olu�turuyor.
	-- ve o s�tunun sat�rlar�n� olu�turan her bir kategoriyi birer s�tuna d�n��t�r�yor. yani sat�rlardaki value'lar s�tunlarda sergileniyor

-- Pivot tablosunda s�tun ve value olarak g�z�kmesini istedi�im s�tunlar� (feature'lar�) Pivot'un �st�ndeki SELECT sat�r�na ekliyorum.
	--Bunlardan VALUE olacak olan s�tununa Pivot ile ba�layan kod blo�unda AGGRAGATE i�lemi uyguluyorum.
	-- Unutmayal�m ki pivot table, group by i�leminin ayn�s�n� yap�yor. Aggregate i�lemi de oradan geliyor.

-- E�er kaynak tablomdaki bir s�tun hem value'lar i�in kullan�lacak (aggregate yap�lacak) hem de ayr� bir boyut olarak kullan�lacak ise;
	-- SELECT sat�r�nda bu s�tun iki kere yaz�lmal� (biri ilave boyut i�in di�eri value'lar� olu�turmak i�in)
	-- Fakat "The column 'xxxxxx' was specified multiple times" hatas� almamak i�in birine "Alias" (takma ad) verilmeli!!! �rne�i a�a��da 

--SYNTAX
SELECT [column_name], [pivot_value1], [pivot_value2], ...[pivot_value_n]
FROM
table_name
PIVOT
(
aggregate_function(aggregate_column)
FOR pivot_column
IN ([pivot_value1], [pivot_value2], ... [pivot_value_n])
) AS pivot_table_name;


--�RNEK:

SELECT *
FROM sales.sales_summary

-- �nce kaynak tabloyu olu�turuyoruz. ben pivot table'� veya aggregate i�lemini hangi tablodan olu�turmak istiyorum?
-- ben kategorilere g�re toplam fiyatlar� bulmak istiyorum.
SELECT category, SUM(total_sales_price)
FROM sales.sales_summary
GROUP BY Category

-- �imdi category s�tununun sat�rlar�n� (bisiklet kategorilerini) s�tunlara alacak 
-- ve total_sales_price'lar� value olarak sat�rlara getirecek �ekilde pivot table yapal�m
SELECT *
FROM sales.sales_summary
PIVOT
(
	SUM(total_sales_price)
	FOR category IN  -- burada belirledi�imiz pivot column'un, gruplad���m�z column oldu�una dikkat et.
	(
	[Children Bicycles], -- category s�tunu alt�nda bu kategoriler vard�. bunlar pivot table �n s�tunlar� olacak.
    [Comfort Bicycles], 
    [Cruisers Bicycles], 
    [Cyclocross Bicycles], 
    [Electric Bikes], 
    [Mountain Bikes], 
    [Road Bikes])
	) AS PIVOT_TABLE  -- pivot table'a bir isim vermemiz gerekiyor.

-- �imdi son dokunu�larla bu kodu biraz daha spesifik hale getirelim.

-- �nce kaynak tabloyu belirtiyoruz. kaynak tablom bu query:
SELECT Category, total_sales_price
FROM sales.sales_summary

--- �imdi Pivot i�lemi sonucunda ortaya ��kacak tablo i�in  bir SELECT i�lemi daha yapmam gerekiyor.
SELECT *  
FROM 
(SELECT Category, total_sales_price  -- bu parantezin i�i kaynak tablom.
FROM sales.sales_summary
) A
PIVOT
(
	SUM(total_sales_price)
	FOR category	-- pivot s�tunumuz category, ve value'lar�m�z bu s�tundaki bisiklet modelleri olacak
	IN(
	[Children Bicycles], 
    [Comfort Bicycles], 
    [Cruisers Bicycles], 
    [Cyclocross Bicycles], 
    [Electric Bikes], 
    [Mountain Bikes], 
    [Road Bikes])
	) AS PIVOT_TABLE

-- ben buna bir boyut daha eklemek istersem..
	-- category s�tununa g�re gruplam��t�k. bir de model_year gruplamas� olsun.
SELECT category, model_year, SUM(total_sales_price)
FROM sales.sales_summary
GROUP BY Category, Model_Year
ORDER BY 1  -- bir de order by ekleyelim g�zel g�z�ks�n.
--- �imdi bir k�r�lma daha bir boyut daha eklemi� olduk. �nceden sadecec kategorilere g�re ay�r�m yap�yordu
	-- �imdi ise kategorilerin i�inde model y�llara g�re de ay�r�m yapt�k.

-- model_year boyutunu pivot table'a ekleyip g�relim.
	-- kaynak tablomun SELECT sat�r�na model_year s�tununu eklemeliyim.
SELECT category, Model_Year, total_sales_price 
			FROM SALES.sales_summary

SELECT *
FROM
			(
			SELECT category, Model_Year, total_sales_price --model_year eklendi.
			FROM SALES.sales_summary
			) A
PIVOT
(
	SUM(total_sales_price)
	FOR category IN
	(
	[Children Bicycles], 
    [Comfort Bicycles], 
    [Cruisers Bicycles], 
    [Cyclocross Bicycles], 
    [Electric Bikes], 
    [Mountain Bikes], 
    [Road Bikes])
	) AS PIVOT_TABLE
-- g�r�ld��� gibi g�rsel olarak �ok rahat okunan bir tablo elde ettik.


-- -------------------
CREATE VIEW Brands_Categories AS
SELECT	category_name, brand_name
FROM
	(
	SELECT
		C.category_name AS category_name,
		A.brand_name AS brand_name
	FROM production.brands A, production.products B, production.categories C
	WHERE A.brand_id = B.brand_id AND B.category_id = c.category_id
	GROUP BY C.category_name, A.brand_name
	) A
;

SELECT *
FROM
	(
	SELECT	category_name, brand_name
	FROM	Brands_Categories
	) A
PIVOT
(
COUNT(brand_name)
FOR	category_name
IN	(
	[Children Bicycles],
        [Comfort Bicycles],
        [Cruisers Bicycles],
        [Cyclocross Bicycles],
        [Electric Bikes],
        [Mountain Bikes],
        [Road Bikes]
	)
) AS PIVOT_TABLE

-- BU P�VOT TABLOSUNDA MARKA �S�MLER�N� DE AYRI B�R BOYUT OLARAK KATALIM.
	-- Bunun i�in brand_name'i SELECT'te eklemem yeterli. ancak orada brand_name aggregate i�lemi i�in yani
	-- value'ler i�in kullan�ld��� i�in ikinci kez ekledi�imde buna Alias vermem gerekiyor!!
SELECT *
FROM
	(
	SELECT	category_name, brand_name AS BRAND_NAMES, brand_name -- 2. kere kulland���mda brand_name'e alias verdim.
	FROM	Brands_Categories
	) A
PIVOT
(
COUNT(brand_name)
FOR	category_name
IN	(
	[Children Bicycles],
        [Comfort Bicycles],
        [Cruisers Bicycles],
        [Cyclocross Bicycles],
        [Electric Bikes],
        [Mountain Bikes],
        [Road Bikes]
	)
) AS PIVOT_TABLE





----------------------- KONU: SUBQUERY -----------------

-- SORU 1 : Bring all the personnels from the store that Kali Vargas works.
-- (TR) Kali Vargas'�n �al��t��� ma�azadan t�m personeli getirin.

------------SINGLE ROW SUBQUERIES----------------

SELECT *
FROM sales.staffs --t�m �al��anlar� ve �al��t�klar� ma�azalar� getirdim. 8.sat�rda Kali Vargas� ve �al��t��� store'un id sini g�rebiliyorum.

SELECT *
FROM sales.staffs
WHERE first_name = 'Kali' AND last_name = 'Vargas' 
-- staffs tablosunda first_name Kali ve last_name Vargas olan sat�r� getir dedik.
-- ve store_id sinin 3 oldu�unu g�rd�k. A�a��da WHERE store_id=3 d e diyebiliriz.

-- staffs tablosunda store_id= (subquery'den gelen store_id) �eklinde bir query kuraca��z.
SELECT *
FROM sales.staffs
WHERE store_id = (SELECT store_id
				  FROM sales.staffs
				  WHERE first_name = 'Kali' and last_name = 'Vargas')




-- SORU 2: List the staff what Venita Daniel is the manager of.
-- (Tr) Venita Daniel'in y�neticisi oldu�u personeli listeleyin.

-- Venita Daniel'in staff_id si kimin manager_id'si ise onlar� listeleyece�iz.
SELECT *
FROM sales.staffs
WHERE manager_id = (                -- Venita'n�n staff id sinin manager_id si olan personeli tan�mlad�k.
					SELECT staff_id		
					FROM sales.staffs
					WHERE first_name = 'Venita' AND last_name = 'Daniel' -- subquery'de Venita'n�n staff id sini �ektik.
					)

-- alternatif ��z�m (self join ile):
SELECT A.*
FROM sales.staffs A, sales.staffs B
WHERE A.manager_id = B.staff_id
AND B.first_name = 'Venita' AND B.last_name = 'Daniel'
-- burada A.manager_id = B.staff_id dedi�imiz i�in (yani A'nin manager_id'si B'nin staff_id'si olanlara e�it olma durumu) B.first_name='Venita' yapt�k. 
	-- e�er A.first_name='Venita' deseydik (yani A'daki first_name Venita olsun deseydik) Venita'n�n manager'�n� getirirdi bize.



-- SORU 3: Write a query that returns customer in the city where the 'Rowlett Bikes' store is located.
-- (TR) 'Rowlett Bikes' ma�azas�n�n bulundu�u �ehirde m��teriyi d�nd�ren bir sorgu yaz�n.

-- �nce Rowlet Bikes store'un bulundu�u city'i bulal�m. (sales.stores tablosunda city isimleri var)
SELECT city
FROM sales.stores
WHERE store_name = 'Rowlett Bikes' 
-- Rowlet �ehrinde oldu�unu g�rd�k. bu query a�a��da ana query'mizin subquery'si olacak.

-- �imdi sales.custormers tablosunda city=Rowlet olan verileri g�relim.
SELECT *
FROM sales.customers
WHERE city= (
			SELECT city
			FROM sales.stores
			WHERE store_name = 'Rowlett Bikes'
			)



-- SORU 4: List bikes that are more expensive than the 'Trek CrossRip+ - 2018' bike
-- TR: 'Trek CrossRip - 2018' bisikletinden daha pahal� olan bisikletleri listeleyin

--�nce subquery'i belirlemekle ba�layal�m. bahsedilen bisikletin fiyat�n� �ekelim.
select list_price
from production.products 
where product_name = 'Trek CrossRip+ - 2018',

-- �imdi listenmesi istenen s�tunlar�n hangi listelerde oldu�una bakarak o listeleri join edece�im 
	-- ve subquery'i WHERE sat�r�nda yerine koyarak query'mi olu�turaca��m.
	-- istenen s�tunlar: product_id, product_name, model_year, list_price, brand_name, category_name
SELECT DISTINCT A.product_id, A.product_name, A.model_year, A.list_price, B.brand_name, C.category_name
FROM production.products AS A, production.brands AS B, production.categories AS C
WHERE A.brand_id = B.brand_id AND A.category_id = C.category_id
AND list_price > (SELECT list_price
					FROM production.products
					WHERE product_name= 'Trek CrossRip+ - 2018')
-- WHERE sat�r�mda hem listelerimi join ettim hem de SUBQUERY kullanarak filtreleme �art�m� ekledim.
-- DISTICT att�m ki tekrarlayan s�tunlar gelmesin. 
	-- Ancak burda DISTINCT atmadan da ayn� sonuca ula��yorum, ��nk� tekrar yok. 
	-- DISTINCT maliyetli bir i�, SQL e ekstra i�lem ve y�k getiren bir i� bu y�zden burda DISTINCT kullanmamam laz�m. 
	-- Genelde DISTINCT'i bir aggregation i�lemi yapm�yorsak en son sonu� tablosunda, sonu� select'in de kullan�r�z. 
	-- �nceki select lerde kullanmay�z.





-- SORU 5: List customers who orders previous dates than Arla Ellis.
-- (TR) Arla Ellis'ten �nceki tarihlerde sipari� veren m��terileri listeleyin.

-- �nce Arla Ellis'in sipari� verdi�i tarihi bulal�m ki onu ana query de subquery olarak kullanabilelim. 
	-- tarihler orders tablosunda, isimler customers tablosunda oldu�u i�in orders ve customers tablolar�n� birle�tirmem gerekiyor.
SELECT *
FROM sales.customers A, sales.orders B
WHERE A.customer_id = B.customer_id
and A.first_name = 'Arla' and A.last_name='Ellis'
-- bu isimle tek bir customer var ve bir order var
-- bu sorgunun sonu�lar�ndan order_date i alaca��m ve bu sonucu da subquery yap�p 
-- arad���m�z order_date'in bu subquery'den gelen date'ten �nce olma durumunu < operat�r� ile sorgulayaca��z.


-- �imdi istenen s�tunlarla birlikte query'mizi yazal�m ve WHERE sat�r�ndaki condition'da yukardaki subquery'i kullanal�m.
SELECT A.customer_id, A.first_name, A.last_name, B.order_date
FROM sales.customers A, sales.orders B
WHERE order_date < (
					SELECT B.order_date
					FROM sales.customers A, sales.orders B
					where A.customer_id = B.customer_id
					and A.first_name = 'Arla' and A.last_name='Ellis'
					)

--------------- MULTIPLE ROW SUBQUERIES -------------------
	--Birden �ok de�er d�nd�ren subquerylerdir.
	-- Bir�ok de�er i�erisinden bir de�er ar�yor ve onlar i�erisinde bir filtreleme yapacaksam IN, NOT IN, ANY ve ALL operat�rlerini kullan�yorum.

					

-- SORU 6 : List order dates for customers residing in the Holbrook city.
-- (TR) Holbrook �ehrinde oturan m��terilerin sipari� tarihlerini listeleyin.

-- bunu JOIN ile de yapabiliriz ama buda subquery ile yapaca��z.

-- �nce Holbrook �ehrindeki customer id leri g�relim.
select customer_id
from sales.customers 
where city='Holbrook'

-- orders tablosunda 1615 order_date var.
SELECT order_date
FROM sales.orders

-- yukardaki query'i subquery yaparak order_date'i filtreleyelim 
	--ve sadece Holbrook �ehrinde ya�ayan customer'lar�n order_date lerini getirsin.
SELECT order_date
FROM sales.orders
WHERE customer_id IN (
					SELECT customer_id
					FROM sales.customers 
					WHERE city='Holbrook'
					)
-- Holbrook �ehrinde ya�ayan m��terilere ait 3 order_date oldu�unu g�rd�m.

-- NOT IN ile yaparsak Holbrook d���nda ya�ayanlar�n tarihlerini getirecektir.
SELECT order_date
FROM sales.orders
WHERE customer_id NOT IN (
					  SELECT customer_id
					  FROM sales.customers
					  WHERE city = 'Holbrook'
					  )




-- SORU 7: List products in categories other than Cruisers Bicycles, Mountain Bikes, or Road Bikes.
-- (TR) �r�nleri Cruisers Bicycles, Mountain BikeS veya Road Bikes DI�INDAK� kategorilerde listeleyin.


SELECT category_id
FROM	production.categories
WHERE	category_name IN ('Cruisers Bicycles', 'Mountain Bikes', 'Road Bikes')
-- bu kategorilerin categori id lerini �ektim. bunu ana query de WHERE sat�r�nda kullanaca��m.

SELECT *
FROM production.products A, production.categories B
WHERE A.category_id = B.category_id and category_name IN (
							SELECT category_name
							FROM production.categories
							WHERE category_name NOT IN ('Cruisers Bicycles', 'Mountain Bikes', 'Road Bikes')
							)
order by product_id --buna gerek yoktu, s�ral� olmas� i�in kulland�m.
-- asl�nda benden sadece product lar� istedi�i i�in burada category_id ve category_name s�tunlar�n� getirmeme gerek yoktu. 
	-- bu durumda fazladan bir join i�lemi yapm�� oldum. 
	-- joinsiz olarak ��z�m daha az maliyetli olacakt�r ve kesinlikle o �ekilde tercih edilmelidir.

-- JOIN yapmaks�z�n sadece products tablosu ile ��z�me ula�al�m
SELECT	product_name, list_price, model_year --bu s�tunlar yeterli olacakt�r.
FROM	production.products
WHERE	category_id NOT IN (       
							SELECT category_id
							FROM	production.categories
							WHERE	category_name IN ('Cruisers Bicycles', 'Mountain Bikes', 'Road Bikes')
							)
-- dikkat edersen �nceki ��z�mde subquery'de NOT IN kulland�m WHERE sat�r�nda IN kulland�m. 
	--burada ise tam tersini yapt�m.

-- ayr�ca subquery deki SELECT sat�r�nda * veya birden fazla s�tun belirtemeyiz hata verir.
	-- ��nk� bu subquery ile ana query'nin WHERE sat�r�nda category_id lere bir condition sa�layaca��mdan,
	-- subquery sadece category_id s�tunu d�nd�rmelidir.


-- sadece 2016 y�l�na ait sonu�lar� getirmek istersek:
SELECT	product_name, list_price, model_year
FROM	production.products
WHERE	category_id NOT IN (
						SELECT category_id
						FROM	production.categories
						WHERE	category_name IN ('Cruisers Bicycles', 'Mountain Bikes', 'Road Bikes')
							)
AND model_year = '2016'  -- WHERE sat�r�nda bir filtreleme daha yapt�m. AND ile istedi�im kadar filtreleme yapabilirim.





-- SORU 8: Elektrikli bisikletlerden daha pahal� olan bisikletleri listeleyin.

-- �nce subquery'mizi yazal�m. electric bikes'lar�n fiyatlar�n� getirelim.
SELECT A.*, B.product_name, B.list_price
FROM production.categories A, production.products B
WHERE A.category_id = B.category_id 
AND A.category_name = 'Electric Bikes'

-- benim ilgilendi�im list_price'lar oldu�undan list_price s�tununu �ekiyorum.
SELECT B.list_price
FROM production.categories A, production.products B
WHERE A.category_id = B.category_id 
AND A.category_name = 'Electric Bikes'

-- �imdi as�l sorgumuzu yazal�m:
SELECT	product_name, model_year, list_price
FROM	production.products
WHERE	list_price > (           
					SELECT	B.list_price
					FROM	production.categories A, production.products B
					WHERE	A.category_id = B.category_id
					AND		A.category_name = 'Electric Bikes'
					)
-- "subquery returned more than 1 value" hatas� verdi. ��nk� > operat�r� kar��s�nda bir tek value ister.
	-- A�a��daki queryde "ALL" komutu ile bunu ��z�yoruz.

SELECT	product_name, model_year, list_price
FROM	production.products
WHERE	list_price > ALL (               -- elektrikli bisikletlerin t�m�nden daha pahal� olanlar� getir.
					SELECT	B.list_price  -- yani en pahal� elektrikli bisikletten daha pahal� olanlar� getiriyor.
					FROM	production.categories A, production.products B
					WHERE	A.category_id = B.category_id
					AND		A.category_name = 'Electric Bikes'
					)
-- ALL yazarak, subquery deki B�T�N fiyatlardan daha y�ksek olanlar�nkini filtreliyoruz. 
	-- Dolay�s�yla tek bir value olmasa da bu subquery'i kabul ediyor.

-- elektriklik bisikletlerden herhangi birinden daha pahal� olan bisikletleri listeleyin
SELECT	product_name, model_year, list_price
FROM	production.products
WHERE	list_price >  ANY (             -- elektrikli bisikletlerin herhangi birinden daha pahal� olanlar� getir.
					SELECT	B.list_price  --her bir elektrikli bisikletten daha pahal� olanlar� getiriyor.
					FROM	production.categories A, production.products B
					WHERE	A.category_id = B.category_id
					AND		A.category_name = 'Electric Bikes'
					)
--Elektrikli bisiklet kategorisindeki herhangi birinden daha y�ksek fiyatl� olanlar� getiriyor.

-- Asl�nda ALL dedi�imizde maksimum fiyatl� olandan daha y�ksek fiyatl� olanlar�, 
-- ANY dedi�imizde ise minimum fiyatl� olandan daha y�ksek fiyiatl� olanlar� getirmi� oldu.


,

		--------------- CORRELATED SUBQUERIES ------------------

		-----------------EXISTS & NOT EXISTS -------------------

		-- SUBQERY ile ana QUERY tablolar�n�n birbiri ile join edilmesi, birbirine ba�lanmas�d�r.

--- Bunlar genelde EXISTS ve NOT EXISTS ile kullan�l�yor.

-- EXIST kulland���n zaman; subquery herhangi bir sonu� d�nd�r�rse �stteki query'i �ALI�TIR anlam�na geliyor
-- NOT EXIST ; subquery herhangi bir sonu� d�nd�r�rse �stteki query'i �ALI�TIRMA anlam�na geliyor



-- SORU : Write a query that returns State where 'Trek Remedy 9.8 - 2017' product is not ordered.
-- (TR) 'Trek Remedy 9.8 - 2017' �r�n�n�n sipari� edilmedi�i State'leri getir.


-- bu �r�n�n product_name'i elimde. yani products tablosunu kullanaca��m. 
	--istenen ise bunun State'i, o da sales.customers tablosunda,
	-- bu iki tabloyu sales.order_items ve sales_orders tablolar� �zerinden birbirine ba�layaca��m.
SELECT D.state
FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
WHERE A.product_id = B.product_id and B.order_id = C.order_id and C.customer_id = D.customer_id
and A.product_name = 'Trek Remedy 9.8 - 2017'
-- 14 state var ama birbirini tekrar edenler de var. Bu y�zden DISTINCT �ekiyorum

SELECT DISTINCT D.state
FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
WHERE A.product_id = B.product_id 
and B.order_id = C.order_id 
and C.customer_id = D.customer_id
and A.product_name = 'Trek Remedy 9.8 - 2017'
-- �imdi bu product ismiyle 2 state'ten sipari� verildi�ini g�rd�m.


SELECT DISTINCT state
FROM sales.customers
WHERE state NOT IN (
					SELECT DISTINCT D.STATE -- BURADA DISTINCT'e gerek yok.
					FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
					WHERE A.product_id = B.product_id
					and B.order_id = C.order_id
					and C.customer_id = D.customer_id 
					and A.product_name = 'Trek Remedy 9.8 - 2017')					
-- NOT IN ile bu product'�n sipari�inin verildi�i (��nk� state'i sales.customers tablosundan �ekiyoruz) state'lerin d���nda kalan state'leri getir demi� olduk.


----- Ya NOT IN yerine NOT EXISTS kullan�rsam:

SELECT DISTINCT state
FROM sales.customers
WHERE NOT EXISTS (
					SELECT DISTINCT D.STATE
					FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
					WHERE A.product_id = B.product_id
					and B.order_id = C.order_id
					and C.customer_id = D.customer_id 
					and A.product_name = 'Trek Remedy 9.8 - 2017'	
					)
-- Hata verdi. ��nk� EXISTS kullan�rsan subquery ile query'i join yapman�z gerekir

--query'leri sales.customer �zerinden joinleyelim:
SELECT DISTINCT state
FROM sales.customers X
WHERE EXISTS (
					SELECT DISTINCT D.STATE
					FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
					WHERE A.product_id = B.product_id
					and B.order_id = C.order_id
					and C.customer_id = D.customer_id 
					and A.product_name = 'Trek Remedy 9.8 - 2017'
					and X.state = D.state
					) 
-- EXISTS ile demi� olduk ki: Subquery ile yukardaki ana tablonun ilgili de�erleri e�le�iyorsa bu EXISTS bir de�er d�nd�r�yor.
	-- Yukardaki customer tablosunun state i ile subquery deki state e�itse bana onlar� getir diyorum
	
-- NOT EXISTS deseydik : e�er e�itlenenler varsa bunlar� getirme, bunlar olmas�n diyorum. Yani burda NOT IN gibi davran�yor.
SELECT DISTINCT state
FROM sales.customers X
WHERE NOT EXISTS (
					SELECT DISTINCT D.STATE -- BURAYA HERHANG� B�R RAKAM KOYAB�L�RS�N. SELECT SATIRINA BAKMIYOR
					FROM production.products A, sales.order_items B, sales.orders C, sales.customers D
					WHERE A.product_id = B.product_id
					and B.order_id = C.order_id
					and C.customer_id = D.customer_id 
					and A.product_name = 'Trek Remedy 9.8 - 2017'
					and X.state = D.state
					) 

--Bak�n a�a��da subquery'nin SELECT sat�r�na 1 yazd�m. yine ayn� sonucu verdi.
-- ��nk� EXISTS, subquery'nin SELECT ifadesinde �a��rd���n�z de�erlerle ilgilenmiyor,
-- sadece buran�n sonu� d�nd�r�p d�nd�rmedi�iyle ile ilgileniyor.
-- yani sonda yazd���m�z X.state=D.state joini ile ilgileniyor.
-- A�a��daki query de:
-- NOT EXISTS --> X.state = D.state ile e�itlenenleri getirme diyor.
-- EXIST -------> e�itlenenler� getirebilirsin.
SELECT	DISTINCT STATE
FROM	sales.customers X
WHERE NOT EXISTS 	(
						SELECT	1
						FROM	production.products A, sales.order_items B, sales.orders C, sales.customers D
						WHERE	A.product_id = B.product_id
						AND		B.order_id = C.order_id
						AND		C.customer_id = D.customer_id
						AND		A.product_name = 'Trek Remedy 9.8 - 2017'
						AND		X.state = D.state
						)



              --------------- VIEWS -------------------

-- Subquery'ler, CTE(Common Table Expression)'lar, VIEW'lar hep ayn� amaca hizmet ediyor. Tablolarla daha rahat �al��mam�z� sa�l�yorlar. ,
	-- Di�er bir avantaj� da performans� art�rmakt�r. Siz query'nizi joinlerle tek bir query i�inde de�il, subery lerle, CTE'lerle,
	-- VIEW'larla daralta daralta (daralt�lm�� tablolarla) sonuca gitmeye �al���yorsunuz.
				-----------AVANTAJLARI:-------------
	--        Performans + Simplicity + Security + Storage 
	
	-- VIEW : Tek bir tabloda yapaca��m�z i�lemleri a�amalar b�lerek yapmam�z� sa�l�yor. Bu da h�z�m�z� artt�r�yor.
	-- VIEW ile ayn� tablo gibi olu�turuyoruz ve bu VIEW'a kimleri eri�ebilece�ini belirleyebiliyoruz. bu da security sa�l�yor.
	-- VIEW'lar�n kullan�m� da olu�turmas� basittir. b�y�k tablonun i�erisinde biz bir k�s�m ilgilendimiz verileri al�p onlar �zerinden �al���yoruz.
	-- VIEW'lar �ok az yer kaplar. ��bk� as�l tablonun bir g�r�nt�s�d�r.


			-------------- CTE - COMMON TABLE ESPRESSIONS -------------

-- Subquery mant��� ile ayn�. Subquery'de i�erde bir tablo ile ilgileniyorduk CTE'de yukarda yaz�yoruz.

--(CTE), ba�ka bir SELECT, INSERT, DELETE veya UPDATE deyiminde ba�vurabilece�iniz veya i�inde kullanabilece�iniz ge�ici bir sonu� k�mesidir. 
-- Ba�ka bir SQL sorgusu i�inde tan�mlayabilece�iniz bir sorgudur. Bu nedenle, di�er sorgular CTE'yi bir tablo gibi kullanabilir. 
-- CTE, daha b�y�k bir sorguda kullan�lmak �zere yard�mc� ifadeler yazmam�z� sa�lar.

--ORDINARY
WITH query_name [(column_name1, ....)] AS
	(SELECT ....)   -- CTE Definition

SQL_Statement
-- sadece WITH k�sm�n� yazarsan tek ba��na �al��maz. WITH ile belirtti�im query'yi birazdan kullanaca��m demek bu. 
-- as�l SQL statement i�inde bunu kullan�yoruz.

-- RECURSIVE
WITH table_name (colum_list)
AS
(
	-- Anchor member
	initial_query
	UNION ALL
	-- Recursive member that references table_name.
	recursive_query
)
-- references table_name
SELECT *
FROM table_name

-- WITH ile yukarda tablo olu�turuyor, a�a��da da SELECT FROM ile bu tabloyu kullan�yor



-- SORU (VIEW): Sipari� detaylar� ile ilgili bir VIEW olu�turun ve birka� sorgu i�inde kullan�n.

-- M��teri ad� soyad�, order_date, product_name, model_year, quantity, list_price, final_price (indirimli fiyat)
-- yukardaki bu bilgileri farkl� tablolardan alabiliriz. farkl� tablolardan her seferinde ayn� sorguyu �al��t�r�p bir sonu� almaktansa;
-- bunlar� ben bir kere kaydedeyim ve tablo g�ncellendik�e bunlar da g�ncellensin dedi�imde VIEW kullan�yorum.

SELECT	A.first_name, A.last_name, B.order_date, D.product_name, D.model_year,
		C.quantity, C.list_price, C.list_price * (1-C.discount) final_price
FROM	sales.customers A, sales.orders B, sales.order_items C, production.products D
WHERE	A.customer_id = B.customer_id AND
		B.order_id = C.order_id AND
		C.product_id = D.product_id
-- ben her defas�nda bu query'i �al��t�rmam gerekiyor. Bu da her seferinde arka tarafta ayn� i�lemlerin yap�lmas� anlam�na geliyor.

-- ben bu tabloyu VIEW olarak CREATE etmek istiyorum:

CREATE VIEW SUMMARY_VIEW AS 
SELECT	A.first_name, A.last_name, B.order_date, D.product_name, D.model_year,
		C.quantity, C.list_price, C.list_price * (1-C.discount) final_price
FROM	sales.customers A, sales.orders B, sales.order_items C, production.products D
WHERE	A.customer_id = B.customer_id AND
		B.order_id = C.order_id AND
		C.product_id = D.product_id

-- istedi�im zaman VIEW'� �a��rarak kullanabilirim. 
SELECT *
FROM SUMMARY_VIEW

-- ana tablo g�ncellendik�e VIEW' da otomatik olarak g�ncellenir.
-- bu tablo olarak create edildi�inde ana tablodan verileri �ekip ekstradan kaydetmi� olacakt�m.
	-- ve ana tablodaki de�erler g�ncellendi�inde bu tablo g�ncellenmemi� olacakt�. 
	-- yani tablo create etmek maliyetli bir i�lemdir.


-- E�er sadece bu session da tablonun create edilmesini istiyorum, session sonunda da tablonun gitmesini istiyorum dersen:

SELECT	A.first_name, A.last_name, B.order_date, D.product_name, D.model_year,
		C.quantity, C.list_price, C.list_price * (1-C.discount) final_price
INTO #SUMMARY_TABLE
FROM	sales.customers A, sales.orders B, sales.order_items C, production.products D
WHERE	A.customer_id = B.customer_id AND
		B.order_id = C.order_id AND
		C.product_id = D.product_id
	
SELECT *
FROM #SUMMARY_TABLE



--------------------- BU NOTEBOOK DA GE�EN �NEML� A�IKLAMALAR--------------------

-- Bir tabloda meydana gelen sonucu ba�ka bir tablo veya i�lem i�in kullanmak i�in 3 y�ntem:
	-- Subqueries
	-- Views
	-- Common Table Expression (CTE's)

-- subqueries, SELECT, FROM ve WHERE sat�rlar�nda kullan�labiliyor.
	-- WHERE'de subquery sonucunda d�nen ifadelere g�re ana tablo �zerinden bir filtreleme yapaca��n anlam�na geliyor.
		--WHERE'in her zaman ana tablo �zerinde filtreleme yapt���n� unutma!
	-- SELECT'te subquery i�indeki de�eri SELECT sat�r�nda d�nd�rmek i�in kullan�l�yor
	-- SELECT sat�r�ndaki subquery TEK B�R S�TUN VEYA SATIR D�ND�RMEK ZORUNDA! (sadece bir de�er d�nd�rmeli)
	-- FROM da subquery bir tablo getirmesi laz�m. ba�ka k�staslara g�re bir tablo olu�uruyor ve bunu Fromda kullanmak �zere getiriyor.

	-- SUBQUERY �E��TLER�
		-- Single-row  : Tek bir sat�r d�nd�r�r. SELECT'te kullan�lan gibi. 
		-- Multiple-row: Birden fazla de�er d�nd�ren subquery
		-- Correlated : �stteki sorgu ile alltaki sorgunun birbiri ile e�lenerek ba�lant� kuruldu�u subquery

	-- SINGLE-ROW SUBQUERY
		-- =, <, >, >=, <=, <>, != operat�rleri ile �zellikle WHERE sat�r�nda kullan�lan subquerylerdir.


-------------- PIVOT -----------

-- Pivot, sat�r bazl� analiz sonucunu s�tun baz�na d�n��t�r�lmesini sa�l�yor. 
	-- group by gibi bir gruplama yap�yor. dolay�s�la group by kullanm�yoruz, pivota �zel bir syntax kullan�yoruz
	-- bu syntax i�erisinde aggregate i�lemi yap�p ilgili s�tunlardaki kategorilere g�re bir pivot table olu�turuyor.
	-- ve o s�tunun sat�rlar�n� olu�turan her bir kategoriyi birer s�tuna d�n��t�r�yor. yani sat�rlardaki value'lar s�tunlarda sergileniyor


	-- E�er DISTINCT atmadan da ayn� sonuca ula��yorsak 
	-- DISTINCT maliyetli bir i� oldu�undan ve SQL e ekstra i�lem ve y�k getirdi�inden DISTINCT kullanmamam laz�m. 
	-- Genelde DISTINCT'i bir aggregation i�lemi yapm�yorsak en son sonu� tablosunda, sonu� select'in de kullan�r�z. 
	-- �nceki select lerde kullanmay�z.


--------------- MULTIPLE ROW SUBQUERIES -------------------
	--Birden �ok de�er d�nd�ren subquerylerdir.
	-- Bir�ok de�er i�erisinden bir de�er ar�yor ve onlar i�erisinde bir filtreleme yapacaksam IN, NOT IN, ANY ve ALL operat�rlerini kullan�yorum.


		--------------- CORRELATED SUBQUERIES ------------------

		-----------------EXISTS & NOT EXISTS -------------------

		-- SUBQERY ile ana QUERY tablolar�n�n birbiri ile join edilmesi, birbirine ba�lanmas�d�r.

--- Bunlar genelde EXISTS ve NOT EXISTS ile kullan�l�yor.

-- EXIST kulland���n zaman; subquery herhangi bir sonu� d�nd�r�rse �stteki query'i �ALI�TIR anlam�na geliyor
-- NOT EXIST ; subquery herhangi bir sonu� d�nd�r�rse �stteki query'i �ALI�TIRMA anlam�na geliyor

--Subquery'nin SELECT sat�r�na 1 yazd�m. yine ayn� sonucu verdi.
	-- ��nk� EXISTS, subquery'nin SELECT ifadesinde �a��rd���n�z de�erlerle ilgilenmiyor,
	-- sadece buran�n sonu� d�nd�r�p d�nd�rmedi�iyle ile ilgileniyor.

	             --------------- VIEWS -------------------

-- Subquery'ler, CTE(Common Table Expression)'lar, VIEW'lar hep ayn� amaca hizmet ediyor. Tablolarla daha rahat �al��mam�z� sa�l�yorlar. ,
	-- Di�er bir avantaj� da performans� art�rmakt�r. Siz query'nizi joinlerle tek bir query i�inde de�il, subery lerle, CTE'lerle,
	-- VIEW'larla daralta daralta (daralt�lm�� tablolarla) sonuca gitmeye �al���yorsunuz.
				-----------AVANTAJLARI:-------------
	--        Performans + Simplicity + Security + Storage 
	
	-- VIEW : Tek bir tabloda yapaca��m�z i�lemleri a�amalar b�lerek yapmam�z� sa�l�yor. Bu da h�z�m�z� artt�r�yor.
	-- VIEW ile ayn� tablo gibi olu�turuyoruz ve bu VIEW'a kimleri eri�ebilece�ini belirleyebiliyoruz. bu da security sa�l�yor.
	-- VIEW'lar�n kullan�m� da olu�turmas� basittir. b�y�k tablonun i�erisinde biz bir k�s�m ilgilendimiz verileri al�p onlar �zerinden �al���yoruz.
	-- VIEW'lar �ok az yer kaplar. ��bk� as�l tablonun bir g�r�nt�s�d�r.

	-- ana tablo g�ncellendik�e VIEW' da otomatik olarak g�ncellenir.
		-- bu tablo olarak create edildi�inde ana tablodan verileri �ekip ekstradan kaydetmi� olacakt�m.
		-- ve ana tablodaki de�erler g�ncellendi�inde bu tablo g�ncellenmemi� olacakt�. 
		-- yani tablo create etmek maliyetli bir i�lemdir.


	-- M��teri ad� soyad�, order_date, product_name, model_year, quantity, list_price, final_price (indirimli fiyat)
	-- yukardaki bu bilgileri farkl� tablolardan alabiliriz. farkl� tablolardan her seferinde ayn� sorguyu �al��t�r�p bir sonu� almaktansa;
	-- bunlar� ben bir kere kaydedeyim ve tablo g�ncellendik�e bunlar da g�ncellensin dedi�imde VIEW kullan�yorum.



			-------------- CTE - COMMON TABLE ESPRESSIONS -------------

-- Subquery mant��� ile ayn�. Subquery'de i�erde bir tablo ile ilgileniyorduk CTE'de yukarda yaz�yoruz.

--(CTE), ba�ka bir SELECT, INSERT, DELETE veya UPDATE deyiminde ba�vurabilece�iniz veya i�inde kullanabilece�iniz ge�ici bir sonu� k�mesidir. 
-- Ba�ka bir SQL sorgusu i�inde tan�mlayabilece�iniz bir sorgudur. Bu nedenle, di�er sorgular CTE'yi bir tablo gibi kullanabilir. 
-- CTE, daha b�y�k bir sorguda kullan�lmak �zere yard�mc� ifadeler yazmam�z� sa�lar.

