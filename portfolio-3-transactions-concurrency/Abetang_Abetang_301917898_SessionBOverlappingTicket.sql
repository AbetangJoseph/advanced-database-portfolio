SET search_path TO public;
SET lock_timeout = '3s';

BEGIN;

SELECT 'Session B attempts the overlapping Lagos-Abeokuta interval on the same journey and seat.' AS observation;
INSERT INTO tickets (
    ticket_number, qr_token, booking_id, passenger_id, journey_id,
    origin_journey_stop_id, destination_journey_stop_id, seat_id, fare_id,
    boarding_sequence, alighting_sequence, charged_fare,
    status, held_until, issued_at
)
VALUES (
    'NRC-CON-B', 'qr-concurrent-b',
    '21000000-0000-0000-0000-000000000002',
    '31000000-0000-0000-0000-000000000002',
    1, 1, 2, 3, 1, 0, 1, 6000, 'ISSUED', NULL, now()
);

COMMIT;
RESET lock_timeout;
