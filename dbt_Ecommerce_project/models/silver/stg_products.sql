{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Products data (will add transformations later)
-- Source: Bronze layer products table

SELECT 
    *
FROM {{ ref('products') }}
