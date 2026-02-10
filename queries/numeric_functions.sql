-- Session 5
-- Task 1.1) total_revenue of company
SELECT
	SUM(total_sales) AS total_revenue
FROM sales_analysis;

-- 1.2) total_revenue by category 
SELECT
	category,
	SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY category;

-- 1.3) Max total_revenue by category
SELECT
	category,
	SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY category
ORDER BY total_revenue DESC;

-- 2) AVG vs MEDIAN by total_sales
SELECT
	AVG(total_sales) AS avg_transaction_value,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) AS median_transaction_value
FROM sales_analysis;

-- 3.1) NULL discount CHECK
SELECT 
	COUNT(*) AS discount_null
FROM sales_analysis
WHERE discount IS NULL;

-- 3.2) average of discount by default
SELECT
	AVG(discount) AS avg_discount_default
FROM sales_analysis;

-- 3.3) by zero imputation
SELECT
	AVG(COALESCE(discount, 0)) AS avg_discount_with_zeros
FROM sales_analysis;

-- 3.4) by average imputation
WITH avg_calc AS (
	SELECT
		AVG(discount) AS avg_discount
	FROM sales_analysis
)
SELECT
	AVG(COALESCE(discount, avg_discount)) AS avg_mean_imputed
FROM sales_analysis, avg_calc;

-- 3.5) by median imputation
WITH mdn_calc AS (
	SELECT
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_sales) AS mdn_discount
	FROM sales_analysis
)
SELECT
	AVG(COALESCE(discount, mdn_discount)) AS mdn_mean_imputed
FROM sales_analysis, mdn_calc;

-- 4) Group transactions into 50-unit revenue ranges
SELECT
	CEILING(total_sales / 50.0) * 50 AS revenue_range,
	COUNT(*) AS transactions_count,
	SUM(total_sales) AS total_revenue
FROM sales_analysis
GROUP BY CEILING(total_sales / 50.0) * 50
ORDER BY transactions_count DESC
LIMIT 1 
-- Use LIMIT 1 to see the dominant revenue range.

-- 5) Checking transaction dublicates
SELECT
	transaction_id,
	COUNT(*) AS dublicate_count
FROM sales_analysis
GROUP BY transaction_id
HAVING COUNT(*) > 1;