-- Query 3: Calculate occupancy by journey segment

-- Purpose: Count occupied seats between every pair of adjacent stations on
-- journey LITS-001 and compare the count with the train's total active seats.

SET search_path TO public;

SELECT
    j.service_number,
    start_station.station_code || '-' || end_station.station_code AS segment,
    count(t.ticket_id) FILTER (
        WHERE t.status IN ('HELD', 'ISSUED', 'USED')
          AND t.occupied_range && int4range(
                start_stop.stop_sequence,
                end_stop.stop_sequence,
                '[)'
              )
    ) AS occupied_seats,
    (
        SELECT count(*)
        FROM seats AS all_seats
        JOIN coaches AS all_coaches
          ON all_coaches.coach_id = all_seats.coach_id
        WHERE all_coaches.train_id = j.train_id
          AND all_seats.active
          AND all_coaches.active
    ) AS total_seats
FROM journeys AS j
JOIN journey_stops AS start_stop ON start_stop.journey_id = j.journey_id
JOIN journey_stops AS end_stop
  ON end_stop.journey_id = j.journey_id
 AND end_stop.stop_sequence = start_stop.stop_sequence + 1
JOIN stations AS start_station ON start_station.station_id = start_stop.station_id
JOIN stations AS end_station ON end_station.station_id = end_stop.station_id
LEFT JOIN tickets AS t ON t.journey_id = j.journey_id
WHERE j.service_number = 'LITS-001'
GROUP BY
    j.journey_id,
    start_stop.stop_sequence,
    end_stop.stop_sequence,
    start_station.station_code,
    end_station.station_code
ORDER BY start_stop.stop_sequence;

