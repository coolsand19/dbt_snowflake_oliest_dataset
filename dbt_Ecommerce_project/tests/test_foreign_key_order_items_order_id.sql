-- Test: All order_ids in order_items must exist in orders table
-- Foreign key validation: stg_order_items.order_id -> stg_orders.order_id
-- Expectation: This query should return 0 rows

SELECT 
    oi.order_id,
    oi.order_item_id,
    oi.product_id
FROM {{ ref('stg_order_items') }} oi
LEFT JOIN {{ ref('stg_orders') }} o 
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL
