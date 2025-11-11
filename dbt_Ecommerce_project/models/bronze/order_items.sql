{{
  config(
    materialized='table',
    schema='bronze'
  )
}}

-- Bronze layer: Raw order line items without transformations
-- Source: Raw data in omni_retail.raw.order_items

SELECT 
    *
FROM {{ source('raw', 'olist_orders_items_dataset') }}