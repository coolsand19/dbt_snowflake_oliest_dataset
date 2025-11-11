# Silver Layer - Cleaned and Conformed Data

## Purpose
The silver layer provides **cleaned, typed, and conformed data** built on top of the bronze layer. This layer:
- References bronze models using dbt's `{{ ref() }}` function
- Currently uses `SELECT *` (transformations to be added)
- Materialized as **views** for flexibility during development
- Will include data quality tests, type casting, and business logic

## Medallion Architecture
```
RAW Schema (Snowflake) 
    ↓
BRONZE Layer (raw passthrough tables)
    ↓
SILVER Layer (cleaned/conformed - this folder)
    ↓
GOLD Layer (business marts)
```

## Models in This Layer

### Transactional Data
| Model | Source | Description |
|-------|--------|-------------|
| `orders.sql` | `{{ ref('orders') }}` | Cleaned orders data |
| `order_items.sql` | `{{ ref('order_items') }}` | Cleaned order line items |
| `order_payments.sql` | `{{ ref('order_payments') }}` | Cleaned payment events |
| `order_reviews.sql` | `{{ ref('order_reviews') }}` | Cleaned order reviews |

### Master Data
| Model | Source | Description |
|-------|--------|-------------|
| `products.sql` | `{{ ref('products') }}` | Cleaned product master |
| `sellers.sql` | `{{ ref('sellers') }}` | Cleaned seller/store master |
| `customers.sql` | `{{ ref('customers') }}` | Cleaned customer master |

### Reference Data
| Model | Source | Description |
|-------|--------|-------------|
| `geolocation.sql` | `{{ ref('geolocation') }}` | Cleaned geolocation lookup |
| `category_translation.sql` | `{{ ref('category_translation') }}` | Category translation reference |

## Configuration

All silver models are configured in `dbt_project.yml`:

```yaml
models:
  dbt_Ecommerce_project:
    silver:
      +materialized: view
      +schema: silver
```

## Current State

✅ **Phase 1: Structure Created** (Current)
- All 9 silver models created
- Simple `SELECT *` from bronze
- Ready for quality testing

⏳ **Phase 2: Add Quality Tests** (Next)
- Add data quality tests in `schema.yml`
- Test for nulls, duplicates, referential integrity
- Validate data types and ranges

⏳ **Phase 3: Add Transformations** (Future)
- Type casting (VARCHAR → TIMESTAMP, etc.)
- Data cleaning (trim, uppercase, null handling)
- Business logic (calculated fields)
- Deduplication
- Late-arrival handling

## Usage

Silver models are referenced in gold layer models:

```sql
-- In gold/fact_sales.sql
SELECT 
  o.order_id,
  o.customer_id,
  oi.product_id,
  oi.price * oi.quantity AS total_amount
FROM {{ ref('orders') }} o
JOIN {{ ref('order_items') }} oi ON o.order_id = oi.order_id
```

## Building Silver Models

```bash
# Build all silver models
dbt run --select silver

# Build specific model
dbt run --select orders

# Run tests
dbt test --select silver

# Build bronze + silver together
dbt run --select bronze+ silver
```

## Planned Transformations

### Orders
- Cast `order_purchase_timestamp` to proper TIMESTAMP type
- Calculate order age and fulfillment time
- Add order status categories
- Handle late-arriving orders

### Order Items
- Calculate line item totals (price * quantity)
- Add margin calculations
- Validate price > 0

### Products
- Clean product names and descriptions
- Handle missing category names
- Join with category translation
- Calculate product dimensions volume

### Customers
- Deduplicate by customer_unique_id
- Standardize city/state names
- Geocode using geolocation table

### Payments
- Aggregate multiple payments per order
- Calculate total payment amount
- Identify payment method mix

## Key Principles

✅ **DO:**
- Add data quality tests
- Clean and standardize data
- Cast to proper data types
- Add calculated fields
- Document all transformations

❌ **DON'T:**
- Create complex business aggregations (save for gold)
- Mix multiple subject areas in one model
- Skip documentation
- Ignore data quality issues

## Next Steps

1. **Run silver models**: `dbt run --select silver`
2. **Add quality tests**: Edit `schema.yml` to add tests
3. **Run tests**: `dbt test --select silver`
4. **Add transformations**: Gradually enhance each model
5. **Document changes**: Update this README as you add features
