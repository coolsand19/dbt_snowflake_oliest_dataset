-- Investigation query for duplicate customer_unique_id
SELECT 
    customer_unique_id, 
    COUNT(*) as duplicate_count,
    COUNT(DISTINCT customer_id) as unique_customer_ids,
    MIN(customer_id) as first_customer_id,
    MAX(customer_id) as last_customer_id
FROM {{ ref('stg_customers') }}
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10
