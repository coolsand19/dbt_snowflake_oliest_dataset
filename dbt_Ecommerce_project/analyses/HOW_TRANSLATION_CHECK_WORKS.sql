-- VISUAL EXAMPLE: How the Translation Check Works
-- This shows you exactly how the JOIN logic identifies missing translations

-- Scenario 1: Product WITH translation (GOOD ✅)
-- 
-- stg_products table:
--   product_id: ABC123
--   product_category_name: 'moveis_decoracao'
-- 
-- stg_category_translation table:
--   product_category_name: 'moveis_decoracao'
--   product_category_name_english: 'furniture_decor'
-- 
-- LEFT JOIN Result:
--   product_id: ABC123
--   portuguese_category: 'moveis_decoracao'
--   english_category: 'furniture_decor'  ← Found! ✅
--   issue_type: NULL (doesn't appear in test results)


-- Scenario 2: Product WITHOUT translation (BAD ❌)
-- 
-- stg_products table:
--   product_id: XYZ789
--   product_category_name: 'portateis_cozinha_e_preparadores_de_alimentos'
-- 
-- stg_category_translation table:
--   (no matching row exists)
-- 
-- LEFT JOIN Result:
--   product_id: XYZ789
--   portuguese_category: 'portateis_cozinha_e_preparadores_de_alimentos'
--   english_category: NULL  ← Not found! ❌
--   issue_type: 'No English translation found'


-- Scenario 3: Product with NULL category (BAD ❌)
-- 
-- stg_products table:
--   product_id: DEF456
--   product_category_name: NULL
-- 
-- LEFT JOIN Result:
--   product_id: DEF456
--   portuguese_category: NULL
--   english_category: NULL  ← Can't look up! ❌
--   issue_type: 'Missing Portuguese category name'


-- The test ONLY returns rows where english_category is NULL
-- That's how we identify the 623 products with missing translations!

-- NO API NEEDED - Just pure SQL table comparison!
