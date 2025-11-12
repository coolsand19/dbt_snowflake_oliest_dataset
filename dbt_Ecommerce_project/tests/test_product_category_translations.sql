-- Test: Check if products have English translations
-- IMPORTANT: This is a DATA QUALITY CHECK, not a blocker
-- It's OK if future categories don't have translations yet - they can be added later
-- This test helps identify which categories need translation work
-- Configured as WARNING (not ERROR) to allow data pipeline to continue

{{ config(severity='warn') }}

SELECT 
    p.product_id,
    p.product_category_name as portuguese_category,
    ct.product_category_name_english as english_category,
    CASE 
        WHEN p.product_category_name IS NULL THEN 'Missing Portuguese category name'
        WHEN ct.product_category_name_english IS NULL THEN 'No English translation found'
        ELSE 'Unknown issue'
    END as issue_type
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_category_translation') }} ct 
    ON p.product_category_name = ct.product_category_name
WHERE 
    -- Products with no category name
    p.product_category_name IS NULL
    OR 
    -- Products with category name but no translation
    (p.product_category_name IS NOT NULL AND ct.product_category_name_english IS NULL)
ORDER BY issue_type, p.product_category_name
