{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Order payments data with data quality filters
-- Source: Bronze layer order_payments table
-- Filter: Only include payments for valid orders + valid installment range

SELECT op.*
FROM {{ ref('order_payments') }} op
INNER JOIN {{ ref('stg_orders') }} o
    ON op.order_id = o.order_id
WHERE op.PAYMENT_INSTALLMENTS > 0 AND op.PAYMENT_INSTALLMENTS <= 24
