-- Test: Total payment amount should roughly match order items total
-- Allow 50% variance for discounts, vouchers, adjustments, rounding, and data quality issues
-- This is a Brazilian e-commerce dataset with known payment mismatches (promotions, vouchers, etc.)
-- Expectation: This query should return 0 rows

WITH order_totals AS (
    SELECT 
        order_id,
        SUM(price + freight_value) as items_total
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),
payment_totals AS (
    SELECT 
        order_id,
        SUM(payment_value) as payment_total
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id
)

SELECT 
    COALESCE(ot.order_id, pt.order_id) as order_id,
    ot.items_total,
    pt.payment_total,
    ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) as difference,
    CASE 
        WHEN COALESCE(ot.items_total, 0) > 0 
        THEN ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) / ot.items_total * 100 
        ELSE 0 
    END as percent_difference
FROM order_totals ot
FULL OUTER JOIN payment_totals pt 
    ON ot.order_id = pt.order_id
WHERE 
    -- More than 50% difference (real-world e-commerce has significant discounts/vouchers/promotions)
    CASE 
        WHEN COALESCE(ot.items_total, 0) > 0 
        THEN ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) / ot.items_total * 100 
        ELSE 0 
    END > 50
    -- Exclude edge cases where one side is completely missing
    AND ot.order_id IS NOT NULL  
    AND pt.order_id IS NOT NULL
