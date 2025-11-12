{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Orders data with data quality filters and timestamp cleaning
-- Source: Bronze layer orders table
-- Filter: Only include orders that have at least one order item (except canceled/unavailable)
-- Cleaning: Fix timestamp logical sequence issues

WITH base_orders AS (
    SELECT *
    FROM {{ ref('orders') }}
    WHERE ORDER_STATUS = 'canceled' 
       OR ORDER_STATUS = 'unavailable' 
       OR ORDER_STATUS = 'processing'
       OR ORDER_STATUS = 'shipped'
       OR (ORDER_STATUS = 'delivered' AND ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL)
),

orders_with_items AS (
    SELECT DISTINCT order_id
    FROM {{ ref('order_items') }}
),

filtered_orders AS (
    SELECT o.*
    FROM base_orders o
    WHERE 
        -- Include canceled/unavailable orders regardless of items
        o.ORDER_STATUS IN ('canceled', 'unavailable')
        -- OR only include other orders that have items
        OR o.order_id IN (SELECT order_id FROM orders_with_items)
),

cleaned_orders AS (
    SELECT
        ORDER_ID,
        CUSTOMER_ID,
        ORDER_STATUS,
        ORDER_PURCHASE_TIMESTAMP,
        
        -- Clean order_approved_at: nullify if before purchase timestamp
        CASE 
            WHEN ORDER_APPROVED_AT IS NOT NULL 
                 AND ORDER_APPROVED_AT < ORDER_PURCHASE_TIMESTAMP 
            THEN NULL
            ELSE ORDER_APPROVED_AT
        END AS ORDER_APPROVED_AT,
        
        -- Clean order_delivered_carrier_date: nullify if before approved or purchase date
        CASE 
            WHEN ORDER_DELIVERED_CARRIER_DATE IS NOT NULL 
                 AND ORDER_APPROVED_AT IS NOT NULL 
                 AND ORDER_DELIVERED_CARRIER_DATE < ORDER_APPROVED_AT 
            THEN NULL
            WHEN ORDER_DELIVERED_CARRIER_DATE IS NOT NULL 
                 AND ORDER_DELIVERED_CARRIER_DATE < ORDER_PURCHASE_TIMESTAMP 
            THEN NULL
            ELSE ORDER_DELIVERED_CARRIER_DATE
        END AS ORDER_DELIVERED_CARRIER_DATE,
        
        -- Clean order_delivered_customer_date: nullify if before carrier, approved, or purchase date
        -- For delivered orders with NULL date after cleaning, use estimated delivery date as fallback
        CASE 
            WHEN ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL 
                 AND ORDER_DELIVERED_CARRIER_DATE IS NOT NULL 
                 AND ORDER_DELIVERED_CUSTOMER_DATE < ORDER_DELIVERED_CARRIER_DATE 
            THEN CASE 
                    WHEN ORDER_STATUS = 'delivered' THEN ORDER_ESTIMATED_DELIVERY_DATE 
                    ELSE NULL 
                 END
            WHEN ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL 
                 AND ORDER_APPROVED_AT IS NOT NULL 
                 AND ORDER_DELIVERED_CUSTOMER_DATE < ORDER_APPROVED_AT 
            THEN CASE 
                    WHEN ORDER_STATUS = 'delivered' THEN ORDER_ESTIMATED_DELIVERY_DATE 
                    ELSE NULL 
                 END
            WHEN ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL 
                 AND ORDER_DELIVERED_CUSTOMER_DATE < ORDER_PURCHASE_TIMESTAMP 
            THEN CASE 
                    WHEN ORDER_STATUS = 'delivered' THEN ORDER_ESTIMATED_DELIVERY_DATE 
                    ELSE NULL 
                 END
            WHEN ORDER_DELIVERED_CUSTOMER_DATE IS NULL 
                 AND ORDER_STATUS = 'delivered'
            THEN ORDER_ESTIMATED_DELIVERY_DATE
            ELSE ORDER_DELIVERED_CUSTOMER_DATE
        END AS ORDER_DELIVERED_CUSTOMER_DATE,
        
        ORDER_ESTIMATED_DELIVERY_DATE
    FROM filtered_orders
)

-- Final selection: Remove any rows that still have timestamp sequence issues
-- (This is a safety net in case the CASE logic above doesn't catch everything)
SELECT *
FROM cleaned_orders
WHERE NOT (
    -- Check if approved date is before purchase date (shouldn't happen after cleaning but double-check)
    (ORDER_APPROVED_AT IS NOT NULL AND ORDER_APPROVED_AT < ORDER_PURCHASE_TIMESTAMP)
    OR  
    -- Check if carrier date is before approved date
    (ORDER_DELIVERED_CARRIER_DATE IS NOT NULL AND ORDER_APPROVED_AT IS NOT NULL 
     AND ORDER_DELIVERED_CARRIER_DATE < ORDER_APPROVED_AT)
    OR
    -- Check if delivered date is before carrier date
    (ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL AND ORDER_DELIVERED_CARRIER_DATE IS NOT NULL
     AND ORDER_DELIVERED_CUSTOMER_DATE < ORDER_DELIVERED_CARRIER_DATE)
    OR
    -- Check if delivered date is before purchase date
    (ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL AND ORDER_DELIVERED_CUSTOMER_DATE < ORDER_PURCHASE_TIMESTAMP)
)
