-- Performance step 3: Add indexes justified by the demonstrated workload.

SET search_path TO public;

CREATE INDEX IF NOT EXISTS idx_journeys_route_departure
    ON journeys (route_id, planned_departure)
    INCLUDE (service_number, planned_arrival, status, train_id);

CREATE INDEX IF NOT EXISTS idx_journey_stops_station_journey
    ON journey_stops (station_id, journey_id, stop_sequence);

CREATE INDEX IF NOT EXISTS idx_tickets_active_journey
    ON tickets (journey_id, seat_id)
    WHERE status IN ('HELD', 'ISSUED', 'USED');

CREATE INDEX IF NOT EXISTS idx_bookings_user_date
    ON bookings (user_id, booked_at DESC);

CREATE INDEX IF NOT EXISTS idx_payments_booking_status
    ON payments (booking_id, status);

CREATE INDEX IF NOT EXISTS idx_fares_lookup
    ON fares (
        route_id,
        origin_station_id,
        destination_station_id,
        coach_class,
        passenger_type,
        effective_from DESC
    );

ANALYZE;

