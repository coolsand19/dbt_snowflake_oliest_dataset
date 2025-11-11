-- Test: Prices and freight values must be non-negative
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    order_item_id,
    product_id,
    price,
    freight_value
FROM {{ ref('stg_order_items') }}
WHERE price < 0 
   OR freight_value < 0
