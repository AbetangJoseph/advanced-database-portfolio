SET search_path TO public;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO bookings (
    booking_id, booking_reference, user_id, sales_channel, status,
    hold_expires_at, total_amount, currency_code
)
VALUES (
    '22000000-0000-0000-0000-000000000001',
    'TXNR001', '10000000-0000-0000-0000-000000000002', 'WEB',
    'HELD', now() + interval '20 minutes', 8000, 'NGN'
);

INSERT INTO booking_passengers (
    passenger_id, booking_id, title, first_name, last_name, date_of_birth,
    passenger_type, identity_type, identity_reference, identity_last4, identity_verified
)
VALUES (
    '32000000-0000-0000-0000-000000000001',
    '22000000-0000-0000-0000-000000000001',
    'MR', 'Tunde', 'Bello', '1988-09-10',
    'ADULT', 'NIN', 'tokenized-transaction-demo', '0100', true
);

INSERT INTO payments (
    booking_id, amount, currency_code, method,
    provider_reference, status, paid_at
)
VALUES (
    '22000000-0000-0000-0000-000000000001', 8000, 'NGN', 'CARD',
    'DEMO-RAIL-TXN-001', 'SUCCESS', now()
);

-- The trigger derives sequences from stops and verifies that seat 13 belongs
-- to the train assigned to journey 3. The exclusion constraint performs the
-- final concurrency-safe overlap check.
INSERT INTO tickets (
    ticket_number, qr_token, booking_id, passenger_id, journey_id,
    origin_journey_stop_id, destination_journey_stop_id, seat_id, fare_id,
    boarding_sequence, alighting_sequence, charged_fare,
    status, held_until, issued_at
)
VALUES (
    'NRC-TKT-TXN-001', 'qr-demo-transaction-001',
    '22000000-0000-0000-0000-000000000001',
    '32000000-0000-0000-0000-000000000001', 3,
    7, 9, 13, 9,
    0, 1, 8000,
    'ISSUED', NULL, now()
);

UPDATE bookings
SET status = 'CONFIRMED', hold_expires_at = NULL, updated_at = now()
WHERE booking_id = '22000000-0000-0000-0000-000000000001';

COMMIT;

SELECT
    b.booking_reference,
    b.status AS booking_status,
    t.ticket_number,
    j.service_number,
    origin.station_code AS origin,
    destination.station_code AS destination,
    c.coach_number,
    s.seat_number,
    p.status AS payment_status
FROM bookings AS b
JOIN payments AS p ON p.booking_id = b.booking_id
JOIN tickets AS t ON t.booking_id = b.booking_id
JOIN journeys AS j ON j.journey_id = t.journey_id
JOIN journey_stops AS origin_stop ON origin_stop.journey_stop_id = t.origin_journey_stop_id
JOIN stations AS origin ON origin.station_id = origin_stop.station_id
JOIN journey_stops AS destination_stop ON destination_stop.journey_stop_id = t.destination_journey_stop_id
JOIN stations AS destination ON destination.station_id = destination_stop.station_id
JOIN seats AS s ON s.seat_id = t.seat_id
JOIN coaches AS c ON c.coach_id = s.coach_id
WHERE b.booking_reference = 'TXNR001';
