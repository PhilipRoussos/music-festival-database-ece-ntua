--Query #10--
WITH artist_genres AS (
    SELECT DISTINCT
        a.artist_id,
        g.genre_name
    FROM (
        SELECT p.artist_id
        FROM performance p
        WHERE p.artist_id IS NOT NULL

        UNION

        SELECT ba.artist_id
        FROM performance p
        JOIN band_artist ba ON p.band_id = ba.band_id
        WHERE p.band_id IS NOT NULL
    ) AS performing_artists
    JOIN artist a ON performing_artists.artist_id = a.artist_id
    JOIN artist_subgenre asg ON a.artist_id = asg.artist_id
    JOIN subgenre s ON asg.subgenre_id = s.subgenre_id
    JOIN genre g ON s.genre_id = g.genre_id
),
genre_pairs AS (
    SELECT
        g1.genre_name AS genre1,
        g2.genre_name AS genre2
    FROM artist_genres g1
    JOIN artist_genres g2 
        ON g1.artist_id = g2.artist_id 
        AND g1.genre_name < g2.genre_name
)
SELECT 
    genre1,
    genre2,
    COUNT(*) AS pair_count
FROM genre_pairs
GROUP BY genre1, genre2
ORDER BY pair_count DESC
LIMIT 3;
------------
