-- Test: Payment installments should be reasonable (between 1 and 24)
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    payment_sequential,
    payment_installments
FROM {{ ref('stg_order_payments') }}
WHERE payment_installments < 1 
   OR payment_installments > 24
