-- Test: Orders with 'delivered' status must have a delivery date
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    order_status,
    order_delivered_customer_date,
    order_purchase_timestamp
FROM {{ ref('stg_orders') }}
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL
