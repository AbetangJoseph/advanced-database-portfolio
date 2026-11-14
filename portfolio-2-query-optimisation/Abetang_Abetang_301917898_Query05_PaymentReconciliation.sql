-- Query 5: Reconcile bookings and payments

-- Purpose: Compare each confirmed booking total with its successful payments
-- and expose any unpaid or overpaid difference.

SET search_path TO public;

SELECT
    b.booking_reference,
    b.total_amount,
    coalesce(
        sum(p.amount) FILTER (WHERE p.status = 'SUCCESS'),
        0
    ) AS successful_payments,
    b.total_amount - coalesce(
        sum(p.amount) FILTER (WHERE p.status = 'SUCCESS'),
        0
    ) AS difference
FROM bookings AS b
LEFT JOIN payments AS p ON p.booking_id = b.booking_id
WHERE b.status = 'CONFIRMED'
GROUP BY b.booking_id
ORDER BY b.booking_reference;

