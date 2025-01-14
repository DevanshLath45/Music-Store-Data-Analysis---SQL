USE music_database

SELECT count(DISTINCT billing_country) FROM invoice



SELECT * FROM customer

WITH new AS (
	SELECT c.customer_id, MAX(c.first_name) AS first_name, MAX(c.last_name) AS last_name, 
	i.billing_country AS country, SUM(i.total) AS total_spent,
	ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS row_num
	FROM customer AS c
	INNER JOIN invoice AS i
	ON c.customer_id = i.customer_id
	GROUP BY c.customer_id, i.billing_country
)
SELECT * FROM new
WHERE row_num = 1
ORDER BY country
