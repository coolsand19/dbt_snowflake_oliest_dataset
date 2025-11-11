-- Investigation query for order timestamp sequence issues
SELECT 
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    CASE 
        WHEN order_approved_at < order_purchase_timestamp THEN 'Approved before purchase'
        WHEN order_delivered_carrier_date < order_approved_at THEN 'Carrier before approved'
        WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 'Delivered before carrier'
        WHEN order_delivered_customer_date < order_purchase_timestamp THEN 'Delivered before purchase'
        ELSE 'Other sequence issue'
    END as issue_type,
    DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) as days_to_deliver
FROM {{ ref('stg_orders') }}
WHERE 
    (order_approved_at IS NOT NULL AND order_approved_at < order_purchase_timestamp)
    OR (order_delivered_carrier_date IS NOT NULL AND order_approved_at IS NOT NULL 
        AND order_delivered_carrier_date < order_approved_at)
    OR (order_delivered_customer_date IS NOT NULL AND order_delivered_carrier_date IS NOT NULL
        AND order_delivered_customer_date < order_delivered_carrier_date)
    OR (order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date < order_purchase_timestamp)
ORDER BY order_purchase_timestamp DESC
LIMIT 20
