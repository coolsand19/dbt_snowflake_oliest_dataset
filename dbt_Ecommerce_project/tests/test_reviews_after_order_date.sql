-- Test: Reviews should be created after the order was placed
-- Expectation: This query should return 0 rows

SELECT 
    r.review_id,
    r.order_id,
    r.review_creation_date,
    o.order_purchase_timestamp
FROM {{ ref('stg_order_reviews') }} r
JOIN {{ ref('stg_orders') }} o 
    ON r.order_id = o.order_id
WHERE r.review_creation_date < o.order_purchase_timestamp
