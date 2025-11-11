-- Test: All seller_ids in order_items must exist in sellers table
-- Foreign key validation: stg_order_items.seller_id -> stg_sellers.seller_id
-- Expectation: This query should return 0 rows

SELECT 
    oi.order_id,
    oi.seller_id,
    COUNT(*) as item_count
FROM {{ ref('stg_order_items') }} oi
LEFT JOIN {{ ref('stg_sellers') }} s 
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL
GROUP BY oi.order_id, oi.seller_id
