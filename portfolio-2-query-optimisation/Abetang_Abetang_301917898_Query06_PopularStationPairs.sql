-- Query 6: Rank popular station pairs

-- Purpose: Count issued/used tickets for each origin-destination pair and
-- rank the pairs with a window function.

SET search_path TO public;

WITH pair_sales AS (
    SELECT
        origin.station_code || '-' || destination.station_code AS station_pair,
        count(*) AS issued_tickets
    FROM tickets AS t
    JOIN journey_stops AS origin_stop
      ON origin_stop.journey_stop_id = t.origin_journey_stop_id
    JOIN stations AS origin ON origin.station_id = origin_stop.station_id
    JOIN journey_stops AS destination_stop
      ON destination_stop.journey_stop_id = t.destination_journey_stop_id
    JOIN stations AS destination
      ON destination.station_id = destination_stop.station_id
    WHERE t.status IN ('ISSUED', 'USED')
    GROUP BY origin.station_code, destination.station_code
)
SELECT
    station_pair,
    issued_tickets,
    dense_rank() OVER (ORDER BY issued_tickets DESC) AS popularity_rank
FROM pair_sales
ORDER BY popularity_rank, station_pair;

