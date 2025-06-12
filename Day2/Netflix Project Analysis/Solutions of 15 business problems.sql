USE sql_kaggle;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*) AS total_content
FROM netflix GROUP BY type;

-- 2. Find the most common rating for movies and TV shows.

SELECT type, rating, count
FROM (
    SELECT type, rating, COUNT(*) AS count,
           RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    GROUP BY type, rating
) AS ranked
WHERE rnk = 1;


-- 3. List all movies released in a specific year (e.g., 2020).

SELECT * FROM netflix
WHERE type = 'Movie'
AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix.

SELECT country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country
    FROM netflix
    WHERE country IS NOT NULL

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', 2), ',', -1))
    FROM netflix
    WHERE country LIKE '%,%'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', 3), ',', -1))
    FROM netflix
    WHERE country LIKE '%,%,%'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', 4), ',', -1))
    FROM netflix
    WHERE country LIKE '%,%,%,%'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', 5), ',', -1))
    FROM netflix
    WHERE country LIKE '%,%,%,%,%'
) AS split_countries
WHERE country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie.

SELECT * FROM netflix 
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years.

SELECT 
    *
FROM
    netflix
WHERE
    STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons.

SELECT *, 
       CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS season_count
FROM netflix 
WHERE type = 'TV Show' 
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9. Count the number of content items in each genre.

SELECT genre, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre FROM netflix WHERE listed_in IS NOT NULL

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 2), ',', -1)) FROM netflix WHERE listed_in LIKE '%,%'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 3), ',', -1)) FROM netflix WHERE listed_in LIKE '%,%,%'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 4), ',', -1)) FROM netflix WHERE listed_in LIKE '%,%,%,%'

    UNION ALL

    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 5), ',', -1)) FROM netflix WHERE listed_in LIKE '%,%,%,%,%'
) AS split_genres
WHERE genre <> ''
GROUP BY genre
ORDER BY total_content DESC;


-- 10. Find each year and the average number of content releases per month in India on Netflix. Return the top 5 years with the highest average.

SELECT 
    year_release,
    ROUND(AVG(monthly_count), 2) AS average_monthly_content
FROM
    (SELECT 
        YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year_release,
            MONTH(STR_TO_DATE(date_added, '%M %d, %Y')) AS month_release,
            COUNT(*) AS monthly_count
    FROM
        netflix
    WHERE
        country LIKE '%India%'
            AND date_added IS NOT NULL
    GROUP BY year_release , month_release) AS monthly_data
GROUP BY year_release
ORDER BY average_monthly_content DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Find all content without a director.

SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT COUNT(*) AS count FROM netflix 
WHERE type = 'Movie' AND cast LIKE '%Salman Khan%' 
AND STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 10 YEAR);


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10



-- 15.Categorize the content based on the presence of the keywords 'kill' 
-- and 'violence' in the description field. Label content containing these keywords as 'Bad' 
-- and all other content as 'Good'. Count how many items fall into each category.


WITH new_table 
AS
(
SELECT *,
	CASE 
	WHEN 
		description LIKE '%kill%' OR 
		description LIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good Content'
	END category
FROM netflix
)
SELECT 
	category,
    COUNT(*) AS total_content 
FROM new_table
GROUP BY category