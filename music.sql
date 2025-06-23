use music;

/* WHO IS THE SENIOR MOST EMPLOYEE BASED ON THE JOB TITLE */

select * from employee
order by levels desc
limit 1;

/* WHICH COUNRTY HAVE THE MOST INVOICES */

select count( * ) as c,billing_country
from invoice
group by billing_country
order by c desc;

/* WHAT IS TOP 3 TOTAL VALUES OF INVOICE */

select total from invoice
order by total desc
limit 3;

/* WHICH CITY HAS THE BEST CUSTOMER? 
QUERY TO RETURN ONE CITY WHICH HAS THE HIGHEST SUM OF INVOICE TOTALS
RETURN BOTH CITY NAME & SUM OF ALL INVOICE TOTALS */

select sum(total) as invoice_total,billing_country
from invoice
group by billing_country
order by invoice_total desc;

/* WHO IS THE BEST CUSTOMER? WHO HAS SPENT THE MOST MONEY WILL BE DECLARED AS THE BEST CUSTOMER
QUERY THAT RETURNS THE PERSON WHO HAS SPENT THE MOST MONEY */

select customer.customer_id, customer.first_name,customer.last_name,sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name 
order by total desc
limit 1;

/* Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct email,first_name,last_name
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in(
select track_id from track 
join genre on track.genre_id = genre.genre_id
where genre.name like 'ROCK'
)
order by email;

/* Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs
from track
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'ROCK'
group by artist.artist_id, artist.name
order by number_of_songs desc
limit 10;


SELECT * FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist on artist.artist_id = album2.artist_id
JOIN genre on genre.genre_id = track.genre_id
where genre.name like 'ROCK'
LIMIT 10;

/* Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds
from track
where milliseconds >
(
select avg(milliseconds) as avg_song_length
from track
)
order by milliseconds desc;

/* Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with best_selling_artist as (
select artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
group by 1,2
order by total_sales desc
limit 1
)
select * from best_selling_artist; 
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album2 alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by 5 desc;

/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH popular_genre AS
(
SELECT COUNT(invoice_line.quantity) as purchases,customer.country,genre.name,genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity)desc) as row_no
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre where row_no <=1;

/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH customer_with_Country as
(
select customer.customer_id,customer.first_name,customer.last_name,billing_country,sum(total) 
as total_spending,
row_number() over(partition by billing_country order by sum(total) desc) as ROWNO
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 4 asc ,5 desc),
country_max_spending as(
select billing_country,max(total_spending) as max_spending
from customer_with_country
group by billing_country)
select cc.customer_id,cc.first_name,cc.last_name,cc.billing_country,cc.total_spending
from customer_with_country cc
join country_max_spending ms
on cc.billing_country=ms.billing_country
where cc.total_spending=ms.max_spending
order by 1;

select * from customer_with_Country where ROWNO <=1
