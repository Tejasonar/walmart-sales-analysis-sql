-- ===============================
-- DATABASE & TABLE CREATION
-- ===============================

CREATE DATABASE IF NOT EXISTS walmartSales;
USE walmartSales;

CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4),
    rating DECIMAL(3,1)
);

-- ===============================
-- DATA WRANGLING (NULL CHECK)
-- ===============================

SELECT 
    COUNT(*) AS total_rows,
    SUM(invoice_id IS NULL) AS invoice_id_nulls,
    SUM(branch IS NULL) AS branch_nulls,
    SUM(city IS NULL) AS city_nulls,
    SUM(customer_type IS NULL) AS customer_type_nulls,
    SUM(gender IS NULL) AS gender_nulls,
    SUM(product_line IS NULL) AS product_line_nulls,
    SUM(unit_price IS NULL) AS unit_price_nulls,
    SUM(quantity IS NULL) AS quantity_nulls,
    SUM(tax_pct IS NULL) AS tax_pct_nulls,
    SUM(total IS NULL) AS total_nulls,
    SUM(date IS NULL) AS date_nulls,
    SUM(time IS NULL) AS time_nulls,
    SUM(payment IS NULL) AS payment_nulls,
    SUM(cogs IS NULL) AS cogs_nulls,
    SUM(gross_margin_pct IS NULL) AS gross_margin_pct_nulls,
    SUM(gross_income IS NULL) AS gross_income_nulls,
    SUM(rating IS NULL) AS rating_nulls
FROM sales;

-- ===============================
-- FEATURE ENGINEERING (Time_of_Day,Day_Name,Month_Name ADDING NEW COLS)
-- ===============================

ALTER TABLE sales
ADD COLUMN Time_of_Day VARCHAR(15),
ADD COLUMN Day_Name VARCHAR(10),
ADD COLUMN Month_Name VARCHAR(15);

UPDATE sales
SET
    Time_of_Day = CASE
        WHEN time < '12:00:00' THEN 'Morning'
        WHEN time < '18:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END,
    Day_Name = DAYNAME(date),
    Month_Name = MONTHNAME(date);

-- ===============================
-- GENERIC QUESTIONS
-- ===============================

-- Unique cities
SELECT COUNT(DISTINCT city) AS unique_cities FROM sales;

-- Branch per city
SELECT DISTINCT branch, city FROM sales;

-- ===============================
-- PRODUCT ANALYSIS
-- ===============================

-- Unique product lines
SELECT COUNT(DISTINCT product_line) AS unique_product_lines FROM sales;

-- Most common payment method
SELECT payment, COUNT(*) AS count
FROM sales
GROUP BY payment
ORDER BY count DESC
LIMIT 1;

-- Most selling product line
SELECT product_line, SUM(quantity) AS total_sold
FROM sales
GROUP BY product_line
ORDER BY total_sold DESC
LIMIT 1;

-- Total revenue by month
SELECT Month_Name, SUM(total) AS total_revenue
FROM sales
GROUP BY Month_Name
ORDER BY total_revenue DESC;

-- Month with highest COGS
SELECT Month_Name, SUM(cogs) AS total_cogs
FROM sales
GROUP BY Month_Name
ORDER BY total_cogs DESC
LIMIT 1;

-- Product line with highest revenue
SELECT product_line, SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC
LIMIT 1;

-- City with highest revenue
SELECT city, SUM(total) AS revenue
FROM sales
GROUP BY city
ORDER BY revenue DESC
LIMIT 1;

-- Product line with highest VAT (CORRECT)
SELECT product_line, SUM(gross_income) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

-- Product performance (Good / Bad)
SELECT 
    product_line,
    SUM(total) AS revenue,
    CASE
        WHEN SUM(total) >
            (SELECT AVG(product_revenue)
             FROM (
                SELECT SUM(total) AS product_revenue
                FROM sales
                GROUP BY product_line
             ) t)
        THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM sales
GROUP BY product_line;

-- Branch selling more than average
SELECT branch, SUM(quantity) AS total_sold
FROM sales
GROUP BY branch
HAVING SUM(quantity) >
(
    SELECT AVG(branch_qty)
    FROM (
        SELECT SUM(quantity) AS branch_qty
        FROM sales
        GROUP BY branch
    ) t
);

-- Most common product line by gender (CORRECT)
SELECT s.gender, s.product_line, COUNT(*) AS cnt
FROM sales s
GROUP BY s.gender, s.product_line
HAVING COUNT(*) = (
    SELECT MAX(c)
    FROM (
        SELECT COUNT(*) AS c
        FROM sales
        WHERE gender = s.gender
        GROUP BY product_line
    ) t
);

-- Average rating per product line
SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line;

-- ===============================
-- SALES ANALYSIS
-- ===============================

-- Sales count per time of day per weekday
SELECT Day_Name, Time_of_Day, COUNT(*) AS sales_count
FROM sales
GROUP BY Day_Name, Time_of_Day
ORDER BY Day_Name, Time_of_Day;

-- Customer type with highest revenue
SELECT customer_type, SUM(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC
LIMIT 1;

-- City with highest VAT (CORRECT)
SELECT city, SUM(gross_income) AS total_vat
FROM sales
GROUP BY city
ORDER BY total_vat DESC
LIMIT 1;

-- Customer type paying most VAT (CORRECT)
SELECT customer_type, SUM(gross_income) AS total_vat
FROM sales
GROUP BY customer_type
ORDER BY total_vat DESC
LIMIT 1;

-- ===============================
-- CUSTOMER ANALYSIS
-- ===============================

-- Unique customer types
SELECT COUNT(DISTINCT customer_type) AS customer_types FROM sales;

-- Unique payment methods
SELECT COUNT(DISTINCT payment) AS payment_methods FROM sales;

-- Most common customer type
SELECT customer_type, COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC
LIMIT 1;

-- Customer type buying most products
SELECT customer_type, SUM(quantity) AS total_items
FROM sales
GROUP BY customer_type
ORDER BY total_items DESC
LIMIT 1;

-- Gender with most customers
SELECT gender, COUNT(*) AS count
FROM sales
GROUP BY gender
ORDER BY count DESC
LIMIT 1;

-- Gender distribution per branch
SELECT branch, gender, COUNT(*) AS count
FROM sales
GROUP BY branch, gender;

-- Time of day with best ratings
SELECT Time_of_Day, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY Time_of_Day
ORDER BY avg_rating DESC
LIMIT 1;

-- Best rating time per branch
SELECT branch, Time_of_Day, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY branch, Time_of_Day
ORDER BY branch, avg_rating DESC;

-- Best rating day of week
SELECT Day_Name, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY Day_Name
ORDER BY avg_rating DESC
LIMIT 1;

-- Best rating day per branch
SELECT branch, Day_Name, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY branch, Day_Name
ORDER BY branch, avg_rating DESC;