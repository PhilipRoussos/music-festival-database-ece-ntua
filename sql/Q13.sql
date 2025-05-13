--Query #13--
WITH artist_continents AS (

    SELECT 
        p.artist_id,
        fl.continent
    FROM 
        performance p
        JOIN festival_event fe ON p.event_id = fe.event_id
        JOIN festival f ON fe.festival_year = f.festival_year
        JOIN festival_location fl ON f.location_id = fl.location_id
    WHERE 
        p.artist_id IS NOT NULL

    UNION

    SELECT 
        ba.artist_id,
        fl.continent
    FROM 
        performance p
        JOIN band_artist ba ON p.band_id = ba.band_id
        JOIN festival_event fe ON p.event_id = fe.event_id
        JOIN festival f ON fe.festival_year = f.festival_year
        JOIN festival_location fl ON f.location_id = fl.location_id
    WHERE 
        p.band_id IS NOT NULL
)

SELECT 
    a.artist_id AS "Artist ID",
    a.artist_name AS "Artist Name",
    COUNT(DISTINCT ac.continent) AS "Continent Number"
FROM 
    artist_continents ac
    JOIN artist a ON ac.artist_id = a.artist_id
GROUP BY 
    a.artist_id, 
    a.artist_name
HAVING 
    COUNT(DISTINCT ac.continent) >= 3
ORDER BY 
    COUNT(DISTINCT ac.continent) DESC;
------------