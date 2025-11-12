{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Order items data with data quality filters
-- Source: Bronze layer order_items table
-- Filter: Only include items for valid orders that exist in stg_orders

SELECT oi.*
FROM {{ ref('order_items') }} oi
INNER JOIN {{ ref('stg_orders') }} o
    ON oi.order_id = o.order_id
