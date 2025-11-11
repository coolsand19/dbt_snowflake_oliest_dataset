-- Investigation query for duplicate review_id
SELECT 
    review_id,
    COUNT(*) as duplicate_count,
    COUNT(DISTINCT order_id) as unique_orders,
    MIN(review_score) as min_score,
    MAX(review_score) as max_score,
    MIN(review_creation_date) as first_date,
    MAX(review_creation_date) as last_date
FROM {{ ref('stg_order_reviews') }}
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10
