{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw orders data without transformations
-- Source: Snowpipe (JSON events from e-commerce platform)

SELECT 
    *
FROM {{ source('raw', 'olist_orders_dataset') }}
