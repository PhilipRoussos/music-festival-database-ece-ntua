--Query #4--
WITH ArtistPerformanceIDs AS (
    SELECT p.performance_id
    FROM performance p
    WHERE p.artist_id = 1 #@target_artist_id

    UNION

    SELECT p.performance_id
    FROM performance p
    JOIN band_artist ba ON p.band_id = ba.band_id
    WHERE ba.artist_id = 1 #@target_artist_id
)
SELECT
    A.artist_name AS 'Artist Name',
    AVG(R.artist_performance) AS 'Artist Performance AVG',
    AVG(R.overall_impression) AS 'Overall Impression AVG'
FROM
    rating R
JOIN ArtistPerformanceIDs API ON R.performance_id = API.performance_id
JOIN artist A ON A.artist_id = 1 #@target_artist_id
GROUP BY
    A.artist_id, A.artist_name;
------------