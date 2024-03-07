----------------------DATA PREPARATION AND UNDERSTANDING---------------------------------
--Q1.
SELECT 'CUSTOMER' AS TABLE_NAME, COUNT(*) AS ROWS_NUMBER FROM Customer
UNION
SELECT 'PRO_CAT_INFO' AS TABLE_NAME, COUNT(*) AS ROWS_NUMBER FROM prod_cat_info
UNION
SELECT 'TRANSACTIONS' AS TABLE_NAME, COUNT(*) AS ROWS_NUMBER FROM Transactions;

--Q2.
SELECT COUNT(*) AS RETURN_TRANSACTIONS FROM Transactions
WHERE total_amt<0;

--Q3.
SELECT CONVERT(DATE,tran_date,105) FROM Transactions;
SELECT CONVERT(DATE,DOB,105) FROM Customer;            
                   
	----I had already changed the datatype of the above 2 columns while importing the data-------------------------------

--Q4.
SELECT MAX(tran_date) AS MAX_DATE, MIN(tran_date) AS MIN_DATE, DATEDIFF(DD,MIN(tran_date),MAX(tran_date)) AS DAYS,
DATEDIFF(MM,MIN(tran_date),MAX(tran_date)) AS MONTHS,
DATEDIFF(YY,MIN(tran_date),MAX(tran_date)) AS YEARS
FROM Transactions;

--Q5.
SELECT prod_cat FROM prod_cat_info
WHERE prod_subcat ='DIY';


----------------------------------DATA ANALYSIS---------------------------------------------
--Q1. 
SELECT TOP 1 Store_type, COUNT(Store_type) AS FREQUENCY FROM Transactions
GROUP BY Store_type
ORDER BY FREQUENCY DESC;
                  --OR--
SELECT Store_Type, COUNT(Store_type) AS FREQUENCY FROM Transactions
GROUP BY Store_Type
HAVING COUNT(Store_Type) >= ALL(SELECT COUNT(Store_type) FROM Transactions GROUP BY Store_Type)

--Q2.
SELECT 'MALE' AS [GENDER], COUNT(*) AS [COUNT] FROM Customer
WHERE Gender='M'
UNION
SELECT 'FEMALE' AS [GENDER], COUNT(*) AS [COUNT] FROM Customer
WHERE Gender='F';

--Q3.
SELECT TOP 1 city_code, COUNT(city_code) AS [COUNT] FROM Customer
GROUP BY city_code
ORDER BY [COUNT] DESC;

--Q4.
SELECT prod_cat, COUNT(prod_subcat) AS SUB_CAT_COUNT FROM prod_cat_info
WHERE prod_cat = 'BOOKS'
GROUP BY prod_cat;

--Q5.
SELECT MAX(Qty) AS MAX_QUANTITY FROM Transactions
                        --OR--
SELECT b.prod_subcat,MAX(Qty) from Transactions as a inner join prod_cat_info as b on a.prod_cat_code =b.prod_cat_code and a.prod_subcat_code =b.prod_sub_cat_code  
group by b.prod_subcat


--Q6.
--SELECT * FROM Transactions
SELECT B.PROD_CAT,SUM(TOTAL_AMT) AS REVENUE FROM Transactions AS A 
LEFT JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code=B.prod_sub_cat_code
WHERE B.prod_cat IN ('ELECTRONICS', 'BOOKS')
GROUP BY B.prod_cat;

--Q7.
SELECT * FROM (
				SELECT CUST_ID, COUNT(total_amt) TOTAL_TRANS FROM Transactions
				WHERE total_amt>0
				GROUP BY cust_id) AS X
WHERE TOTAL_TRANS>10;
                   --OR--
SELECT cust_id, COUNT(cust_id) from Transactions
where total_amt>0
group by cust_id
having COUNT(cust_id)>10

--Q8.
SELECT PROD_CAT,SUM(TOTAL_AMT) AS REVENUE FROM Transactions AS A INNER JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code 
WHERE prod_cat IN ('ELECTRONICS', 'CLOTHING') AND Store_type='FLAGSHIP STORE'
GROUP BY prod_cat;

--Q9.
WITH DEMO_TABLE AS
				(SELECT A.total_amt,B.prod_cat,B.prod_subcat,C.Gender FROM Transactions AS A INNER JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
				left join Customer AS C ON A.cust_id=C.customer_Id)
SELECT PROD_CAT, prod_subcat, SUM(total_amt) AS REVENUE FROM DEMO_TABLE
WHERE prod_cat='ELECTRONICS' AND Gender='M'
GROUP BY prod_subcat,prod_cat;

                           --OR--

SELECT prod_cat,prod_subcat,sum(total_amt) as REVENUE FROM Transactions AS A 
INNER JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code 
left join Customer AS C ON A.cust_id=C.customer_Id
where Gender='M' and prod_cat='ELECTRONICS'
group by prod_cat,prod_subcat

--Q10.
SELECT TOP 5 PROD_SUBCAT,(SUM(total_amt)/(SELECT SUM(total_amt) FROM Transactions))*100 AS SALES_PERCENTAGE,
(COUNT(CASE  
		WHEN total_amt<0
		THEN prod_subcat
		END)/(SELECT COUNT(prod_subcat_code) FROM Transactions WHERE total_amt<0))*100 AS [RETURN_PERCENTAGE]

FROM Transactions AS A LEFT JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
GROUP BY prod_subcat
ORDER BY SUM(total_amt) DESC;
                       --Uppra wala sahi nahi lagra cause return aara hai jabki return 0 nahi hai--
SELECT top 5 prod_subcat,(sum(total_amt)/(SELECT SUM(total_amt) from Transactions))*100 as [Sales%], 
( SUM (CASE WHEN total_amt<0 THEN ABS(total_amt) END)/(SELECT SUM(ABS(total_amt)) from Transactions where total_amt<0) ) as [Return%]
FROM Transactions AS A INNER JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
group by prod_subcat
order by [Sales%] DESC;


(SELECT SUM(total_amt) from Transactions where total_amt<0) 
SELECT prod_cat_code,prod_subcat_code,SUM (CASE WHEN total_amt<0 THEN (total_amt) END) from Transactions --AS A LEFT JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
group by prod_cat_code,prod_subcat_code



--Q11.
WITH TABLE_DEMO AS
				(SELECT *, CASE 
							WHEN DOB IS NOT NULL
							THEN DATEDIFF(YY,DOB,GETDATE())
							END AS AGE
				 FROM Transactions AS A LEFT JOIN Customer AS B ON A.cust_id =B.customer_Id)
SELECT cust_id, SUM(total_amt) AS REVENUE FROM table_demo
WHERE age between 25 and 35 and tran_date BETWEEN (SELECT MAX(tran_date)-30 FROM TABLE_DEMO) AND (SELECT MAX(tran_date) FROM TABLE_DEMO)
GROUP BY cust_id;

--Q12.
SELECT TOP 1 * FROM
(SELECT prod_cat, ABS(SUM(total_amt)) AS RETURN_VALUE
FROM Transactions AS A LEFT JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
WHERE total_amt<0 AND tran_date >= DATEADD(MM,-3,(SELECT MAX(TRAN_DATE) FROM TRANSACTIONS))
GROUP BY prod_cat) AS X
ORDER BY RETURN_VALUE DESC;

--Q13.
WITH [TABLE] AS 
				(SELECT Store_type, SUM(total_amt) AS SALES,RANK() OVER (ORDER BY SUM(total_amt) DESC) AS REVENUE_RANK, 
				 SUM(Qty) AS QUANTITY, RANK() OVER (ORDER BY SUM(QTY) DESC) AS QUAN_RANK FROM Transactions
				 GROUP BY Store_type) 
SELECT * FROM [TABLE]
WHERE REVENUE_RANK=1 AND QUAN_RANK=1;


--Q14.
SELECT prod_cat, AVG(total_amt) AS AVG_REVENUE
FROM Transactions AS A LEFT JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
GROUP BY prod_cat
HAVING AVG(total_amt) > (SELECT AVG(total_amt) FROM Transactions);


--Q15.
SELECT prod_cat,prod_subcat, AVG(total_amt) AS AVG_REVENUE, SUM(total_amt) AS TOTAL_REVENUE
FROM Transactions AS A LEFT JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
WHERE prod_cat IN (
				SELECT TOP 5 prod_cat
				FROM Transactions AS A LEFT JOIN prod_cat_info AS B ON A.prod_cat_code=B.prod_cat_code AND A.prod_subcat_code =B.prod_sub_cat_code
				GROUP BY prod_cat
				ORDER BY SUM(Qty) DESC)
GROUP BY prod_subcat, prod_cat








