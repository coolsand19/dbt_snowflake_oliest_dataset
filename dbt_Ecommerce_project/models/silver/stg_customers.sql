{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Customers data (will add transformations later)
-- Source: Bronze layer customers table

SELECT 
    *
FROM {{ ref('customers') }}
