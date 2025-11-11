-- Test: Every order (except canceled/unavailable) must have at least one order item
-- Expectation: This query should return 0 rows

SELECT 
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('stg_order_items') }} oi 
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
  AND o.order_status NOT IN ('canceled', 'unavailable')
