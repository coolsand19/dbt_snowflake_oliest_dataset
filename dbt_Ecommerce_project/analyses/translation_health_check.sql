-- Analysis: Translation Table Health Check
-- Shows the relationship between products and translations

-- Section 1: Summary Statistics
SELECT 
    'Total Categories in Translation Table' as metric,
    COUNT(DISTINCT product_category_name) as count
FROM {{ ref('stg_category_translation') }}

UNION ALL

SELECT 
    'Total Unique Categories in Products' as metric,
    COUNT(DISTINCT product_category_name) as count
FROM {{ ref('stg_products') }}
WHERE product_category_name IS NOT NULL

UNION ALL

SELECT 
    'Categories WITH Translation' as metric,
    COUNT(DISTINCT p.product_category_name) as count
FROM {{ ref('stg_products') }} p
INNER JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
WHERE p.product_category_name IS NOT NULL

UNION ALL

SELECT 
    'Categories MISSING Translation' as metric,
    COUNT(DISTINCT p.product_category_name) as count
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND ct.product_category_name_english IS NULL

UNION ALL

SELECT 
    'Orphaned Translations (no products)' as metric,
    COUNT(DISTINCT ct.product_category_name) as count
FROM {{ ref('stg_category_translation') }} ct
LEFT JOIN {{ ref('stg_products') }} p 
    ON ct.product_category_name = p.product_category_name
WHERE p.product_id IS NULL
