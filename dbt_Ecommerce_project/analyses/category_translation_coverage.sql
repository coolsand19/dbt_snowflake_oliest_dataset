-- Analysis: Product Category Translation Coverage Report
-- Shows which categories are missing translations and how many products are affected

WITH products_with_translations AS (
    SELECT 
        p.product_id,
        p.product_category_name as portuguese_category,
        ct.product_category_name_english as english_category,
        CASE 
            WHEN p.product_category_name IS NULL THEN 'Missing Portuguese category'
            WHEN ct.product_category_name_english IS NULL THEN 'No English translation'
            ELSE 'Has translation'
        END as translation_status
    FROM {{ ref('stg_products') }} p
    LEFT JOIN {{ ref('stg_category_translation') }} ct 
        ON p.product_category_name = ct.product_category_name
)

SELECT 
    translation_status,
    COUNT(*) as product_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM products_with_translations
GROUP BY translation_status
ORDER BY product_count DESC

UNION ALL

SELECT 
    '--- Details by Category ---' as translation_status,
    NULL as product_count,
    NULL as percentage

UNION ALL

-- Show categories without translations
SELECT 
    'Missing: ' || COALESCE(portuguese_category, '[NULL]') as translation_status,
    COUNT(*) as product_count,
    NULL as percentage
FROM products_with_translations
WHERE translation_status IN ('Missing Portuguese category', 'No English translation')
GROUP BY portuguese_category
ORDER BY product_count DESC
