-- Analysis: Check the distribution of payment mismatches

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
),
mismatches AS (
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
        CASE 
            WHEN COALESCE(ot.items_total, 0) > 0 
            THEN ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) / ot.items_total * 100 
            ELSE 0 
        END > 5
        OR ot.order_id IS NULL
        OR pt.order_id IS NULL
)

SELECT 
    CASE 
        WHEN percent_difference <= 10 THEN '5-10%'
        WHEN percent_difference <= 20 THEN '10-20%'
        WHEN percent_difference <= 50 THEN '20-50%'
        WHEN percent_difference > 50 THEN '>50%'
        ELSE 'Missing data'
    END as mismatch_category,
    COUNT(*) as count
FROM mismatches
GROUP BY 1
ORDER BY 1
