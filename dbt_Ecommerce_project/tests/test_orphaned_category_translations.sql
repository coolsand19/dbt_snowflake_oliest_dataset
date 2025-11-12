-- Test: Check for orphaned translations (translations with no products using them)
-- This identifies translations in the CSV that are not being used by any current products
-- These might be:
--   1. Old categories that no longer exist
--   2. Future categories that will be used later (OK to keep)
--   3. Typos in the translation table
-- Configured as WARNING to help maintain the translation table

{{ config(severity='warn') }}

SELECT 
    ct.product_category_name as portuguese_category,
    ct.product_category_name_english as english_translation,
    COUNT(p.product_id) as product_count,
    'No products currently use this translation' as issue_description
FROM {{ ref('stg_category_translation') }} ct
LEFT JOIN {{ ref('stg_products') }} p 
    ON ct.product_category_name = p.product_category_name
GROUP BY 
    ct.product_category_name,
    ct.product_category_name_english
HAVING COUNT(p.product_id) = 0
ORDER BY ct.product_category_name
