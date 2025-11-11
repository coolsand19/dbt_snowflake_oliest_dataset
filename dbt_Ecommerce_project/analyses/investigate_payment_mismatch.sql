-- Investigation query for payment vs order total mismatch
WITH order_totals AS (
    SELECT 
        order_id,
        SUM(price + freight_value) as items_total,
        COUNT(*) as item_count
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),
payment_totals AS (
    SELECT 
        order_id,
        SUM(payment_value) as payment_total,
        COUNT(*) as payment_count
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id
)

SELECT 
    COALESCE(ot.order_id, pt.order_id) as order_id,
    ot.items_total,
    ot.item_count,
    pt.payment_total,
    pt.payment_count,
    ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) as difference,
    CASE 
        WHEN COALESCE(ot.items_total, 0) > 0 
        THEN ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) / ot.items_total * 100 
        ELSE 0 
    END as percent_difference,
    CASE
        WHEN ot.order_id IS NULL THEN 'Payment without items'
        WHEN pt.order_id IS NULL THEN 'Items without payment'
        ELSE 'Mismatch'
    END as issue_type
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
ORDER BY percent_difference DESC
LIMIT 20
