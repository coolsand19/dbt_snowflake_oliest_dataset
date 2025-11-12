-- Check the impact of our timestamp cleaning on stg_orders

-- Count comparison
WITH bronze_count AS (
    SELECT COUNT(*) as bronze_total
    FROM {{ ref('orders') }}
),
silver_count AS (
    SELECT COUNT(*) as silver_total
    FROM {{ ref('stg_orders') }}
),
nullified_timestamps AS (
    SELECT 
        COUNT(*) as total_orders,
        COUNT(CASE WHEN ORDER_APPROVED_AT IS NULL THEN 1 END) as null_approved,
        COUNT(CASE WHEN ORDER_DELIVERED_CARRIER_DATE IS NULL THEN 1 END) as null_carrier,
        COUNT(CASE WHEN ORDER_DELIVERED_CUSTOMER_DATE IS NULL THEN 1 END) as null_delivered
    FROM {{ ref('stg_orders') }}
)

SELECT 
    b.bronze_total,
    s.silver_total,
    (b.bronze_total - s.silver_total) as orders_removed,
    n.total_orders,
    n.null_approved,
    n.null_carrier,
    n.null_delivered
FROM bronze_count b
CROSS JOIN silver_count s
CROSS JOIN nullified_timestamps n
