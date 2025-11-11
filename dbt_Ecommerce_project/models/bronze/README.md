# Bronze Layer - Raw Data Passthrough

## Purpose
The bronze layer provides a **1:1 mapping** of raw tables in the `RAW` schema without any transformations. This layer:
- References source tables using dbt's `{{ source() }}` function
- Uses `SELECT *` to pass through all columns unchanged
- Materialized as **views** for zero storage overhead
- Serves as the foundation for silver layer transformations

## Medallion Architecture
```
RAW Schema (Snowflake) 
    ↓
BRONZE Layer (dbt views - this folder)
    ↓
SILVER Layer (cleaned/conformed)
    ↓
GOLD Layer (business marts)
```

## Models in This Layer

### Streaming Data (Snowpipe - JSON Events)
| Model | Source Table | Description |
|-------|--------------|-------------|
| `bronze_orders` | `raw.orders` | E-commerce orders from JSON events |
| `bronze_order_items` | `raw.order_items` | Order line items from JSON events |
| `bronze_order_payments` | `raw.order_payments` | Payment events from JSON |

### Batch Data (COPY INTO - CSV from ERP/CRM)
| Model | Source Table | Description |
|-------|--------------|-------------|
| `bronze_products` | `raw.products` | Product master data from ERP |
| `bronze_sellers` | `raw.sellers` | Seller/store master data |
| `bronze_customers` | `raw.customers` | Customer master with CDC |
| `bronze_order_reviews` | `raw.order_reviews` | Order reviews and feedback |
| `bronze_geolocation` | `raw.geolocation` | Postal code to location mapping |

### Reference Data (dbt Seeds)
| Model | Source Table | Description |
|-------|--------------|-------------|
| `bronze_category_translation` | `raw.product_category_name_translation` | Category Portuguese→English mapping |

## Configuration

All bronze models are configured in `dbt_project.yml`:

```yaml
models:
  dbt_Ecommerce_project:
    bronze:
      +materialized: view
      +schema: bronze
```

## Usage

Bronze models are referenced in silver layer models:

```sql
-- In silver/stg_orders.sql
SELECT 
  order_id,
  customer_id,
  CAST(order_purchase_timestamp AS TIMESTAMP_NTZ) AS order_purchased_at,
  -- ... transformations ...
FROM {{ ref('bronze_orders') }}
```

## Key Principles

✅ **DO:**
- Keep models as simple `SELECT *` statements
- Use views for zero storage cost
- Add comments explaining source ingestion method
- Document source tables in `sources.yml`

❌ **DON'T:**
- Apply transformations (save for silver layer)
- Filter rows or columns
- Join tables
- Add business logic

## Building Bronze Models

```bash
# Build all bronze models
dbt run --select bronze

# Build specific model
dbt run --select bronze_orders

# Test sources
dbt test --select source:raw
```

## Source Definition

All raw tables are defined in `sources.yml` in this folder. This provides:
- Documentation of upstream tables
- Freshness checks (optional)
- Column-level descriptions
- Lineage tracking in dbt docs
