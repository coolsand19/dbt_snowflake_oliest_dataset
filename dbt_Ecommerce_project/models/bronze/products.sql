{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw product master data without transformations
-- Source: COPY INTO (CSV from ERP system)

SELECT 
    *
FROM {{ source('raw', 'olist_products_dataset') }}
