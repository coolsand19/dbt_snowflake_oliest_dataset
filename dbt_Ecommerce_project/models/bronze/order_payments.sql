{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw payment events without transformations
-- Source: Snowpipe (JSON events from payment gateway)

SELECT 
    *
FROM {{ source('raw', 'olist_order_payments_dataset') }}
