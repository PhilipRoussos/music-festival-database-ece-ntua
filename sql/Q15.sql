--Query #15--
SET @target_artist_id = 1;

WITH TargetArtistBands AS (
    SELECT DISTINCT ba.band_id
    FROM band_artist ba
    WHERE ba.artist_id = @target_artist_id
)
SELECT
    att.attendee_name AS visitor_name,
    (SELECT ar_context.artist_name FROM artist ar_context WHERE ar_context.artist_id = @target_artist_id) AS context_artist_name,
    SUM(r.artist_performance + r.stage_presence + r.setup + r.sound_and_lighting + r.overall_impression) AS total_combined_rating_score
FROM
    attendee att
JOIN ticket t ON att.attendee_id = t.attendee_id
JOIN rating r ON t.IAN_number = r.IAN_number
JOIN performance perf ON r.performance_id = perf.performance_id
JOIN artist ar_check ON ar_check.artist_id = @target_artist_id
JOIN band_artist ba_check ON ba_check.artist_id = ar_check.artist_id
WHERE
    (perf.artist_id = @target_artist_id)
    OR
    (perf.band_id IN (SELECT band_id FROM TargetArtistBands))
GROUP BY
    att.attendee_id, att.attendee_name
ORDER BY
    total_combined_rating_score DESC
LIMIT 5;
------------