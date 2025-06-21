USE sql_kaggle;


-- -------------------------------------------
-- # 🎧 Spotify Dataset – SQL Project Questions
-- -------------------------------------------

-- ## 🟢 Easy Level

-- 1. Retrieve the top 10 most popular tracks based on Stream count.

SELECT Track, Artist, Stream 
FROM spotify
ORDER BY Stream DESC
LIMIT 10;

-- 2. What is the average Stream count for each Album_type?

SELECT Album_type, ROUND(AVG(Stream), 2) AS avg_streams FROM spotify
GROUP BY Album_type 
ORDER BY avg_streams DESC;

-- 3. Calculate the average Duration_min of tracks for each Album_type.

SELECT Album_type, ROUND(AVG(Duration_min), 2) AS avg_Duration_min 
FROM spotify
GROUP BY Album_type, Track
ORDER BY avg_Duration_min DESC;

-- 4. List the top 5 tracks with the highest Danceability scores.

SELECT Track, Artist, Danceability FROM spotify
ORDER BY Danceability DESC
LIMIT 5;

-- 5. Find the top 10 most acoustic tracks (Acousticness > 0.8).
SELECT Track, Artist, Acousticness FROM spotify
WHERE Acousticness > 0.8
ORDER BY Acousticness DESC
LIMIT 10;

-- ## 🟡 Medium Level

-- 6. Which 10 artists have the most tracks in the dataset?
SELECT Artist, Count(*) AS total_tracks FROM spotify
GROUP BY Artist
ORDER BY total_tracks DESC
LIMIT 10;

-- 7. Which Album_type has the highest average Danceability?

SELECT Album_type, ROUND(AVG(Danceability), 3) AS avg_danceability FROM spotify
GROUP BY Album_type
ORDER BY avg_danceability DESC;


-- 8. List all tracks with Stream count greater than the overall average.

SELECT Track, Artist, Stream 
FROM spotify
WHERE Stream > (SELECT AVG(Stream) FROM spotify)
ORDER BY Stream DESC;

-- 9. Find artists whose average Duration_min exceeds 5 minutes.
SELECT Artist, ROUND(AVG(Duration_min), 2) AS avg_duration
FROM spotify
GROUP BY Artist
HAVING AVG(Duration_min) > 5
ORDER BY avg_duration DESC;

-- 10. Count how many tracks are marked as official videos.

SELECT COUNT(*) AS official_video_count
FROM spotify
WHERE official_video = 'TRUE';

SELECT 
    SUM(CASE WHEN official_video = 'TRUE' THEN 1 ELSE 0 END) AS Official,
    SUM(CASE WHEN official_video != 'TRUE' THEN 1 ELSE 0 END) AS Not_Official
FROM spotify;

-- ## 🔴 Advanced Level

-- 11. What is the average Stream count by most_playedon platform?

SELECT most_playedon, ROUND(AVG(Stream), 2) AS avg_streams
FROM spotify
GROUP BY most_playedon
ORDER BY avg_streams DESC;

-- 12. Get the most streamed track in each Album_type using a CTE.

WITH ranked_tracks AS
(SELECT *, RANK() OVER(PARTITION BY Album_type ORDER BY Stream DESC) AS rnk
FROM spotify)

SELECT Album_type, Track, Artist, Stream
FROM ranked_tracks
WHERE rnk = 1;

-- 13. Find instrumental tracks (Instrumentalness > 0.8) with Stream count above the Album_type average.

SELECT Artist, Track, Album_type, Instrumentalness
FROM spotify
WHERE Instrumentalness > 0.8 AND Stream >
(SELECT AVG(Stream)
FROM spotify);

-- 14. Show each artist’s track along with a rolling average of Stream counts (window function).

SELECT Artist, Track, Stream, ROUND(AVG(Stream) 
	OVER(PARTITION BY Artist ORDER BY Stream DESC
			ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg_stream
FROM spotify;

-- 15. Get the first and most recent tracks by each artist based on Views.

WITH ranked_tracks AS (
  SELECT 
    Artist, 
    Track, 
    Views,
    ROW_NUMBER() OVER(PARTITION BY Artist ORDER BY Views ASC) AS least_viewed_rank,
    ROW_NUMBER() OVER(PARTITION BY Artist ORDER BY Views DESC) AS most_viewed_rank
  FROM spotify
)
SELECT 
  Artist,
  MAX(CASE WHEN least_viewed_rank = 1 THEN Track END) AS least_viewed_track,
  MAX(CASE WHEN least_viewed_rank = 1 THEN Views END) AS least_views,
  MAX(CASE WHEN most_viewed_rank = 1 THEN Track END) AS most_viewed_track,
  MAX(CASE WHEN most_viewed_rank = 1 THEN Views END) AS most_views
FROM ranked_tracks
WHERE least_viewed_rank = 1 OR most_viewed_rank = 1
GROUP BY Artist;

-- 16. Which Album_type has the highest average Valence?

SELECT Album_type, ROUND(AVG(Valence), 2) AS avg_valence
FROM spotify
GROUP BY Album_type
ORDER BY avg_valence DESC
LIMIT 1;


-- 17. Find top 10 tracks where both Energy and Liveness are above their overall average.

SELECT Track, Artist, Energy, Liveness
FROM spotify
WHERE Energy > (SELECT AVG(Energy) FROM spotify)
AND Liveness > (SELECT AVG(Liveness) FROM spotify)
ORDER BY Energy DESC, Liveness DESC 
LIMIT 10;

-- 18. Rank tracks by Stream count within each Album_type.

SELECT  
	Album_type, 
    Track, 
    Artist, 
    Stream, 
    RANK() OVER(PARTITION BY Album_type ORDER BY Stream DESC) AS rank_within_album
FROM spotify;

-- 19. How many tracks were released by each Channel?

SELECT Channel, COUNT(*) AS total_tracks
FROM spotify
GROUP BY Channel
ORDER BY total_tracks DESC;


-- 20. Which most_playedon platform had the highest average Stream count?

SELECT most_playedon, ROUND(AVG(Stream), 2) AS avg_stream_count FROM spotify
GROUP BY most_playedon
ORDER BY avg_stream_count DESC 
LIMIT 1;

