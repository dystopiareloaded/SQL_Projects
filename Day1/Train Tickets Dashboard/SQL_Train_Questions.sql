USE sql_dashboard;
SELECT * FROM train_tickets;
-- 1. List all unique train names

SELECT DISTINCT(train_name) FROM train_tickets;

-- 2. Find all tickets where the class is 'Sleeper'

SELECT ticket_id, class FROM train_tickets 
WHERE class = 'Sleeper';

-- 3. Get all bookings from ‘Delhi’ to ‘Mumbai’.

SELECT * FROM train_tickets
WHERE source = 'Delhi' AND destination = 'Sealdah';

-- 4. List all distinct travel dates in the dataset.
SELECT DISTINCT(travel_date) FROM train_tickets
ORDER BY travel_date;

-- 5. Find how many tickets are booked for each class.
SELECT class, COUNT(*) AS 'Total_Bookings' FROM train_tickets
GROUP BY class;

-- 6. Get total revenue generated per class.
SELECT class, SUM(price) AS total_revenue FROM train_tickets
GROUP BY class;

-- 7. Calculate the average price for each class.
SELECT class, AVG(price) AS AVG_Price FROM train_tickets
GROUP BY class;

-- 8. Find the number of trains operating from each source station.
SELECT source, COUNT(DISTINCT train_name) FROM train_tickets
GROUP BY source;

-- 9. Get top 5 source stations by total seats.
SELECT source, SUM(booked_seats) AS total_bookings FROM train_tickets
GROUP BY source
ORDER BY total_bookings DESC LIMIT 5;

-- Get top 5 source stations by total bookings
SELECT source, COUNT(*) AS Bookings
FROM train_tickets
GROUP BY source
ORDER BY Bookings DESC;

-- 10. Find the route (source → destination) with the highest number of bookings.

SELECT source, destination, COUNT(*) AS Bookings FROM train_tickets
GROUP BY source, destination
ORDER BY Bookings DESC;

-- 11. Find trains with more than 80% seats booked.

SELECT DISTINCT train_name FROM train_tickets
WHERE (booked_seats / total_seats) > 0.8;

-- 12. Calculate total revenue generated per day

SELECT travel_date, SUM(price) as total_revenue FROM train_tickets
GROUP BY travel_date
ORDER BY travel_date;

-- 13. List trains operating on ‘Monday’.

SELECT DISTINCT train_name FROM train_tickets
WHERE days_of_operation LIKE '%Mon%';

-- 14. Rank routes by number of bookings.

SELECT source, destination, COUNT(*) AS Total_Bookings, RANK() OVER(ORDER BY COUNT(*) DESC) AS Booking_Rank
FROM train_tickets
GROUP BY source, destination;

-- Fetch daily bookings

SELECT travel_date, COUNT(*) AS Bookings FROM train_tickets
GROUP BY travel_date
ORDER BY travel_date;

select distinct class from train_tickets
