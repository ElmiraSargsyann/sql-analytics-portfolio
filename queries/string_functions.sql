-- Session 6
-- Task 1 | Phone Number Diagnostics
SELECT
	raw_phone,
	LENGTH(raw_phone) AS phone_length,
	POSITION('-' IN raw_phone) AS open_hyphen_pos,
	POSITION('(' IN raw_phone) AS open_paren_pos,
	COUNT(*) AS phone_count
FROM transactions_text_demo
GROUP BY raw_phone, LENGTH(raw_phone), POSITION('-' IN raw_phone), POSITION('(' IN raw_phone);

-- Task 2 | Category Fragmentation
SELECT
	category_raw,
	COUNT(*) AS transactions_count
FROM transactions_text_demo
GROUP BY category_raw
ORDER BY COUNT(*) DESC;
-- 1.How many logical categories exist?
-- 2.How many categories appear due to annotations?
-- Logically, there are 2 categories (Electronics, Accessories), but because of the annotations, it ended up being 5.

-- Part 1 | Profiling
SELECT
	raw_phone,
	LENGTH(raw_phone) AS phone_length,
	COUNT(*) AS occurrences
FROM transactions_text_demo
GROUP BY raw_phone
ORDER BY occurrences DESC;

SELECT
	LENGTH(raw_phone) AS phone_length,
	COUNT(*) AS total_rows,
	COUNT(DISTINCT raw_phone) AS distinct_raw_phone
FROM transactions_text_demo
GROUP BY LENGTH(raw_phone);

SELECT
	category_raw,
	COUNT(*) AS transactions
FROM transactions_text_demo
GROUP BY category_raw;

SELECT
	COUNT(*) AS total_rows,
	COUNT(DISTINCT category_raw) AS distinct_category_raw
FROM transactions_text_demo;
-- Due to dirty text, the GROUP BY returns 5 categories instead of 2.

-- Part 2 | Standardization Layer
SELECT
	SUBSTRING(digits_only FROM LENGTH(digits_only) - 7 FOR 8) AS phone_core,
	REGEXP_REPLACE(category_raw, '\s*\(.*?\)', '', 'g') AS cleaned_category,
	quantity * price AS revenue_per_transaction
FROM (
	SELECT
		raw_phone,
		category_raw,
		quantity,
		price,
		REGEXP_REPLACE(raw_phone, '[^0-9]', '', 'g') AS digits_only
	FROM transactions_text_demo
) AS sub;


-- Part 3 | KPI Comparison
-- 3.1) revenue by raw category
SELECT
	category_raw,
	SUM(quantity*price) AS revenue_raw
FROM transactions_text_demo
GROUP BY category_raw
ORDER BY revenue_raw DESC;

-- 3.2) revenue by cleaned category
SELECT
    REGEXP_REPLACE(category_raw, '\s*\(.*?\)', '', 'g') AS cleaned_category,
    SUM(quantity * price) AS revenue_cleaned
FROM transactions_text_demo
GROUP BY cleaned_category
ORDER BY revenue_cleaned;

-- 3.3) unique customers (raw vs cleaned phone)
SELECT
	COUNT(DISTINCT raw_phone) AS unique_phone_raw,
	COUNT(DISTINCT REGEXP_REPLACE(raw_phone, '[^0-9]', '', 'g')) AS unique_phone_cleaned
FROM transactions_text_demo;

-- Part 4 | Analytical Explanation
-- KPI changes occurred because there were excessive category annotations initially, causing inconsistencies in the numbers. After data cleaning, the results are clear and accurate.
-- The removal of excessive or incorrect category annotations had the greatest impact, as it aligned the numbers correctly and clarified the KPIs.
-- We assumed that all revenue values in the Electronics category were correctly assigned, and that any discrepancies were due to mislabelled or excessive category annotations. We also assumed that after cleaning, the remaining data accurately represents real sales.
-- Unexpected data formatting issues, missing or mislabelled category annotations, and subtle calculation errors in KPIs can silently break the results during production if not properly monitored