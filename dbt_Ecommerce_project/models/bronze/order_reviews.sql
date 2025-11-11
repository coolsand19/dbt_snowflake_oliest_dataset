{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw order reviews without transformations
-- Source: COPY INTO (CSV batch from review system)

SELECT 
    *
FROM {{ source('raw', 'olist_order_reviews_dataset') }}
