--Query #5--
SELECT 
    a.artist_id AS "Artist ID",
    a.artist_name AS "Artist Name",
    COUNT(*) AS "Participations"
FROM (
    SELECT 
        p.artist_id, 
        p.event_id
    FROM 
        performance p 
    WHERE 
        p.artist_id IS NOT NULL

    UNION ALL

    SELECT 
        ba.artist_id, 
        p.event_id
    FROM 
        performance p 
        JOIN band_artist ba ON p.band_id = ba.band_id
    WHERE 
        p.band_id IS NOT NULL
) AS all_participations
JOIN artist a ON all_participations.artist_id = a.artist_id
WHERE 
    TIMESTAMPDIFF(YEAR, a.date_of_birth, CURDATE()) < 30
GROUP BY 
    a.artist_id, 
    a.artist_name
ORDER BY 
    COUNT(*) DESC;
------------