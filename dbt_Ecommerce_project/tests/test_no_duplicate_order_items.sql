-- Test: No duplicate order items (same order_id + order_item_id combination)
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    order_item_id,
    COUNT(*) as duplicate_count
FROM {{ ref('stg_order_items') }}
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
