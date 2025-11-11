-- Test: All order_ids in reviews must exist in orders table
-- Foreign key validation: stg_order_reviews.order_id -> stg_orders.order_id
-- Expectation: This query should return 0 rows

SELECT 
    r.review_id,
    r.order_id,
    r.review_score
FROM {{ ref('stg_order_reviews') }} r
LEFT JOIN {{ ref('stg_orders') }} o 
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL
