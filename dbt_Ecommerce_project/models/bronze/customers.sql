{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw customer master data without transformations
-- Source: COPY INTO + CDC Stream (CRM system)

SELECT 
    *
FROM {{ source('raw', 'olist_customers_dataset') }}
