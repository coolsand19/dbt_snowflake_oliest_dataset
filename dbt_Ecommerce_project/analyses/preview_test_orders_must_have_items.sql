-- =====================================================================
-- PREVIEW: Test Orders Must Have Items
-- =====================================================================
-- This file can be run directly in VS Code dbt Power User preview
-- Expected Result: 0 rows (test passes)
-- =====================================================================

SELECT 
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    oi.order_item_id
FROM omni_retail.raw_silver.stg_orders o
LEFT JOIN omni_retail.raw_silver.stg_order_items oi 
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
  AND o.order_status NOT IN ('canceled', 'unavailable')
