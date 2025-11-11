-- Test: All product_ids in order_items must exist in products table
-- Foreign key validation: stg_order_items.product_id -> stg_products.product_id
-- Expectation: This query should return 0 rows

SELECT 
    oi.order_id,
    oi.product_id,
    COUNT(*) as item_count
FROM {{ ref('stg_order_items') }} oi
LEFT JOIN {{ ref('stg_products') }} p 
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL
GROUP BY oi.order_id, oi.product_id
