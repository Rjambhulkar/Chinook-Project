
select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

/***
-- SQL Project Idea: Below is a few sample questions you can attempt to practice on this database.

    --> Which city corresponds to the best customers?

    --> The highest number of invoices belongs to which country?

    --> Name the best customer (customer who spent the most money).

    --> Suppose you want to host a rock concert in a city and want to know which location should host it. Query the dataset to find the city with the most rock-music listeners to answer this question.

    --> If you want to know which artists the store should invite, find out who is the highest-paid and most-listened-to.
***/

-- Steps followed during projects:
1. Extract the dataset
2. Analyse the data (identify relations between different tables)
3. Cleansing of data
4. Draw insights from data (solve problems or answers given questions using data) / Visualize data to share with stakeholders.

-- Cleansing of data:
1. remove redundant data or incorrect data
2. Exclude data which is not required for your project.
3. Fixing wrong data.
4. etc etc.

1) Are there any albums owned by multiple artist?
    select albumid, count(1) from Album
    group by albumid
    having count(1) > 1;
2) Is there any invoice which is issued to a non existing customer?
    select * from Invoice I
    where not exists (select * from customer c
                      where c.customerid = I.customerid)
3) Is there any invoice line for a non existing invoice?
4) Are there albums without a title?
5) Are there invalid tracks in the playlist?
6) etc...


-- SQL Queries to answer some questions from the chinook database.

	select * from Album; -- 347
	select * from Artist; -- 275
	select * from Customer; -- 59
	select * from Employee; -- 8
	select * from Genre; -- 25
	select * from Invoice; -- 412	
	select * from InvoiceLine; -- 2240
	select * from MediaType; -- 5
	select * from Playlist; -- 18
	select * from PlaylistTrack; -- 8715
	select * from Track; -- 3503

	
1)Find the artist who has contributed with the maximum no of songs. Display the artist name and the no of albums.
with cte as
		(select ar.name as artist_name, count (1)as no_of_songs
		 , rank () over (order by count(1)desc)as rnk
		from track t
		join album a on a.albumid = t.albumid
		join artist ar on ar.artistid = a.artistid
		group by ar.name)
select artist_name, no_of_songs
from cte
where rnk = 1;



2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.
with cte as 
		(select concat(c.firstname,' ',c.lastname)as listener, g.name as music ,c.email,c.country
		 from invoice i
		 join invoiceline il on i.invoiceid = il.invoiceid
		 join track t on t.trackid = il.trackid
		 join genre g on g.genreid = t.genreid
		 join customer c on c.customerid = i.customerid)
select *
from cte
where music in ('Pop','Jazz','Rock');

    /*   select concat(c.firstname,' ',c.lastname)as listener, g.name as music ,c.email,c.country
		 from invoice i
		 join invoiceline il on i.invoiceid = il.invoiceid
		 join track t on t.trackid = il.trackid
		 join genre g on g.genreid = t.genreid
		 join customer c on c.customerid = i.customerid
         where music in ('Pop','Jazz','Rock');
      */

3) Find the employee who has supported the most no of customers. Display the employee name and designation



4) Which city corresponds to the best customers?
with cte as 
		(select billingcity as city ,count(1)
		,rank() over(order by count(1) desc) as rnk
		from Invoice i
		join invoiceline il on i.invoiceid = il.invoiceid
		group by city )
 select * from cte 
 where rnk = 1;

5) The highest number of invoices belongs to which country?
select billingcountry ,count(1) 
from Invoice
group by  billingcountry 
order by 2 desc

6) Name the best customer (customer who spent the most money).
with cte as
		(select concat(c.firstname, ' ', c.lastname)as name ,sum(total) 
		,rank() over(order by sum(total) desc) as rnk
		 from customer c 
		 join invoice i on c. customerid = i.customerid
		 group by name)
select * from cte
where rnk =1;

7) Suppose you want to host a rock concert in a city and want to know which location should host it.

	with cte as 
				(select  g.name, i.billingcity as city 
				from invoice i
				join invoiceline il on i.invoiceid = il.invoiceid
				join track t on t.trackid = il.trackid
				join genre g on g.genreid = t.genreid
				where g.name = 'Rock' ),
			bkchodi as
				(select city ,count (1)
				,rank() over(order by count(1 ) desc)as rnk
				from cte 
				group by city)
	select city from bkchodi
	where rnk =1


8) Identify all the albums who have less then 5 track under them.

select a.title as albumname ,count(1)as tracks
from track t
join album a on a.albumid = t.albumid
group by albumname 
having count(1)< 5 
order by count(1) desc;

9) Display the track, album, artist and the genre for all tracks which are not purchased.

with cte as 
			(select t.name as track_name,a.title,ar.name,g.name
			from track t 
			join album a on a.albumid = t.albumid
			join artist ar on ar.artistid = a.artistid
			join genre g on g.genreid = t.genreid
			 join invoiceline il on il.trackid = t.trackid)
			select * from cte
where cte.trackid <>il.invoicelineid ;

10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

with cte as 
			(select distinct  a.name as artist,g.name as genre
			from album al
			join artist a on a.artistid = al.artistid
			join track t on t.albumid = al.albumid
			join genre g on g.genreid = t.genreid),
		wc as 	
			(select artist ,count(1)
			from cte 
			group by artist
			having count(1)>1
			order by 1)			
select w.artist ,c.genre
from wc w
join cte c on w.artist =c.artist
order by 1,2

11) Which is the most popular and least popular genre? (Popularity is defined based on how many times it has been purchased.
		
with cte as 
			(select g.name ,count(1),
			rank () over(order by count(1) desc) as rnk
			from invoiceline il
			join track t on il.trackid =t.trackid
			join genre g on g.genreid = t.genreid
			group by g.name)
select name ,  'most popular' as popularity
from cte 
where rnk =1
union 
select name ,  'least_popular'as popularity
from cte
where rnk in (select max(rnk) from cte)

																					
														
12) Identify if there are tracks more expensive than others.
If there are then display the track name along with the album title and artist name for these expensive tracks.


	select t.name,al.title,a.name,t.unitprice
	from track t 
	join album al on al.albumid = t.albumid
	join artist a on a.artistid = al.artistid
	order by 4 desc

13) Identify the 5 most popular artist for the most popular genre. 
Display the artist name along with the no of songs. 
(Popularity is defined based on how many songs an artist has performed in for the particular genre.)
with cte as 
	(select g.genreid,g.name as genre ,count(1)--,a.name
	,rank() over (order by count(1) desc) as rnk 
	from track t
	join genre g on g.genreid = t.genreid
	join album al on al.albumid = t.albumid
	join artist a on a.artistid = al.artistid
	group by g.genreid,g.name),
populargenre as
		(select genreid,genre
		from cte
		where rnk =1),
finalw as		
		(select ar.name as artist_name ,count(1)as no_of_songs,
		rank() over(order by count(1) desc )as rnk 
		from populargenre pg 
		join track t on t.genreid = pg.genreid
		join album al on al.albumid = t.albumid
		join artist ar on ar.artistid = al.artistid
		join genre g on g.genreid = t.genreid
		group by ar.name)
select artist_name,no_of_songs
from finalw
where rnk <6
	
	
	
	
	
	
	
	
	
	