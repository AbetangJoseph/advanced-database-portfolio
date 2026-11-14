SET search_path TO public;

INSERT INTO bookings (booking_id, booking_reference, user_id, sales_channel, status, hold_expires_at, total_amount)
VALUES
    ('21000000-0000-0000-0000-000000000001', 'CONA001', '10000000-0000-0000-0000-000000000001', 'WEB', 'HELD', now() + interval '30 minutes', 9000),
    ('21000000-0000-0000-0000-000000000002', 'CONB001', '10000000-0000-0000-0000-000000000002', 'WEB', 'HELD', now() + interval '30 minutes', 6000)
ON CONFLICT DO NOTHING;

INSERT INTO booking_passengers (
    passenger_id, booking_id, title, first_name, last_name, date_of_birth,
    passenger_type, identity_type, identity_reference, identity_last4, identity_verified
)
VALUES
    ('31000000-0000-0000-0000-000000000001', '21000000-0000-0000-0000-000000000001', 'MS', 'Concurrent', 'PassengerA', '1990-01-01', 'ADULT', 'NIN', 'token-concurrent-a', '1001', true),
    ('31000000-0000-0000-0000-000000000002', '21000000-0000-0000-0000-000000000002', 'MR', 'Concurrent', 'PassengerB', '1991-01-01', 'ADULT', 'NIN', 'token-concurrent-b', '1002', true)
ON CONFLICT DO NOTHING;

SELECT booking_reference, status
FROM bookings
WHERE booking_reference IN ('CONA001', 'CONB001')
ORDER BY booking_reference;
