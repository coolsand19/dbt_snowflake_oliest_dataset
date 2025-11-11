-- Test: All order_ids in payments must exist in orders table
-- Foreign key validation: stg_order_payments.order_id -> stg_orders.order_id
-- Expectation: This query should return 0 rows

SELECT 
    p.order_id,
    p.payment_sequential,
    p.payment_value
FROM {{ ref('stg_order_payments') }} p
LEFT JOIN {{ ref('stg_orders') }} o 
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL
