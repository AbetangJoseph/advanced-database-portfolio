-- Performance step 2: Capture the execution plan before adding the portfolio

-- index. Ran this exact query at least three times and recorded the median.

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

