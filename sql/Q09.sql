--Query #9--
SELECT 
    total_performances,
    GROUP_CONCAT(attendee_id ORDER BY attendee_id) AS attendee_ids,
    COUNT(attendee_id) AS attendees_count
FROM (
    SELECT 
        t.attendee_id,
        fe.festival_year,
        COUNT(DISTINCT p.performance_id) AS total_performances
    FROM 
        ticket t
    JOIN festival_event fe ON t.event_id = fe.event_id
    JOIN performance p ON fe.event_id = p.event_id
    GROUP BY 
        t.attendee_id, 
        fe.festival_year
    HAVING 
        total_performances > 3
) AS subquery
GROUP BY 
    total_performances
HAVING 
    COUNT(attendee_id) >= 1;
------------