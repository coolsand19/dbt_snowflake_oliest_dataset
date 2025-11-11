{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Category translation data (will add transformations later)
-- Source: Bronze layer category_translation table

SELECT 
    *
FROM {{ ref('category_translation') }}
