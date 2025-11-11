{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Order payments data (will add transformations later)
-- Source: Bronze layer order_payments table

SELECT 
    *
FROM {{ ref('order_payments') }}
