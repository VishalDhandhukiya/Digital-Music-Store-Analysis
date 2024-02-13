#1 Who is the senior most employee based on job title?

Select * From employee
Order by levels desc
limit 1;

#2 Which countries have the most Invoices?

select billing_country,
	   count(invoice_id) as Count
From invoice
Group by 1
order by Count desc;

#3 What are top 3 values of total invoice?

select invoice_id,
	   Total
From invoice
order by Total desc
limit 3;

#4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

Select billing_City,
	   sum(total) as Invoice_totals
From invoice
Group by 1
order by 2 desc
limit 1;

#5 Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

Select T2.customer_id,
	   T2.first_name,
       T2.last_name,
	   sum(T1.Total) as Total_Spent
From invoice as T1 Inner Join Customer as T2 Using(Customer_id)
group by 1,2,3
order by 4 desc
limit 1;

#6 Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

Select distinct(T1.email),
	   T1.First_name,
       T1.Last_name
From customer as T1 Inner Join invoice as T2 Using(customer_id)
					   Inner Join invoice_line as T3 Using(invoice_id)
                       Inner Join track as T4 Using(track_id)
                       Inner Join genre as T5 Using(genre_id)
Where T5.name="Rock"
order by T1.Email;

#7 Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

Select T1.artist_ID,
	    T1.name,
	   Count(*) as "Total Track"
From Artist as T1 Inner join album as T2 Using(artist_Id)
			      Inner join track as T3 Using(album_id)
                  Inner join genre as T4 Using(genre_id)
Where T4.name like "Rock"
Group by 1,2
order by 3 desc
limit 10;

#8 Return all the track_id that have a song length longer than the average song length.
-- Return the track_id and Milliseconds for each track. Order by the song length with the longest songs listed first

Select track_id,
	   milliseconds
From track
where milliseconds > (Select avg(milliseconds) from track)
order by 2 desc;

#9 Find how much amount spent by each customer on artists? Write a query to return Customer name, artist name and total spent

With Project as
(
	Select T1.artist_id,T1.name,sum(T4.quantity*T4.unit_price) as Total_Spent
    From artist as T1 Inner Join album as T2 Using(artist_id)
					  Inner Join track as T3 Using(album_id)
					  Inner Join invoice_line as T4 Using(track_id)
	Group by 1,2
    order by 3 desc
    limit 1
)

Select T1.customer_id,T1.first_name,T1.Last_name,T6.name,sum(T3.quantity*T3.unit_price) as Total_Spent
From Customer as T1 Inner Join Invoice as T2 Using(customer_id)
					Inner Join invoice_line as T3 Using(Invoice_Id)
					Inner Join track as T4 Using(track_id)
                    Inner Join album as T5 Using(Album_Id)
                    Inner Join Project as T6 Using(artist_id)
Group by 1,2,3,4
Order by 5 desc;
                    
#10 We want to find out the most popular music Genre for each country. 
--  We determine the most popular genre as the genre with the highest amount of purchases. 
--  Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.

Select Country,name,Total
From 
	(Select Country,name,Total,dense_rank() Over(partition by Country order by Total desc) as Rankk
	From (Select T1.billing_country as Country,T4.genre_id,T4.name,Count(T1.invoice_id) as Total
		  From invoice as T1 Inner Join invoice_line as T2 Using(invoice_id)
				   Inner Join track as T3 Using(track_id)
                   Inner Join genre as T4 Using(genre_id)
				   Group by 1,2,3
				   Order by 4 desc) as Project) as Final
Where Rankk=1;


#11 Write a query that determines the customer that has spent the most on music for each country. 
--  Write a query that returns the country along with the top customer and how much they spent. 
--  For countries where the top amount spent is shared, provide all customers who spent this amount.

With CTE as
(
Select T1.first_name,
	   T1.last_name,
       T1.country,
       Sum(T2.Total) as Total
From customer as T1 Inner Join Invoice as T2 Using(Customer_ID)
Group by 1,2,3
)

Select country,  first_name, last_name,Total
From(
		Select  first_name,last_name, country,Total, Dense_rank() over(partition by country order by Total desc) as Rankk
		From CTE
	 ) as Projectt
Where Rankk=1;