<h1 align="center">Monday Coffee Analysis ☕️ </h1>

This project analyses coffee sales across multiple cities in India with a focus on identifying trends, growth rates, and customer patterns. Using SQL and Excel visualisation techniques, the analysis provides insights into sales distribution, top-performing cities, and customer behaviour.

##  📊 Project Overview

### 🚀 Objective: To explore coffee sales data across Indian cities and evaluate performance on Mondays.

Scope: Includes analysis of sales growth, top-selling products, and city-level performance.

## Tools Used:
SQL 
Excel

(Intermediate level – used CTEs, JOINs, LAG(), and window functions)

## 🔑 Key Insights

- Identified top 3 coffee products sold in each city.
- Measured sales growth rates using LAG() and window functions.
- Compared customer purchase behaviour across different cities.
- Highlighted cities with consistently high Monday sales volumes.

## 🛠️ SQL Skills Demonstrated

- Writing CTEs to structure queries.
- Using LAG() to calculate growth rates.
- Applying DENSE_RANK() to rank products by sales.
- Combining multiple tables with JOINs for city, product, and sales data.

## 📈 Example Query Snippet

### Calculate the percentage growth(or decline) in sales over different time period (monthly) by each city

```sql
WITH monthly_sales
AS
(	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM s.sale_date) AS sale_date_month,
		EXTRACT(YEAR FROM s.sale_date) AS sale_date_year,
		SUM(s.total) AS total_sale
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1,3,2
),
growth_rate
AS
(SELECT
	city_name,
	sale_date_month AS month,
	sale_date_year AS year,
	total_sale,
	LAG(total_sale,1) OVER(PARTITION BY city_name ORDER BY sale_date_year, sale_date_month) as prev_month_sales
FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	total_sale,
	prev_month_sales,
	ROUND((total_sale - prev_month_sales) ::numeric /prev_month_sales::numeric * 100, 2) AS growth_ratio
FROM growth_rate
WHERE 
	prev_month_sales IS NOT NULL;

```









