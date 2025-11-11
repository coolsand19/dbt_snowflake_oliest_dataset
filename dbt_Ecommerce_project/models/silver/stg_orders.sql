{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Orders data (will add transformations later)
-- Source: Bronze layer orders table

SELECT 
    *
FROM {{ ref('orders') }}
