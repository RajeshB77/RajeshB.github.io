-- Q1: who is the senior most employee based on kob title ?

SELECT * FROM employee
ORDER BY levels DESC
limit 1

-- Q2: Which countries have the most Invoices?
	
SELECT COUNT(*) as c, billing_country 
FROM invoice
group by billing_country
order by c desc


-- Q3: What are top 3 values of total invoices? 

SELECT total FROM invoice
ORDER BY total desc
LIMIT 3


-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival
-- in the city we made the most money. Write a query that return one city that has the heighest sum on invoice 
-- totals. 
-- Return both the city name & sum of all invoice totals

SELECT SUM(total) total_invoice,billing_city 
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice desc


-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer.
-- Write a query that return the person who has spent the most money

SELECT c.customer_id, c.first_name,c.last_name, SUM(i.total) as total 
FROM customer as c
JOIN invoice as i ON C.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 1

-- Q6: Wriet a query to retrun th email, first name ,last name & Genre of all Rock Music listeners.
-- Retrun your list ordered alphabetically by email starting with A
-- HINT: 1st brack the query sort rock listner first then solve email, lastname of the listner for that used sub-query

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email
	


-- Q7: Let's invite the artists who have written the most rock music in our dataset. 
-- write a query that returns the Artist name and total track count of top 10 bands

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10


-- Q8: Return all the track names that have a song length longer than the average song length
-- Return the Name and Milliseconds for each track.Order by the song with longest song listed first

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds)AS avg_track_length
	FROM track
)
ORDER BY milliseconds DESC	


-- Q9 Advance: Find how much amount spent by each customer on artists? 
-- write a query to return customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


-- Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.


WITH populer_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY Count(invoice_line.quantity) DESC) AS RowNO
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM populer_genre WHERE RowNo <= 1


-- Q11: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.


WITH Customer_with_country AS (
	SELECT C.customer_id, c.first_name, c.last_name,billing_country,SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice 
	JOIN customer c ON c.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC , 5 DESC
)
SELECT * FROM Customer_with_country WHERE RowNo <= 1