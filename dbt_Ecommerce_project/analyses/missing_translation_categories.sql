-- List: Portuguese categories without English translations
-- Helps identify which translations need to be added

SELECT 
    p.product_category_name as portuguese_category,
    COUNT(DISTINCT p.product_id) as affected_products
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
WHERE 
    p.product_category_name IS NOT NULL
    AND ct.product_category_name_english IS NULL
GROUP BY p.product_category_name
ORDER BY affected_products DESC, p.product_category_name
