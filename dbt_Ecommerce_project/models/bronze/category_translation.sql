{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Category translation lookup without transformations
-- Source: dbt seed

SELECT 
    *
FROM {{ source('raw', 'product_category_name_translation') }}
