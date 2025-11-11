{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Sellers data (will add transformations later)
-- Source: Bronze layer sellers table

SELECT 
    *
FROM {{ ref('sellers') }}
