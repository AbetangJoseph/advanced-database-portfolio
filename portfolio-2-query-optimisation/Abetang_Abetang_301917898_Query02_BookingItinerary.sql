-- Query 2: Retrieve a complete booking itinerary

-- Purpose: Show the passenger, train service, station pair, coach, seat,
-- ticket status and charged fare for booking NRC0001.

SET search_path TO public;

SELECT
    b.booking_reference,
    bp.first_name || ' ' || bp.last_name AS passenger,
    j.service_number,
    origin.station_code AS origin,
    destination.station_code AS destination,
    c.coach_number,
    c.coach_class,
    s.seat_number,
    t.ticket_number,
    t.status AS ticket_status,
    t.charged_fare
FROM bookings AS b
JOIN booking_passengers AS bp ON bp.booking_id = b.booking_id
JOIN tickets AS t ON t.passenger_id = bp.passenger_id
JOIN journeys AS j ON j.journey_id = t.journey_id
JOIN journey_stops AS origin_stop
  ON origin_stop.journey_stop_id = t.origin_journey_stop_id
JOIN stations AS origin ON origin.station_id = origin_stop.station_id
JOIN journey_stops AS destination_stop
  ON destination_stop.journey_stop_id = t.destination_journey_stop_id
JOIN stations AS destination ON destination.station_id = destination_stop.station_id
JOIN seats AS s ON s.seat_id = t.seat_id
JOIN coaches AS c ON c.coach_id = s.coach_id
WHERE b.booking_reference = 'NRC0001'
ORDER BY passenger;

