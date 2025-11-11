-- Test: Order timestamps should follow logical sequence
-- Purchase <= Approved <= Carrier <= Delivered
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM {{ ref('stg_orders') }}
WHERE 
    -- Check if approved date is before purchase date
    (order_approved_at IS NOT NULL AND order_approved_at < order_purchase_timestamp)
    OR
    -- Check if carrier date is before approved date
    (order_delivered_carrier_date IS NOT NULL AND order_approved_at IS NOT NULL 
     AND order_delivered_carrier_date < order_approved_at)
    OR
    -- Check if delivered date is before carrier date
    (order_delivered_customer_date IS NOT NULL AND order_delivered_carrier_date IS NOT NULL
     AND order_delivered_customer_date < order_delivered_carrier_date)
    OR
    -- Check if delivered date is before purchase date
    (order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date < order_purchase_timestamp)
