--Query #11--
WITH ArtistParticipation AS (
    SELECT 
        a.artist_id,
        a.artist_name,
        COUNT(DISTINCT fe.festival_year) AS participation_count
    FROM 
        artist a
    LEFT JOIN performance p_artist 
        ON a.artist_id = p_artist.artist_id
    LEFT JOIN band_artist ba 
        ON a.artist_id = ba.artist_id
    LEFT JOIN performance p_band 
        ON ba.band_id = p_band.band_id
    LEFT JOIN festival_event fe 
        ON COALESCE(p_artist.event_id, p_band.event_id) = fe.event_id
    GROUP BY 
        a.artist_id, 
        a.artist_name
)
SELECT 
    artist_id,
    artist_name,
    participation_count
FROM 
    ArtistParticipation
WHERE 
    participation_count <= (
        SELECT MAX(participation_count) - 5 
        FROM ArtistParticipation
    );
------------