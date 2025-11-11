{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw geolocation lookup without transformations
-- Source: COPY INTO (CSV from geolocation provider)

SELECT 
    *
FROM {{ source('raw', 'olist_geolocation_dataset') }}
