-- Test: Order status should only contain valid values
-- Accepted values: delivered, shipped, processing, canceled, invoiced, approved, created, unavailable
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    order_status,
    COUNT(*) as count
FROM {{ ref('stg_orders') }}
WHERE order_status NOT IN (
    'delivered', 
    'shipped', 
    'processing', 
    'canceled', 
    'invoiced', 
    'approved', 
    'created', 
    'unavailable'
)
GROUP BY order_id, order_status
