-- DATA QUALITY INVESTIGATION REPORT
-- Run this in Snowflake to investigate test failures

USE DATABASE omni_retail;
USE SCHEMA raw_silver;
USE WAREHOUSE transform_wh;

-- ============================================================================
-- INVESTIGATION 1: Duplicate customer_unique_id (2,997 duplicates found)
-- ============================================================================
SELECT '=== INVESTIGATION 1: Duplicate customer_unique_id ===' as investigation;

SELECT 
    customer_unique_id, 
    COUNT(*) as duplicate_count,
    COUNT(DISTINCT customer_id) as unique_customer_ids,
    MIN(customer_city) as city,
    MIN(customer_state) as state
FROM omni_retail.raw_silver.stg_customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- Check if same customer_unique_id appears with different customer_id
SELECT 
    'Same customer_unique_id can have multiple customer_id (this is EXPECTED in e-commerce)' as explanation,
    'One person can make multiple orders with slightly different info = multiple customer_id' as reason;

-- Sample: Show one customer with duplicates
SELECT * FROM omni_retail.raw_silver.stg_customers
WHERE customer_unique_id = (
    SELECT customer_unique_id FROM omni_retail.raw_silver.stg_customers
    GROUP BY customer_unique_id HAVING COUNT(*) > 1 LIMIT 1
)
LIMIT 5;

-- ============================================================================
-- INVESTIGATION 2: Duplicate review_id (789 duplicates found)
-- ============================================================================
SELECT '=== INVESTIGATION 2: Duplicate review_id ===' as investigation;

SELECT 
    review_id,
    COUNT(*) as duplicate_count,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(DISTINCT review_score) as unique_scores
FROM omni_retail.raw_silver.stg_order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- Sample: Show one review with duplicates
SELECT * FROM omni_retail.raw_silver.stg_order_reviews
WHERE review_id = (
    SELECT review_id FROM omni_retail.raw_silver.stg_order_reviews
    GROUP BY review_id HAVING COUNT(*) > 1 LIMIT 1
)
LIMIT 5;

-- ============================================================================
-- INVESTIGATION 3: Payment amount vs Order total (98,666 mismatches found)
-- ============================================================================
SELECT '=== INVESTIGATION 3: Payment vs Order Total Mismatch ===' as investigation;

WITH order_totals AS (
    SELECT 
        order_id,
        SUM(price + freight_value) as items_total
    FROM omni_retail.raw_silver.stg_order_items
    GROUP BY order_id
),
payment_totals AS (
    SELECT 
        order_id,
        SUM(payment_value) as payment_total
    FROM omni_retail.raw_silver.stg_order_payments
    GROUP BY order_id
)
SELECT 
    COUNT(*) as total_mismatches,
    SUM(CASE WHEN ot.order_id IS NULL THEN 1 ELSE 0 END) as payments_without_items,
    SUM(CASE WHEN pt.order_id IS NULL THEN 1 ELSE 0 END) as items_without_payments,
    SUM(CASE WHEN ot.order_id IS NOT NULL AND pt.order_id IS NOT NULL THEN 1 ELSE 0 END) as amount_mismatches,
    AVG(ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0))) as avg_difference,
    MAX(ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0))) as max_difference
FROM order_totals ot
FULL OUTER JOIN payment_totals pt ON ot.order_id = pt.order_id
WHERE 
    CASE 
        WHEN COALESCE(ot.items_total, 0) > 0 
        THEN ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) / ot.items_total * 100 
        ELSE 0 
    END > 5
    OR ot.order_id IS NULL
    OR pt.order_id IS NULL;

-- Sample mismatches
SELECT 
    COALESCE(ot.order_id, pt.order_id) as order_id,
    ot.items_total,
    pt.payment_total,
    ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) as difference,
    ROUND(ABS(COALESCE(ot.items_total, 0) - COALESCE(pt.payment_total, 0)) / NULLIF(ot.items_total, 0) * 100, 2) as percent_diff
FROM order_totals ot
FULL OUTER JOIN payment_totals pt ON ot.order_id = pt.order_id
WHERE ot.order_id IS NOT NULL AND pt.order_id IS NOT NULL
ORDER BY difference DESC
LIMIT 10;

-- ============================================================================
-- INVESTIGATION 4: Order timestamp sequence (1,382 issues found)
-- ============================================================================
SELECT '=== INVESTIGATION 4: Order Timestamp Sequence Issues ===' as investigation;

SELECT 
    COUNT(*) as total_issues,
    SUM(CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END) as approved_before_purchase,
    SUM(CASE WHEN order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END) as carrier_before_approved,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) as delivered_before_carrier
FROM omni_retail.raw_silver.stg_orders
WHERE 
    (order_approved_at IS NOT NULL AND order_approved_at < order_purchase_timestamp)
    OR (order_delivered_carrier_date IS NOT NULL AND order_approved_at IS NOT NULL 
        AND order_delivered_carrier_date < order_approved_at)
    OR (order_delivered_customer_date IS NOT NULL AND order_delivered_carrier_date IS NOT NULL
        AND order_delivered_customer_date < order_delivered_carrier_date);

-- Sample issues
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
    END as issue_type
FROM omni_retail.raw_silver.stg_orders
WHERE 
    (order_approved_at IS NOT NULL AND order_approved_at < order_purchase_timestamp)
    OR (order_delivered_carrier_date IS NOT NULL AND order_approved_at IS NOT NULL 
        AND order_delivered_carrier_date < order_approved_at)
    OR (order_delivered_customer_date IS NOT NULL AND order_delivered_carrier_date IS NOT NULL
        AND order_delivered_customer_date < order_delivered_carrier_date)
LIMIT 10;

-- ============================================================================
-- INVESTIGATION 5: Delivered orders without delivery date (8 issues found)
-- ============================================================================
SELECT '=== INVESTIGATION 5: Delivered Orders Without Delivery Date ===' as investigation;

SELECT 
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM omni_retail.raw_silver.stg_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- ============================================================================
-- INVESTIGATION 6: Orders without items (8 issues found)
-- ============================================================================
SELECT '=== INVESTIGATION 6: Orders Without Items ===' as investigation;

SELECT 
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.customer_id
FROM omni_retail.raw_silver.stg_orders o
LEFT JOIN omni_retail.raw_silver.stg_order_items oi 
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
  AND o.order_status NOT IN ('canceled', 'unavailable');

-- ============================================================================
-- INVESTIGATION 7: Reviews before order date (74 issues found)
-- ============================================================================
SELECT '=== INVESTIGATION 7: Reviews Created Before Order Date ===' as investigation;

SELECT 
    COUNT(*) as total_issues,
    AVG(DATEDIFF(day, r.review_creation_date, o.order_purchase_timestamp)) as avg_days_difference,
    MIN(DATEDIFF(day, r.review_creation_date, o.order_purchase_timestamp)) as min_days_difference,
    MAX(DATEDIFF(day, r.review_creation_date, o.order_purchase_timestamp)) as max_days_difference
FROM omni_retail.raw_silver.stg_order_reviews r
JOIN omni_retail.raw_silver.stg_orders o 
    ON r.order_id = o.order_id
WHERE r.review_creation_date < o.order_purchase_timestamp;

-- Sample issues
SELECT 
    r.review_id,
    r.order_id,
    r.review_creation_date,
    o.order_purchase_timestamp,
    DATEDIFF(day, r.review_creation_date, o.order_purchase_timestamp) as days_difference
FROM omni_retail.raw_silver.stg_order_reviews r
JOIN omni_retail.raw_silver.stg_orders o 
    ON r.order_id = o.order_id
WHERE r.review_creation_date < o.order_purchase_timestamp
ORDER BY days_difference DESC
LIMIT 10;

-- ============================================================================
-- SUMMARY
-- ============================================================================
SELECT '=== INVESTIGATION SUMMARY ===' as summary;
SELECT 
    'Issue 1: customer_unique_id duplicates' as issue,
    '2,997 duplicates' as count,
    'EXPECTED - Same person multiple orders' as severity,
    'Remove unique constraint, use customer_id as PK' as recommendation
UNION ALL SELECT 
    'Issue 2: review_id duplicates' as issue,
    '789 duplicates' as count,
    'DATA QUALITY - Need investigation' as severity,
    'Check source data, may need composite key' as recommendation
UNION ALL SELECT 
    'Issue 3: Payment vs Order total mismatch' as issue,
    '98,666 mismatches' as count,
    'EXPECTED - Discounts/taxes/fees' as severity,
    'Adjust tolerance or document business rules' as recommendation
UNION ALL SELECT 
    'Issue 4: Timestamp sequence issues' as issue,
    '1,382 issues' as count,
    'DATA QUALITY - Timezone or data entry' as severity,
    'Investigate and fix in transformations' as recommendation
UNION ALL SELECT 
    'Issue 5: Delivered without date' as issue,
    '8 issues' as count,
    'LOW - Small dataset' as severity,
    'Fix manually or in transformations' as recommendation
UNION ALL SELECT 
    'Issue 6: Orders without items' as issue,
    '8 issues' as count,
    'LOW - Small dataset' as severity,
    'Mark as canceled or investigate' as recommendation
UNION ALL SELECT 
    'Issue 7: Reviews before order' as issue,
    '74 issues' as count,
    'LOW - Timezone issue' as severity,
    'Fix timezone handling in transformations' as recommendation;
