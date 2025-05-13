--Query #14--
WITH genre_appearances AS (
    SELECT DISTINCT
        p.performance_id,
        f.festival_year AS year,
        g.genre_id
    FROM 
        performance p
    JOIN festival_event fe ON p.event_id = fe.event_id
    JOIN festival f ON fe.festival_year = f.festival_year
    JOIN artist a ON p.artist_id = a.artist_id
    JOIN artist_subgenre ash ON a.artist_id = ash.artist_id
    JOIN subgenre s ON ash.subgenre_id = s.subgenre_id
    JOIN genre g ON s.genre_id = g.genre_id
    WHERE 
        p.artist_id IS NOT NULL

    UNION ALL

    SELECT DISTINCT
        p.performance_id,
        f.festival_year AS year,
        g.genre_id
    FROM 
        performance p
    JOIN festival_event fe ON p.event_id = fe.event_id
    JOIN festival f ON fe.festival_year = f.festival_year
    JOIN band_artist ba ON p.band_id = ba.band_id
    JOIN artist a ON ba.artist_id = a.artist_id
    JOIN artist_subgenre ash ON a.artist_id = ash.artist_id
    JOIN subgenre s ON ash.subgenre_id = s.subgenre_id
    JOIN genre g ON s.genre_id = g.genre_id
    WHERE 
        p.band_id IS NOT NULL
),
genre_yearly_counts AS (
    SELECT 
        genre_id,
        year,
        COUNT(performance_id) AS total_appearances
    FROM 
        genre_appearances
    GROUP BY 
        genre_id, year
    HAVING 
        COUNT(performance_id) >= 3
)
SELECT 
    g.genre_name AS "Music Genre",
    gyc1.year AS "Year 1",
    gyc2.year AS "Year 2",
    gyc1.total_appearances AS "Appearances"
FROM 
    genre_yearly_counts gyc1
JOIN genre_yearly_counts gyc2 
    ON gyc1.genre_id = gyc2.genre_id
    AND gyc1.year = gyc2.year - 1
    AND gyc1.total_appearances = gyc2.total_appearances
JOIN genre g ON gyc1.genre_id = g.genre_id
ORDER BY 
    g.genre_name, gyc1.year;
------------