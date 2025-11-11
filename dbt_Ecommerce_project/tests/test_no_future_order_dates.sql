-- Test: No order dates should be in the future
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM {{ ref('stg_orders') }}
WHERE 
    order_purchase_timestamp > CURRENT_TIMESTAMP()
    OR order_approved_at > CURRENT_TIMESTAMP()
    OR order_delivered_carrier_date > CURRENT_TIMESTAMP()
    OR order_delivered_customer_date > CURRENT_TIMESTAMP()
