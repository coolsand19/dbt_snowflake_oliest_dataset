-- Test: Payment values must be non-negative
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    payment_sequential,
    payment_value
FROM {{ ref('stg_order_payments') }}
WHERE payment_value < 0
