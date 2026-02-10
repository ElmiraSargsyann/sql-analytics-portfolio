-- Session 2
-- Task 1 

-- Employees emails must be unique
ALTER TABLE employees
ADD CONSTRAINT uq_employees_email UNIQUE (email);

-- Emoployees phone numbers must be mandatory
ALTER TABLE employees
ALTER COLUMN phone_number SET NOT NULL;

-- Product prices must be non-negative
ALTER TABLE products
ADD CONSTRAINT chk_products_price CHECK (price >= 0);

-- Sales totals must be non-negative
ALTER TABLE sales
ADD CONSTRAINT chk_sales_total CHECK (total_sales >= 0);

-- Task 2
-- Add a new column to the sales table
ALTER TABLE sales
ADD COLUMN sales_channel TEXT;

-- Add a constraint to enforce valid values.
ALTER TABLE sales
ADD CONSTRAINT chk_sales_channel
CHECK (sales_channel IN ('online', 'store'));

-- All even transaction_ids are 'online' because transaction_id % 2 = 0 selects even numbers.
UPDATE sales
SET sales_channel = 'online'
WHERE transaction_id % 2 = 0;

-- Task 3
Add Indexes for Query Performance
-- Indexes improves performance

CREATE INDEX idx_sales_product_id
ON sales (product_id);

CREATE INDEX idx_sales_customer_id
ON sales (customer_id);

CREATE INDEX idx_products_category
ON products (category);

-- Task 4
-- Validate Index Usage with EXPLAIN

EXPLAIN
SELECT
  product_id,
  SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id;

Query plan:
"HashAggregate  (cost=143.00..144.25 rows=100 width=36)"
"  Group Key: product_id"
"  ->  Seq Scan on sales  (cost=0.00..118.00 rows=5000 width=10)"
-- Seq Scan - последовательное сканирование таблицы

-- Task 5
-- Reduce Query Cost by Refining SELECT

SELECT *
FROM sales;
-- The original query selects all columns from the sales table using SELECT *, which can be inefficient if only some columns are needed.

SELECT
  transaction_id,
  product_id,
  total_sales
FROM sales;
-- This query selects only the transaction_id, product_id, and total_sales columns from the sales table,
-- which is more efficient than SELECT * because it retrieves only the data needed.

1.why this reduces cost?
This reduces cost because the query selects only the needed columns (transaction_id, product_id, total_sales)
instead of all columns (SELECT *). Reading fewer columns means less data is processed and transferred, which makes the query more efficient.

2.when SELECT * might still be acceptable?
SELECT * might still be acceptable when using LIMIT, because only a small number of rows are retrieved, so the performance impact is minimal.

-- Task 6
-- ORDER BY and LIMIT for Business Questions
-- Marketing wants to identify the top 5 products by total revenue.

SELECT
	product_id,
	SUM(total_sales) AS total_revenue
FROM sales
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 5;

-- Query plan:
"Limit  (cost=145.91..145.92 rows=5 width=36)"
"  ->  Sort  (cost=145.91..146.16 rows=100 width=36)"
"        Sort Key: (sum(total_sales)) DESC"
"        ->  HashAggregate  (cost=143.00..144.25 rows=100 width=36)"
"              Group Key: product_id"
"              ->  Seq Scan on sales  (cost=0.00..118.00 rows=5000 width=10)"
sorting cost 146.16 - 145.91 = 0.25
whether indexes help in this case - ?

-- Task 7
-- Retrieve unique combinations of category and price using DISTINCT and GROUP BY.

-- Using DISTINCT
EXPLAIN
SELECT DISTINCT
  category,
  price
FROM products;

Query plan
"HashAggregate  (cost=3.50..4.50 rows=100 width=15)"
"  Group Key: category, price"
"  ->  Seq Scan on products  (cost=0.00..3.00 rows=100 width=15)"

-- Using GROUP BY
EXPLAIN
SELECT
  category,
  price
FROM products
GROUP BY category, price;

Query plan
"HashAggregate  (cost=3.50..4.50 rows=100 width=15)"
"  Group Key: category, price"
"  ->  Seq Scan on products  (cost=0.00..3.00 rows=100 width=15)"

-- they are the same
-- "Essentially, the task is the same: to find the unique combinations of (category, price)."

-- Task 8 | Constraint Enforcement Test

UPDATE products
SET price = -5
WHERE product_id = 101;
-- This code updates the price of the product with `product_id = 101` and sets it to -5.

INSERT INTO customers (customer_id, email, phone_number)
VALUES (999, 'anna@example.com', '091000999');
-- Error happens because customer_id is a primary key and must be unique—duplicates aren’t allowed.
-- It protects data quality because primary keys ensure each record is unique.
-- If keys could repeat, the table could have duplicate rows, making the database incorrect and unreliable.

-- Task 9 | Reflection
1.Which constraints provide the highest business value?
NOT NULL — helps prevent loss of important customer information (e.g., phone number or email).
PRIMARY KEY — prevents duplicate orders and customers, protecting data and saving money.
These constraints help a business **save money and avoid errors**.

2.Which index would you prioritize in a production environment?
In a production environment, priority is given to indexes on columns that are most frequently used in `SELECT` queries, such as primary keys or columns often used in `WHERE` and `JOIN` conditions.

3.What signals tell you a query needs optimization?
It takes a very long time to execute.


