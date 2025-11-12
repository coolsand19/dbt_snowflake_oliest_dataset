-- COMPREHENSIVE CATEGORY TRANSLATION REPORT
-- Run this to get a complete picture of translation issues

-- Section 1: Overall Summary
SELECT 'SECTION 1: OVERALL SUMMARY' as report_section, 
       NULL as category, 
       NULL as product_count, 
       NULL as percentage
       
UNION ALL

SELECT 
    CASE 
        WHEN p.product_category_name IS NULL THEN 'Missing Portuguese category name'
        WHEN ct.product_category_name_english IS NULL THEN 'Has Portuguese, no English translation'
        ELSE 'Complete translation'
    END as report_section,
    NULL as category,
    COUNT(DISTINCT p.product_id) as product_count,
    ROUND(COUNT(DISTINCT p.product_id) * 100.0 / SUM(COUNT(DISTINCT p.product_id)) OVER (), 2) as percentage
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
GROUP BY 
    CASE 
        WHEN p.product_category_name IS NULL THEN 'Missing Portuguese category name'
        WHEN ct.product_category_name_english IS NULL THEN 'Has Portuguese, no English translation'
        ELSE 'Complete translation'
    END

UNION ALL

-- Section 2: Categories without translations
SELECT 
    'SECTION 2: MISSING TRANSLATIONS BY CATEGORY' as report_section,
    NULL as category,
    NULL as product_count,
    NULL as percentage

UNION ALL

SELECT 
    'Category: ' || COALESCE(p.product_category_name, '[NULL]') as report_section,
    p.product_category_name as category,
    COUNT(DISTINCT p.product_id) as product_count,
    NULL as percentage
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
WHERE 
    p.product_category_name IS NOT NULL
    AND ct.product_category_name_english IS NULL
GROUP BY p.product_category_name
ORDER BY product_count DESC
LIMIT 20
