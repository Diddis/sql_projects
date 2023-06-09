
-- View the top 10 rows of the data.
SELECT TOP 10 *
  FROM supermarket_sales;

-- Count number of sales per branch.
SELECT s.branch, COUNT(*) AS sales_count
  FROM supermarket_sales AS s
 GROUP BY s.branch
 ORDER BY s.branch;

 -- Count number of sales per product line.
SELECT s.product_line, COUNT(*) AS sales_count
  FROM supermarket_sales AS s
 GROUP BY s.product_line
 ORDER BY s.product_line;

-- Count number of sales per branch and product line.
SELECT s.branch, s.product_line, COUNT(*) AS sales_count
  FROM supermarket_sales AS s
 GROUP BY s.branch, s.product_line
 ORDER BY s.branch, s.product_line;

-- Compare total gross profit and average transaction profit by branch
SELECT s.branch, SUM(s.gross_income) AS gross_profit, AVG(s.gross_income) AS average_sale_profit
  FROM supermarket_sales AS s
  GROUP BY s.branch;

-- Do members or normal customers spend more?
SELECT s.customer_type, 
	   SUM(s.total_price) AS total_spending, 
	   AVG(s.total_price) AS average_spending
  FROM supermarket_sales AS s
 GROUP BY s.customer_type;

 -- Do members or normal customers spend more, by male/female?
SELECT s.customer_type, 
	   s.gender,
	   COUNT(*) AS customer_count,
	   SUM(s.total_price) AS total_spending,
	   SUM(s.total_price)/COUNT(*) AS ave_spending_per_customer
  FROM supermarket_sales AS s
 GROUP BY s.customer_type, s.gender
 ORDER BY s.customer_type, s.gender;


-- When during the day do the highest value sales occur?
--Create new time column with hour as INT.
ALTER TABLE supermarket_sales
	ADD time_hour INT NULL;
UPDATE supermarket_sales
	SET time_hour = SUBSTRING([time], 1, 2);

-- View the range of time when sales are made.
SELECT time_hour, COUNT(*)
  FROM supermarket_sales
  GROUP BY time_hour
  ORDER BY time_hour;

-- Display the average total price paid during morning, afternoon, and evening.
SELECT TOP 1 
	   (SELECT AVG(total_price) FROM supermarket_sales WHERE time_hour < 12) AS ave_sale_morning,
	   (SELECT AVG(total_price) FROM supermarket_sales WHERE time_hour > 11 AND time_hour < 18) AS ave_sale_afternoon,
	   (SELECT AVG(total_price) FROM supermarket_sales WHERE time_hour > 17) AS ave_sale_evening
  FROM supermarket_sales;