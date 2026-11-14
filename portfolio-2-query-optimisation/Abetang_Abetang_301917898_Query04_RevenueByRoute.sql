-- Query 4: Calculate ticket revenue

-- Purpose: Summarize issued and used ticket revenue by route and coach class.

SET search_path TO public;

SELECT
    r.route_code,
    c.coach_class,
    count(*) AS tickets,
    sum(t.charged_fare) AS ticket_revenue_ngn
FROM tickets AS t
JOIN journeys AS j ON j.journey_id = t.journey_id
JOIN routes AS r ON r.route_id = j.route_id
JOIN seats AS s ON s.seat_id = t.seat_id
JOIN coaches AS c ON c.coach_id = s.coach_id
WHERE t.status IN ('ISSUED', 'USED')
GROUP BY r.route_code, c.coach_class
ORDER BY ticket_revenue_ngn DESC;

