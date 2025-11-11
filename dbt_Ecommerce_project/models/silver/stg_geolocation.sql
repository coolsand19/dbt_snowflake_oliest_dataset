{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Geolocation data (will add transformations later)
-- Source: Bronze layer geolocation table

SELECT 
    *
FROM {{ ref('geolocation') }}
