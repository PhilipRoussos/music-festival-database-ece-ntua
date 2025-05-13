--Query #6--
SELECT
    P.performance_id AS 'Performance ID',
    T.attendee_id AS 'Attendee ID',
    AVG((R.artist_performance + R.stage_presence + R.setup + R.sound_and_lighting + R.overall_impression) / 5.0) AS 'Average Rating'
FROM
    ticket T
JOIN festival_event FE ON T.event_id = FE.event_id
JOIN rating R ON T.IAN_number = R.IAN_number
JOIN performance P ON R.performance_id = P.performance_id 
WHERE
    T.attendee_id = 3  
    AND T.activated = TRUE              
    AND P.event_id = FE.event_id         
GROUP BY
    P.performance_id
ORDER BY
    P.performance_id ASC;
------------
