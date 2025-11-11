{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw seller/store master data without transformations
-- Source: COPY INTO (CSV from ERP system)

SELECT 
    *
FROM {{ source('raw', 'olist_sellers_dataset') }}
