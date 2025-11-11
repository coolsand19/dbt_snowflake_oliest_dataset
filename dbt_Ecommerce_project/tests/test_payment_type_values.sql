-- Test: Payment type should only contain valid values
-- Accepted values: credit_card, boleto, voucher, debit_card, not_defined
-- Expectation: This query should return 0 rows

SELECT 
    order_id,
    payment_type,
    COUNT(*) as count
FROM {{ ref('stg_order_payments') }}
WHERE payment_type NOT IN (
    'credit_card',
    'boleto',
    'voucher',
    'debit_card',
    'not_defined'
)
GROUP BY order_id, payment_type
