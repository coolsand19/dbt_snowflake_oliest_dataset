# dbt Seeds - Static Reference Data

## 📁 Files in This Folder

Based on your ingestion strategy, **only small lookup/reference tables** should be here:

### 1. Category Mapping
**File**: `product_category_name_translation.csv` (from Olist dataset)
- **Purpose**: Maps Portuguese product category names to English translations
- **Size**: ~71 rows (small, perfect for seed)
- **Load method**: `dbt seed`

### 2. Geolocation ❌ NOT A SEED
**File**: `olist_geolocation_dataset.csv` (from Olist dataset)
- **Purpose**: Postal code to city/state/lat/long mapping
- **Size**: 1,000,164 rows - TOO LARGE for dbt seed
- **Load method**: Use **COPY INTO** (batch load) instead
- **Location**: Keep in `/home/user/SnowflakeProject/` for Snowflake COPY command

---

## 🚫 What Should NOT Be Here

The following files use different ingestion methods (NOT dbt seeds):

| File | Ingestion Method | Reason |
|------|-----------------|--------|
| `olist_orders_dataset.csv` | **Snowpipe** (convert to JSON) | Large transactional data |
| `olist_order_items_dataset.csv` | **Snowpipe** (convert to JSON) | Large transactional data |
| `olist_order_payments_dataset.csv` | **Snowpipe** (convert to JSON) | Large transactional data |
| `olist_products_dataset.csv` | **COPY INTO** | ERP master data (batch) |
| `olist_sellers_dataset.csv` | **COPY INTO** | Store/warehouse master (batch) |
| `olist_customers_dataset.csv` | **COPY INTO + Stream** | CDC simulation |
| `olist_order_reviews_dataset.csv` | **COPY INTO** | Batch feedback data |
| Synthetic price_list.csv | **COPY INTO** | ERP batch data |
| Synthetic stock_snapshot.csv | **COPY INTO** | Daily inventory batch |
| Synthetic inventory_movements.json | **Snowpipe** | Real-time events |

---

## 📋 Instructions

### Step 1: Copy Files to Seeds Folder

```bash
# Navigate to your Olist data location
cd /path/to/your/olist/data

# Copy ONLY these two files to seeds:
cp product_category_name_translation.csv \
   /home/user/SnowflakeProject/dbt_Ecommerce_project/seeds/

# Check geolocation size first:
wc -l olist_geolocation_dataset.csv

# If < 10,000 lines, copy it too:
cp olist_geolocation_dataset.csv \
   /home/user/SnowflakeProject/dbt_Ecommerce_project/seeds/
```

### Step 2: Load Seeds into Snowflake

```bash
cd /home/user/SnowflakeProject/dbt_Ecommerce_project
dbt seed
```

### Step 3: Verify Seeds Loaded

```sql
-- In Snowflake:
SELECT * FROM omni_retail.seeds.product_category_name_translation LIMIT 10;
SELECT * FROM omni_retail.seeds.olist_geolocation_dataset LIMIT 10;
```

---

## ⚙️ Configuration

Seeds are configured in `dbt_project.yml`. After copying files, the configuration will specify:
- Target schema: `seeds`
- Column types (for proper data typing)
- Documentation references

---

## 💡 Best Practices

1. **Keep seeds small**: < 1 MB, < 10,000 rows
2. **Version control**: Seeds are committed to git (don't put sensitive data here)
3. **Static data only**: Lookup tables that rarely change
4. **For large reference data**: Use COPY INTO instead

---

## 🔗 Referencing Seeds in dbt Models

```sql
-- Example: Join product categories
SELECT 
  p.product_id,
  p.product_category_name,
  c.category_name_english
FROM {{ source('raw', 'bronze_products') }} p
LEFT JOIN {{ ref('product_category_name_translation') }} c
  ON p.product_category_name = c.category_name_portuguese
```

---

**Next Steps**: 
1. Copy the 2 seed files to this folder
2. Run `dbt seed` to load them into Snowflake
3. Configure other data sources using COPY INTO and Snowpipe
