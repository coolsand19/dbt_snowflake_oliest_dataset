-- Summary: Count of products by missing translation status

SELECT 
    CASE 
        WHEN p.product_category_name IS NULL THEN '1. Missing Portuguese category name'
        WHEN ct.product_category_name_english IS NULL THEN '2. Has Portuguese name but no English translation'
        ELSE '3. Has both'
    END as translation_status,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT p.product_category_name) as unique_category_count,
    ROUND(COUNT(DISTINCT p.product_id) * 100.0 / SUM(COUNT(DISTINCT p.product_id)) OVER (), 2) as percentage_of_products
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
GROUP BY 
    CASE 
        WHEN p.product_category_name IS NULL THEN '1. Missing Portuguese category name'
        WHEN ct.product_category_name_english IS NULL THEN '2. Has Portuguese name but no English translation'
        ELSE '3. Has both'
    END
ORDER BY translation_status
