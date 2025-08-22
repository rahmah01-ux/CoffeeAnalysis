-- MONDAY COFFEE DATA ANALYSIS

SELECT * 
FROM city;

SELECT * 
FROM customers;

SELECT * 
FROM products;

SELECT * 
FROM sales;


-- Reports & Data Analysis
-- Q1 How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
	ROUND((population * 0.25)/1000000, 2) AS coffee_consumers_in_millions,
	city_rank
FROM city
ORDER BY 2 DESC
LIMIT 5;


-- Q2 What is the total revenue generated from coffee sales across all cities in the last quarter of 2023? (EXTRA: determine each city and the revenue generated)

SELECT *,
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(QUARTER FROM sale_date) AS quarter
FROM sales
WHERE 
	EXTRACT(YEAR FROM sale_date) = 2023
	AND
	EXTRACT(QUARTER FROM sale_date) = 4




SELECT 
	ci.city_name,
	SUM(s.total) AS total_revenue 
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE 
	EXTRACT(YEAR FROM s.sale_date) = 2023
	AND
	EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC;

-- Q3 How many units of each coffee product have been sold?

SELECT 
	p.product_name,
	COUNT(s.sale_id) as total_orders
FROM products as p 
LEFT JOIN
sales as s
ON p.product_id = s.product_id
GROUP BY 1
ORDER BY 2 DESC;

--Q4 What is the average sales amount per customer in each city?

SELECT 
	ci.city_name,
	SUM(s.total) AS total_revenue,
	COUNT(DISTINCT s.customer_id) AS total_customers,
	ROUND((SUM(s.total)/COUNT(DISTINCT s.customer_id)) :: numeric,2) AS average_sale_per_customer
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;


-- note 
-- ::numeric is used in PostgreSQL

--Q5 City Population and coffee consumers (25%)
--Provide a list of all cities along with their populations and estimated coffee consumers.
-- retrun city_name, total current cx, estimated coffee consumers (25%)

WITH city_table AS
(	SELECT 
		city_name,
	    ROUND((population * 0.25)/1000000, 2) AS coffee_consumers_in_millions
	FROM city
),

customers_table
AS
(
	SELECT
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_customers
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT 
	customers_table.city_name,
	city_table.coffee_consumers_in_millions,
	customers_table.unique_customers
FROM city_table
JOIN 
customers_table 
ON city_table.city_name = customers_table.city_name

--Q6
-- Top selling products by city 
-- What are the top 3 selling products in each city based on sales volume?


SELECT *
FROM --table
(
SELECT 
	ci.city_name,
	p.product_name,
	COUNT (s.sale_id) AS total_orders,
	DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC ) AS rank
FROM sales as s
JOIN products as p 
ON s.product_id = p.product_id
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci 
ON ci.city_id = c.city_id
GROUP BY 1,2
-- ORDER BY 1,3 DESC
) as table_1
WHERE rank <= 3



-- Q7 How many unique customer are there in each city who have purched coffee products?


SELECT * 
FROM products;


SELECT 
	ci.city_name,
	COUNT (DISTINCT c.customer_id) as unique_customer_count
FROM city as ci 
JOIN customers as c 
ON ci.city_id = c.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id BETWEEN 1 AND 14
GROUP BY 1;

-- Q8 Find each city and their average sale per customer and avg rent per customer


WITH city_table 
AS 
(	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id ) AS total_customers,
		ROUND((SUM(s.total)/ COUNT(DISTINCT c.customer_id))::numeric,2 ) AS average_cost_per_customer
	FROM city as ci
	JOIN customers as c
	ON ci.city_id = c.city_id
	JOIN sales as s
	ON c.customer_id = s.customer_id
	GROUP BY 1
),
city_rent 
AS 
(SELECT 
	city_name, 
	estimated_rent
FROM city
)

SELECT 
	city_rent.city_name,
	city_rent.estimated_rent,
	city_table.total_customers,
	city_table.average_cost_per_customer,
	ROUND((city_rent.estimated_rent/city_table.average_cost_per_customer)::numeric,2) as average_rent_per_customer
FROM city_rent
JOIN city_table
ON city_rent.city_name = city_table.city_name
ORDER BY 5 DESC;


--Q9 Calculate the percentage growth(or decline) in sales over different time period (monthly) by each city
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


--Q10 Identify the top 3 city based on the highest sales, return city name, total sales, total rent, total customers and estimated coffee consumer
WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) AS total_revenue,
		COUNT(DISTINCT(s.customer_id)) AS unique_customer_count,
		ROUND(SUM(s.total)::numeric/COUNT(DISTINCT(s.customer_id))::numeric, 2) AS average_cost_per_customer
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent 
AS
(SELECT
	city_name,
	estimated_rent,
	ROUND((population * 0.25)/1000000, 2) as estimated_coffee_consumers_in_millions
FROM city	
)
SELECT 
	cr.city_name,
	ct.total_revenue,
	cr.estimated_rent AS total_rent,
	cr.estimated_coffee_consumers_in_millions,
	ct.unique_customer_count,
	ct.average_cost_per_customer,
	ROUND(cr.estimated_rent ::numeric/ct.unique_customer_count::numeric, 2) AS average_rent_per_customer	
FROM city_table as ct
JOIN city_rent as cr
ON ct.city_name = cr.city_name
ORDER BY 2 DESC


/*
Top 3 Recommended Cities

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














