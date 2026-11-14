-- Performance step 4: Run the identical measured query after indexing.

-- Capture the plan, and ran it at three times and compared median execution

SET search_path TO public;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT
    journey_id,
    service_number,
    planned_departure,
    planned_arrival
FROM journeys
WHERE route_id = 1
  AND planned_departure >= timestamptz '2028-01-01 00:00+01'
  AND planned_departure <  timestamptz '2028-06-01 00:00+01'
  AND status = 'SCHEDULED'
ORDER BY planned_departure;

