--Query #8--
SELECT
    s.staff_id AS "Staff ID",
    s.staff_name AS "Staff Name",
    s.specialty AS "specialty"
FROM
    staff s
WHERE
    s.specialty = 'support staff'
    AND NOT EXISTS (
        SELECT 1
        FROM staff_event se
        JOIN festival_event fe ON se.event_id = fe.event_id
        WHERE se.staff_id = s.staff_id
          AND fe.event_date = '2025-06-28'
    )
ORDER BY
    s.staff_name;
------------