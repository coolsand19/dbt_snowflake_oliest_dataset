-- Test: Review score should only be 1, 2, 3, 4, or 5
-- Expectation: This query should return 0 rows

SELECT 
    review_id,
    order_id,
    review_score
FROM {{ ref('stg_order_reviews') }}
WHERE review_score NOT IN (1, 2, 3, 4, 5)
   OR review_score IS NULL
