{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Order reviews data (will add transformations later)
-- Source: Bronze layer order_reviews table

SELECT 
    *
FROM {{ ref('order_reviews') }}
