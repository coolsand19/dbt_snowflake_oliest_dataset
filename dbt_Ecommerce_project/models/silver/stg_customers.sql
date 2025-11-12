{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Customers data 
-- Source: Bronze layer customers table
-- Note: Keep all customer_ids (even duplicates) to maintain referential integrity with orders

SELECT 
    CUSTOMER_ID,
    CUSTOMER_UNIQUE_ID,
    CUSTOMER_ZIP_CODE_PREFIX,
    CUSTOMER_CITY,
    CUSTOMER_STATE
FROM {{ ref('customers') }}
