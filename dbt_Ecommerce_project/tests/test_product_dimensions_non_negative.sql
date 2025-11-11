-- Test: Product dimensions and attributes must be non-negative
-- Expectation: This query should return 0 rows

SELECT 
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM {{ ref('stg_products') }}
WHERE product_weight_g < 0
   OR product_length_cm < 0
   OR product_height_cm < 0
   OR product_width_cm < 0
   OR product_name_lenght < 0
   OR product_description_lenght < 0
   OR product_photos_qty < 0
