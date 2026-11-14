-- Query 1: Search available journeys

-- Purpose: Find scheduled Lagos-to-Ibadan journeys on a selected date and
-- count seats that are available for the complete requested station interval.

SET search_path TO public;

SELECT
    j.journey_id,
    j.service_number,
    origin.station_code AS origin,
    destination.station_code AS destination,
    origin_stop.planned_departure,
    destination_stop.planned_arrival,
    c.coach_class,
    count(*) FILTER (
        WHERE NOT EXISTS (
            SELECT 1
            FROM tickets AS t
            WHERE t.journey_id = j.journey_id
              AND t.seat_id = s.seat_id
              AND t.status IN ('HELD', 'ISSUED', 'USED')
              AND t.occupied_range && int4range(
                    origin_stop.stop_sequence,
                    destination_stop.stop_sequence,
                    '[)'
                  )
        )
    ) AS available_seats
FROM journeys AS j
JOIN journey_stops AS origin_stop ON origin_stop.journey_id = j.journey_id
JOIN stations AS origin ON origin.station_id = origin_stop.station_id
JOIN journey_stops AS destination_stop ON destination_stop.journey_id = j.journey_id
JOIN stations AS destination ON destination.station_id = destination_stop.station_id
JOIN coaches AS c ON c.train_id = j.train_id AND c.active
JOIN seats AS s ON s.coach_id = c.coach_id AND s.active
WHERE origin.station_code = 'MJS'
  AND destination.station_code = 'IBA'
  AND origin_stop.stop_sequence < destination_stop.stop_sequence
  AND j.planned_departure >= timestamptz '2027-02-15 00:00+01'
  AND j.planned_departure < timestamptz '2027-02-16 00:00+01'
  AND j.status IN ('SCHEDULED', 'DELAYED')
GROUP BY
    j.journey_id,
    origin.station_code,
    destination.station_code,
    origin_stop.planned_departure,
    destination_stop.planned_arrival,
    c.coach_class
ORDER BY origin_stop.planned_departure, c.coach_class;

