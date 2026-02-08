Session 2

Task 1 
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

Task 2
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

Task 3
Add Indexes for Query Performance
-- Indexes improves performance

CREATE INDEX idx_sales_product_id
ON sales (product_id);

CREATE INDEX idx_sales_customer_id
ON sales (customer_id);

CREATE INDEX idx_products_category
ON products (category);

Task 4
Validate Index Usage with EXPLAIN

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

Task 5
Reduce Query Cost by Refining SELECT

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

-- 1.why this reduces cost
-- This reduces cost because the query selects only the needed columns (transaction_id, product_id, total_sales)
-- instead of all columns (SELECT *). Reading fewer columns means less data is processed and transferred, which makes the query more efficient.

-- 2.when SELECT * might still be acceptable
-- SELECT * might still be acceptable when using LIMIT, because only a small number of rows are retrieved, so the performance impact is minimal.