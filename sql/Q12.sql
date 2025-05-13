--Query #12--
SELECT 
    fe.event_date AS "Date",
    COUNT(DISTINCT CASE WHEN st.specialty = 'technicians' THEN st.staff_id END) AS "Technical Staff",
    COUNT(DISTINCT CASE WHEN st.specialty = 'security personnel' THEN st.staff_id END) AS "Security Staff",
    COUNT(DISTINCT CASE WHEN st.specialty = 'support staff' THEN st.staff_id END) AS "Support Staff"
FROM 
    festival_event fe
    LEFT JOIN staff_event se ON fe.event_id = se.event_id
    LEFT JOIN staff st ON se.staff_id = st.staff_id
GROUP BY 
    fe.event_date
ORDER BY 
    fe.event_date;
------------