{{
  config(
    materialized='table',
    schema='silver'
  )
}}

-- Silver layer: Order reviews data with data quality filters and deduplication
-- Source: Bronze layer order_reviews table
-- Filter: Only include reviews for valid orders + created after order date
-- Deduplication: Keep the most recent review for duplicate review_ids

WITH base_reviews AS (
    SELECT *
    FROM {{ ref('order_reviews') }}
),

valid_orders AS (
    SELECT 
        order_id,
        order_purchase_timestamp
    FROM {{ ref('stg_orders') }}
),

filtered_reviews AS (
    SELECT r.*
    FROM base_reviews r
    INNER JOIN valid_orders o 
        ON r.order_id = o.order_id
    WHERE r.review_creation_date >= o.order_purchase_timestamp
       OR r.review_creation_date IS NULL  -- Keep reviews without creation date
),

deduplicated_reviews AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY REVIEW_ID 
            ORDER BY REVIEW_CREATION_DATE DESC NULLS LAST, ORDER_ID
        ) as rn
    FROM filtered_reviews
)

SELECT 
    REVIEW_ID,
    ORDER_ID,
    REVIEW_SCORE,
    REVIEW_COMMENT_TITLE,
    REVIEW_COMMENT_MESSAGE,
    REVIEW_CREATION_DATE,
    REVIEW_ANSWER_TIMESTAMP
FROM deduplicated_reviews
WHERE rn = 1
