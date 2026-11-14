-- Performance step 1: Generate sufficient data for a meaningful plan comparison.

-- This inserts 16,000 synthetic future journeys and does not affect the
-- portfolio's original 2027 journeys.

SET search_path TO public;

INSERT INTO journeys (
    service_number,
    route_id,
    train_id,
    planned_departure,
    planned_arrival,
    status
)
SELECT
    'PERF-' || r.route_id,
    r.route_id,
    CASE WHEN r.route_id IN (1, 2) THEN 1 ELSE 2 END,
    timestamptz '2028-01-01 00:00+01' + (g.n || ' hours')::interval,
    timestamptz '2028-01-01 00:00+01'
        + (g.n || ' hours')::interval
        + interval '2 hours 30 minutes',
    'SCHEDULED'
FROM routes AS r
CROSS JOIN generate_series(1, 4000) AS g(n)
ON CONFLICT (service_number, planned_departure) DO NOTHING;

ANALYZE journeys;

SELECT count(*) AS performance_journeys
FROM journeys
WHERE service_number LIKE 'PERF-%';

