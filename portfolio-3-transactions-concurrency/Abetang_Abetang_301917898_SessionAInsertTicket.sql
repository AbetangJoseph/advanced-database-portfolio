SET search_path TO public;

BEGIN;

INSERT INTO tickets (
    ticket_number, qr_token, booking_id, passenger_id, journey_id,
    origin_journey_stop_id, destination_journey_stop_id, seat_id, fare_id,
    boarding_sequence, alighting_sequence, charged_fare,
    status, held_until, issued_at
)
VALUES (
    'NRC-CON-A', 'qr-concurrent-a',
    '21000000-0000-0000-0000-000000000001',
    '31000000-0000-0000-0000-000000000001',
    1, 1, 3, 3, 3, 0, 1, 9000, 'ISSUED', NULL, now()
);

SELECT 'Session A inserted seat 1C for the full Lagos-Ibadan interval and will hold the transaction for 5 seconds.' AS observation;
SELECT pg_sleep(5);
COMMIT;
SELECT 'Session A committed.' AS observation;
