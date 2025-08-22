<h1 align="center">Monday Coffee Analysis ☕️ </h1>

This project analyses coffee sales across multiple cities in India with a focus on identifying trends, growth rates, and customer patterns. Using SQL and Excel visualisation techniques, the analysis provides insights into sales distribution, top-performing cities, and customer behaviour.

##  📊 Project Overview

### 🚀 Objective: To explore coffee sales data across Indian cities and evaluate performance on Mondays.

## Key Questions
### 1. Coffee Consumers Count
How many people in each city are estimated to consume coffee, given that 25% of the population does?

### 2.Total Revenue from Coffee Sales
What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

### 3.Sales Count for Each Product
How many units of each coffee product have been sold?

### 4.Average Sales Amount per City
What is the average sales amount per customer in each city?

### 5.City Population and Coffee Consumers
Provide a list of cities along with their populations and estimated coffee consumers.

### 6.Top Selling Products by City
What are the top 3 selling products in each city based on sales volume?

### 7.Customer Segmentation by City
How many unique customers are there in each city who have purchased coffee products?

### 8.Average Sale vs Rent
Find each city and their average sale per customer and avg rent per customer

### 9.Monthly Sales Growth
Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

### 10.Market Potential Analysis
Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

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

### Calculating the % growth (or decline) in sales over different time period (monthly) by each city

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

### Recommendations

After analysing the data, the recommended top 3 cities for new store opening are:

City 1 : Pune
1. average_rent_per_customer is low
2. Highest total revenue
3. average_cost_per_customer is also high

City 2 : Dehli
1.estimated_coffe_consumers_in_millions is high 7.7mill
2.total_customer is high 68
3.average_rent_per_customer is low (under 500)

City 3 : Japiur
1. Highest customer count 
2. Average rent per customer is low 156
3. average_sale_per_customer is better 11.6k








