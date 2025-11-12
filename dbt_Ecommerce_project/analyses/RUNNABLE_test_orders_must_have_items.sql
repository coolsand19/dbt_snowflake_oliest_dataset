-- =====================================================================
-- TEST: Orders Must Have Items - PREVIEW QUERY
-- =====================================================================
-- This is the compiled SQL that you can run directly in Snowflake
-- Expected Result: 0 rows (test passes)
-- =====================================================================

USE DATABASE omni_retail;
USE SCHEMA raw_silver;
USE WAREHOUSE transform_wh;

-- Test Query: Find orders without items
SELECT 
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    oi.order_item_id
FROM omni_retail.raw_silver.stg_orders o
LEFT JOIN omni_retail.raw_silver.stg_order_items oi 
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
  AND o.order_status NOT IN ('canceled', 'unavailable');

-- =====================================================================
-- EXPLANATION:
-- =====================================================================
-- If this returns 0 rows: ✅ TEST PASSES
-- If this returns rows: ❌ TEST FAILS (orders without items found)
--
-- The test checks that every order (except canceled/unavailable) 
-- has at least one order item.
-- =====================================================================

-- Additional Info: Count total orders
SELECT 
    'Total orders' as metric,
    COUNT(*) as count
FROM omni_retail.raw_silver.stg_orders;

-- Additional Info: Count orders by status
SELECT 
    order_status,
    COUNT(*) as order_count,
    COUNT(DISTINCT customer_id) as unique_customers
FROM omni_retail.raw_silver.stg_orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Additional Info: Verify order-item relationship
SELECT 
    'Orders with items' as metric,
    COUNT(DISTINCT o.order_id) as count
FROM omni_retail.raw_silver.stg_orders o
INNER JOIN omni_retail.raw_silver.stg_order_items oi 
    ON o.order_id = oi.order_id;
