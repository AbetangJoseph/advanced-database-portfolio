SET search_path TO public;

BEGIN;

INSERT INTO bookings (
    booking_reference, user_id, sales_channel, status,
    hold_expires_at, total_amount
)
VALUES (
    'RBKR001', '10000000-0000-0000-0000-000000000001',
    'MOBILE', 'HELD', now() + interval '15 minutes', 9000
);

SELECT booking_reference, status, 'visible before rollback' AS observation
FROM bookings
WHERE booking_reference = 'RBKR001';

ROLLBACK;

SELECT count(*) AS rows_after_rollback
FROM bookings
WHERE booking_reference = 'RBKR001';
