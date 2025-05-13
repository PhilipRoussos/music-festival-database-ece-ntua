--Query #3--
SELECT 
    a.artist_id AS "Artist ID",
    a.artist_name AS "Artist Name",
    fe.festival_year AS "Festival Year",
    COUNT(*) AS "Warm up Count"
FROM (
    SELECT 
        p.artist_id, 
        p.event_id
    FROM 
        performance p 
    WHERE 
        p.performance_type = 'warm up' 
        AND p.artist_id IS NOT NULL
     UNION ALL

    SELECT 
        ba.artist_id, 
        p.event_id
    FROM 
        performance p 
        JOIN band_artist ba ON p.band_id = ba.band_id
    WHERE 
        p.performance_type = 'warm up' 
        AND p.band_id IS NOT NULL
    ) 
AS combined_performances
JOIN festival_event fe ON combined_performances.event_id = fe.event_id
JOIN artist a ON combined_performances.artist_id = a.artist_id
GROUP BY 
    a.artist_id, 
    fe.festival_year
HAVING 
    COUNT(*) > 2
ORDER BY 
    fe.festival_year;
------------