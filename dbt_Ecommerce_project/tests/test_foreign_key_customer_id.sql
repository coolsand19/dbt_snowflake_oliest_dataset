-- Test: All customer_ids in orders must exist in customers table
-- Foreign key validation: stg_orders.customer_id -> stg_customers.customer_id
-- Expectation: This query should return 0 rows

SELECT 
    o.order_id,
    o.customer_id
FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('stg_customers') }} c 
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
