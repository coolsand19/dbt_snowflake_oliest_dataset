-- Analysis: Check impact of our timestamp cleaning on delivered orders
-- This will show us if our cleaning caused the test_delivered_orders_have_delivery_date to fail

SELECT 
    'Delivered orders with NULL customer date' as issue_type,
    COUNT(*) as count
FROM {{ ref('stg_orders') }}
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL

UNION ALL

SELECT 
    'Delivered orders with valid customer date' as issue_type,
    COUNT(*) as count
FROM {{ ref('stg_orders') }}
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL

UNION ALL

SELECT 
    'Total delivered orders' as issue_type,
    COUNT(*) as count
FROM {{ ref('stg_orders') }}
WHERE order_status = 'delivered'
