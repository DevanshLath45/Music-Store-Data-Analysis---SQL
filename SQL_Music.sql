USE music

--Q1) Who is the senior most employee based on job title?  

SELECT TOP 1 * FROM employee
ORDER BY levels DESC;

--Q2) Which countries have the most Invoices? 

SELECT billing_country, COUNT(billing_country) AS highest_billed_country FROM invoice
GROUP BY billing_country
ORDER BY highest_billed_country DESC;

--Q3) What are top 3 values of total invoice? 

SELECT TOP 3 total AS total_invoice FROM invoice
ORDER BY total DESC;

--Q4) Which city has the best customers? Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

SELECT billing_city, SUM(total) AS invoice_total from invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

--Q5) The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.

SELECT TOP 1 c.customer_id, c.first_name, c.last_name, SUM(i.total) AS most_spent
FROM customer AS c
INNER JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY most_spent DESC;

--Q6) Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.

SELECT a.name AS music_type, x.first_name, x.last_name, x.email
FROM genre AS a
INNER JOIN track AS b
ON a.genre_id = b.genre_id
INNER JOIN invoice_line AS c
ON b.track_id = c.track_id
INNER JOIN invoice AS d
ON c.invoice_id = d.invoice_id
INNER JOIN customer AS x
ON d.customer_id = x.customer_id
WHERE a.name LIKE 'Rock'
GROUP BY a.name, x.first_name, x.last_name, x.email
ORDER BY email ASC;

--Q7) Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT TOP 10 a.artist_id, a.name AS artist_name, COUNT(x.genre_id) AS rock_count
FROM artist AS a
INNER JOIN album AS b
ON a.artist_id = b.artist_id
INNER JOIN track AS c
ON b.album_id = c.album_id
INNER JOIN genre AS x
ON c.genre_id = x.genre_id
WHERE x.name LIKE 'ROCK'
GROUP BY a.artist_id, a.name
ORDER BY rock_count DESC;

--Q8) Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the  longest songs listed first.

SELECT name AS track_names, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

--Q9) Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

SELECT c.customer_id, c.first_name, c.last_name, a.name AS artist_name, 
SUM(i.unit_price * i.quantity) AS total_spent
FROM customer AS c
INNER JOIN invoice AS b
ON c.customer_id = b.customer_id
INNER JOIN invoice_line AS i
ON b.invoice_id = i.invoice_id
INNER JOIN track AS d
ON i.track_id = d.track_id
INNER JOIN album AS e
ON d.album_id = e.album_id
INNER JOIN artist AS a
ON e.artist_id = a.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, a.name
ORDER BY total_spent DESC;

--Q10) We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest number of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres 

WITH RankedPurchases AS (
			SELECT i.billing_country AS country_name, g.name AS genre, g.genre_id AS id, 
			COUNT(a.unit_price * a.quantity) AS purchases, 
			ROW_NUMBER() OVER (PARTITION BY i.billing_country 
			ORDER BY COUNT(a.unit_price * a.quantity) DESC) AS row_num
    		FROM invoice AS i
    		INNER JOIN invoice_line AS a
    		ON i.invoice_id = a.invoice_id
    		INNER JOIN track AS b
    		ON a.track_id = b.track_id
    		INNER JOIN genre AS g
    		ON b.genre_id = g.genre_id
    		GROUP BY i.billing_country, g.name, g.genre_id
)
SELECT country_name, genre, id, purchases
FROM RankedPurchases
WHERE row_num = 1
ORDER BY country_name;

--Q11) Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. 

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
ORDER BY country;








