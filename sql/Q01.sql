--Query #1--
SELECT
    f.festival_year AS "Festival Year",
    t.purchase_method AS "Payment Method",
    SUM(t.cost) AS "Total Revenue"
FROM
    ticket t
JOIN festival_event fe ON t.event_id = fe.event_id
JOIN festival f ON fe.festival_year = f.festival_year

GROUP BY
    f.festival_year,
    t.purchase_method
ORDER BY
    f.festival_year,
    t.purchase_method;
------------