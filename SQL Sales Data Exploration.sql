SELECT * FROM MyPortfolioProject.dbo.SalesData

---------------------------------------------------------------------------------------

--Checking the unique values from the data--

SELECT DISTINCT status FROM MyPortfolioProject.dbo.SalesData 
SELECT DISTINCT TERRITORY FROM MyPortfolioProject.dbo.SalesData
SELECT DISTINCT PRODUCTLINE FROM MyPortfolioProject.dbo.SalesData
SELECT DISTINCT COUNTRY FROM MyPortfolioProject.dbo.SalesData
SELECT DISTINCT year_id FROM MyPortfolioProject.dbo.SalesData
SELECT DISTINCT DEALSIZE FROM MyPortfolioProject.dbo.SalesData

------------------------------------------------------------------------------------------

--ANALYSIS--
--Grouping sales by productline--

SELECT PRODUCTLINE, SUM(sales)AS Revenue
FROM MyPortfolioProject.dbo.SalesData
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

SELECT YEAR_ID, SUM(sales) AS Revenue
FROM MyPortfolioProject.dbo.SalesData
GROUP BY YEAR_ID
ORDER BY 2 DESC

SELECT  DEALSIZE,  SUM(sales) AS Revenue
FROM MyPortfolioProject.dbo.SalesData
GROUP BY DEALSIZE

-----------------------------------------------------------------------------------------

--What month in a particular year had the highest sales? What was the monthly income? = NOVEMBER

SELECT  MONTH_ID, SUM(sales) AS Revenue, COUNT(ORDERNUMBER) Frequency
FROM MyPortfolioProject.dbo.SalesData
WHERE YEAR_ID = 2003 
GROUP BY  MONTH_ID
ORDER BY 2 DESC

SELECT  MONTH_ID, SUM(sales) AS Revenue, COUNT(ORDERNUMBER) Frequency
FROM MyPortfolioProject.dbo.SalesData
WHERE YEAR_ID = 2004 
GROUP BY  MONTH_ID
ORDER BY 2 DESC

SELECT  MONTH_ID, SUM(sales) AS Revenue, COUNT(ORDERNUMBER) Frequency
FROM MyPortfolioProject.dbo.SalesData
WHERE YEAR_ID = 2005
GROUP BY  MONTH_ID
ORDER BY 2 DESC

----------------------------------------------------------------------------------------------

--What kind of product do they sell in November? = CLASSIC
SELECT  MONTH_ID, PRODUCTLINE, SUM(sales) AS Revenue, COUNT(ORDERNUMBER)
FROM MyPortfolioProject.dbo.SalesData
WHERE YEAR_ID = 2004 AND MONTH_ID = 11 
GROUP BY  MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC

-------------------------------------------------------------------------------------------

--Who is our top customer? RFM ANALYSIS could provide the most useful answer to this.

DROP TABLE IF EXISTS #rfm
;WITH rfm AS 
(
    SELECT
		CUSTOMERNAME, 
		SUM(sales) AS MonetaryValue,
		AVG(sales) AS AvgMonetaryValue,
		COUNT(ORDERNUMBER) AS Frequency,
		MAX(ORDERDATE) AS last_order_date,
		(SELECT MAX(ORDERDATE) FROM MyPortfolioProject.dbo.SalesData) AS max_order_date,
		DATEDIFF(DD, MAX(ORDERDATE), (SELECT MAX(ORDERDATE) FROM MyPortfolioProject.dbo.SalesData)) AS Recency
	FROM MyPortfolioProject.dbo.SalesData
	GROUP BY CUSTOMERNAME
),
rfm_calc AS
(

	SELECT r.*,
		NTILE(4) OVER (ORDER BY Recency DESC) AS rfm_recency,
		NTILE(4) OVER (ORDER BY  Frequency) AS rfm_frequency,
		NTILE(4) OVER (ORDER BY  MonetaryValue) AS rfm_monetary
	FROM rfm r
)
SELECT 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary AS rfm_cell,
	CAST(rfm_recency AS VARCHAR) + CAST(rfm_frequency AS VARCHAR) + CAST(rfm_monetary  AS VARCHAR) AS rfm_cell_string
INTO #rfm
FROM rfm_calc c

SELECT * FROM #rfm

SELECT  CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	CASE 
		WHEN rfm_cell_string IN (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost_customers'  --lost customers
		WHEN rfm_cell_string IN (133, 134, 143, 244, 334, 343, 344, 144) THEN 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		WHEN rfm_cell_string IN (311, 411, 331) THEN 'new customers'
		WHEN rfm_cell_string IN (222, 223, 233, 322) THEN 'potential churners'
		WHEN rfm_cell_string IN (323, 333,321, 422, 332, 432) THEN 'active' --(Customers who buy often & recently, but at low price points)
		WHEN rfm_cell_string in (433, 434, 443, 444) THEN 'loyal'
	END rfm_segment
FROM #rfm

---------------------------------------------------------------------------------------------

--What products are sold together the most frequently?--

SELECT DISTINCT OrderNumber, STUFF(

	(SELECT ',' + PRODUCTCODE
	FROM MyPortfolioProject.dbo.SalesData AS P
	WHERE ORDERNUMBER IN 
		(

			SELECT ORDERNUMBER
			FROM (
				SELECT ORDERNUMBER, COUNT(*) AS rn
				FROM MyPortfolioProject.dbo.SalesData
				WHERE STATUS = 'Shipped'
				GROUP BY ORDERNUMBER
			) AS m
			WHERE rn = 2
		)
		AND P.ORDERNUMBER = S.ORDERNUMBER
		FOR XML PATH ('')), 1, 1, '') ProductCodes
FROM MyPortfolioProject.dbo.SalesData AS S
ORDER BY 2 DESC
