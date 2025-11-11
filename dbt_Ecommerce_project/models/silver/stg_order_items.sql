{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Order items data (will add transformations later)
-- Source: Bronze layer order_items table

SELECT 
    *
FROM {{ ref('order_items') }}
