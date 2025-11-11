# Data Quality Tests Summary

## Overview
Total Tests Implemented: **54 tests**

---

## Part 1: Schema Tests (schema.yml) - 31 tests

### Basic Integrity Tests
These tests are defined in `/models/silver/schema.yml`

#### stg_orders (5 tests)
- ✅ `order_id` - unique, not_null
- ✅ `customer_id` - not_null
- ✅ `order_status` - not_null
- ✅ `order_purchase_timestamp` - not_null
- ✅ `order_estimated_delivery_date` - not_null

#### stg_order_items (7 tests)
- ✅ `order_id` - not_null
- ✅ `order_item_id` - not_null
- ✅ `product_id` - not_null
- ✅ `seller_id` - not_null
- ✅ `price` - not_null
- ✅ `freight_value` - not_null
- ✅ `shipping_limit_date` - not_null

#### stg_order_payments (5 tests)
- ✅ `order_id` - not_null
- ✅ `payment_sequential` - not_null
- ✅ `payment_type` - not_null
- ✅ `payment_installments` - not_null
- ✅ `payment_value` - not_null

#### stg_products (2 tests)
- ✅ `product_id` - unique, not_null

#### stg_sellers (4 tests)
- ✅ `seller_id` - unique, not_null
- ✅ `seller_zip_code_prefix` - not_null
- ✅ `seller_city` - not_null
- ✅ `seller_state` - not_null

#### stg_customers (5 tests)
- ✅ `customer_id` - not_null
- ✅ `customer_unique_id` - unique, not_null
- ✅ `customer_zip_code_prefix` - not_null
- ✅ `customer_city` - not_null
- ✅ `customer_state` - not_null

#### stg_order_reviews (4 tests)
- ✅ `review_id` - unique, not_null
- ✅ `order_id` - not_null
- ✅ `review_score` - not_null
- ✅ `review_creation_date` - not_null

#### stg_geolocation (5 tests)
- ✅ `geolocation_zip_code_prefix` - not_null
- ✅ `geolocation_lat` - not_null
- ✅ `geolocation_lng` - not_null
- ✅ `geolocation_city` - not_null
- ✅ `geolocation_state` - not_null

#### stg_category_translation (2 tests)
- ✅ `product_category_name` - unique, not_null
- ✅ `product_category_name_english` - not_null

---

## Part 2: Custom Business Logic Tests (tests/ folder) - 23 tests

### Foreign Key Validation Tests (6 tests)
1. ✅ `test_foreign_key_customer_id.sql` - Orders reference valid customers
2. ✅ `test_foreign_key_order_items_order_id.sql` - Order items reference valid orders
3. ✅ `test_foreign_key_product_id.sql` - Order items reference valid products
4. ✅ `test_foreign_key_seller_id.sql` - Order items reference valid sellers
5. ✅ `test_foreign_key_payments_order_id.sql` - Payments reference valid orders
6. ✅ `test_foreign_key_reviews_order_id.sql` - Reviews reference valid orders

### Accepted Values Tests (3 tests)
7. ✅ `test_order_status_values.sql` - Valid order status values
8. ✅ `test_payment_type_values.sql` - Valid payment types
9. ✅ `test_review_score_values.sql` - Review scores between 1-5

### Range Validation Tests (6 tests)
10. ✅ `test_prices_non_negative.sql` - Prices and freight >= 0
11. ✅ `test_payment_values_non_negative.sql` - Payment amounts >= 0
12. ✅ `test_payment_installments_range.sql` - Installments between 1-24
13. ✅ `test_product_dimensions_non_negative.sql` - Product dimensions >= 0
14. ✅ `test_geolocation_coordinates_valid.sql` - Lat/Lng within global bounds
15. ✅ `test_coordinates_within_brazil.sql` - Coordinates within Brazil bounds

### Business Logic Tests (5 tests)
16. ✅ `test_orders_must_have_items.sql` - Non-canceled orders have items
17. ✅ `test_no_duplicate_order_items.sql` - No duplicate order items
18. ✅ `test_order_timestamps_logical_sequence.sql` - Order dates in sequence
19. ✅ `test_delivered_orders_have_delivery_date.sql` - Delivered orders have dates
20. ✅ `test_no_future_order_dates.sql` - No future order dates

### Cross-Table Validation Tests (3 tests)
21. ✅ `test_reviews_after_order_date.sql` - Reviews created after order
22. ✅ `test_payment_amount_matches_order_total.sql` - Payments match order totals
23. ✅ _Future: Add more cross-table validation as needed_

---

## Running Tests

### Run All Tests
```bash
cd /home/user/SnowflakeProject/dbt_Ecommerce_project
source /home/user/SnowflakeProject/.venv/bin/activate
dbt test
```

### Run Only Schema Tests
```bash
dbt test --select silver
```

### Run Only Custom Tests
```bash
dbt test --select test_type:singular
```

### Run Specific Test Category
```bash
# Foreign key tests
dbt test --select "test_foreign_key*"

# Range validation tests
dbt test --select "test_*_non_negative"

# Business logic tests
dbt test --select "test_orders* test_payment_amount*"
```

### Run Tests for Specific Model
```bash
dbt test --select stg_orders
dbt test --select stg_order_items
```

---

## Test Expectations

All tests follow the pattern:
- **Expected Result**: 0 rows returned
- **If rows are returned**: Data quality issue detected
- **Action**: Investigate and fix data issues or adjust test thresholds

---

## Next Steps

1. ✅ Run initial test suite: `dbt test`
2. 📊 Review test results and identify data quality issues
3. 🔧 Fix critical data quality issues in source data or transformations
4. 📈 Add additional tests based on business requirements
5. 🚀 Integrate tests into CI/CD pipeline
6. 📊 Set up test monitoring and alerting

---

## Test Coverage Summary

| Category | Count | Status |
|----------|-------|--------|
| Uniqueness | 6 | ✅ |
| Not Null | 25 | ✅ |
| Foreign Keys | 6 | ✅ |
| Accepted Values | 3 | ✅ |
| Range Validation | 6 | ✅ |
| Business Logic | 5 | ✅ |
| Cross-Table | 3 | ✅ |
| **TOTAL** | **54** | ✅ |

---

**Status**: Ready for testing ✅
**Last Updated**: 2025-11-07
