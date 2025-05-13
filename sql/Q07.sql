--Query #7--
SELECT 
    f.festival_year AS 'Festival Year',
    ROUND(AVG(s.experience), 2) AS 'AVG experience'
FROM 
    festival f
    JOIN festival_event fe ON f.festival_year = fe.festival_year
    JOIN staff_event se ON fe.event_id = se.event_id
    JOIN staff s ON se.staff_id = s.staff_id
WHERE 
    s.specialty = 'technicians'
GROUP BY 
    f.festival_year
ORDER BY 
    AVG(s.experience) ASC
LIMIT 1;
------------