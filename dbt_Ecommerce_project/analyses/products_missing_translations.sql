-- Detailed Report: Products with Missing Category Translations
-- Shows exactly which products and categories are affected

SELECT 
    p.product_id,
    p.product_category_name as portuguese_category,
    ct.product_category_name_english as english_translation,
    CASE 
        WHEN p.product_category_name IS NULL THEN 'Missing Portuguese category'
        WHEN ct.product_category_name_english IS NULL THEN 'No English translation found'
        ELSE 'Has translation'
    END as status
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
WHERE 
    p.product_category_name IS NULL
    OR ct.product_category_name_english IS NULL
ORDER BY 
    status DESC,
    p.product_category_name NULLS FIRST,
    p.product_id
LIMIT 100
