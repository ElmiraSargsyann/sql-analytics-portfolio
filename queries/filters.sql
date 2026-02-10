-- Session 4
-- Task 1 | Complex Transaction Segmentation (CASE + WHERE)

SELECT
	transaction_id,
	total_sales,
	discount,
	category,
	city,
	CASE
		WHEN total_sales >= 400
			AND category = 'Electronics'
			AND discount <= 0.10
			THEN 'High-value Electronics transactions with low discount'
		WHEN total_sales >= 200
			AND discount > 0.10 AND discount <= 0.50
			THEN 'Medium-value transactions with moderate discount'
		WHEN total_sales < 200
			OR discount > 0.50
		THEN 'Low-value or heavily discounted transactions'
		WHEN category = 'books' AND city = 'Brookehaven'
		THEN 'Unique transactions'
		ELSE 'Other transactions'
	END AS business_segment
FROM sales_analysis
WHERE year = 2023;

-- Task 2 | Category-Level Performance Analysis (CASE + GROUP BY + HAVING)
SELECT
	category,
	SUM(total_sales) AS total_revenue,
	COUNT(transaction_id) AS transaction_count,
	AVG(discount) AS avg_discount,
	CASE
		WHEN COUNT(transaction_id) > 300 THEN 'Strong Performer'
		WHEN COUNT(transaction_id) BETWEEN 250 AND 300 THEN 'Average Performer'
		ELSE 'Underperformer'
	END AS performance_label
FROM sales_analysis
WHERE year = 2023
GROUP by category
HAVING COUNT(transaction_id) > 100
ORDER BY total_revenue DESC;

-- Task 3 | City-Level Activity Analysis (COUNT + HAVING + CASE)
SELECT
	city,
	COUNT(transaction_id) AS transaction_count,
	CASE
		WHEN COUNT(transaction_id) >= 4 THEN 'High Activity'
		WHEN COUNT(transaction_id) BETWEEN 2 AND 4 THEN 'Medium Activity'
		ELSE 'Low Activity'
	END AS activity_level
FROM sales_analysis
WHERE year = 2023
GROUP BY city
HAVING COUNT(transaction_id) > 1
ORDER BY transaction_count DESC;

-- Task 4 | Discount Behavior Analysis (CASE + HAVING)
SELECT
	category,
	SUM(total_sales) AS total_revenue,
	AVG(discount) AS avg_discount,
	CASE
		WHEN AVG(discount) > 0.40 THEN 'High Discount'
		WHEN AVG(discount) BETWEEN 0.20 AND 0.40 THEN 'Moderate Discount'
		ELSE 'Low or No Discount'
	END AS discount_category
FROM sales_analysis
GROUP BY category
HAVING COUNT(*) > 5
ORDER BY SUM(total_sales) DESC;