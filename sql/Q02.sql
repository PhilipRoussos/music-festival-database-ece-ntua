--Query #2--
SELECT 
    a.artist_id AS 'Artist ID',
    a.artist_name AS 'Artist Name',
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM performance p 
            JOIN festival_event fe ON p.event_id = fe.event_id 
            WHERE fe.festival_year = 2025 
              AND p.artist_id = a.artist_id
        ) OR EXISTS (
            SELECT 1 
            FROM band_artist ba 
            JOIN performance p ON ba.band_id = p.band_id 
            JOIN festival_event fe ON p.event_id = fe.event_id 
            WHERE fe.festival_year = 2025 
              AND ba.artist_id = a.artist_id
        ) THEN 'Yes' 
        ELSE 'No' 
    END AS 'Participated in 2025'
FROM 
    artist a
    JOIN artist_subgenre asg ON a.artist_id = asg.artist_id
    JOIN subgenre s ON asg.subgenre_id = s.subgenre_id
    JOIN genre g ON s.genre_id = g.genre_id
WHERE 
    g.genre_name = 'Pop'
ORDER BY 
    a.artist_name;
------------