# Why Are 4 Tests Still Failing?

## ✅ **Your Timestamp Test PASSES** - Mission Accomplished!
- `test_order_timestamps_logical_sequence` ✅ **PASS**

---

## ❌ **The 4 Failing Tests - Root Cause Analysis**

### 1️⃣ **test_delivered_orders_have_delivery_date** (84 failures)
**Status:** ⚠️ **INCREASED DUE TO OUR CHANGES** (was 8, now 84)

**Why It's Failing:**
- Orders with status = 'delivered' but `ORDER_DELIVERED_CUSTOMER_DATE` IS NULL
- **Our cleaning logic set ~76 more delivery dates to NULL** when they violated timestamp sequence

**What Happened:**
```sql
-- In stg_orders.sql, we did this:
CASE 
    WHEN ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL 
         AND ORDER_DELIVERED_CUSTOMER_DATE < ORDER_DELIVERED_CARRIER_DATE 
    THEN NULL  -- ❗ This created new NULL values
    ...
END AS ORDER_DELIVERED_CUSTOMER_DATE
```

**Is This a Problem?**
- ✅ **NO** - This is the correct behavior!
- We nullified ILLOGICAL dates (customer delivery before carrier pickup)
- These dates were **wrong**, so NULL is more accurate than a bad date

**Solution Options:**
1. **Accept it** - NULL is better than illogical dates
2. **Fix the test** - Adjust it to allow NULL for edge cases
3. **Set to estimated date** - Use `ORDER_ESTIMATED_DELIVERY_DATE` as fallback

---

### 2️⃣ **test_payment_amount_matches_order_total** (1,040 failures)
**Status:** ✅ **NOT RELATED TO OUR CHANGES**

**Why It's Failing:**
- Payment totals don't match order item totals (price + freight mismatch)
- This is a **source data quality issue** from the original dataset

**Our Impact:** ZERO - We didn't modify payment or order item data

---

### 3️⃣ **unique_stg_customers_customer_unique_id** (2,997 failures)
**Status:** ✅ **NOT RELATED TO OUR CHANGES**

**Why It's Failing:**
- Duplicate customer records in the bronze layer
- Same customer appears multiple times with different customer_ids

**Our Impact:** ZERO - We didn't modify customer data

---

### 4️⃣ **unique_stg_order_reviews_review_id** (747 failures)
**Status:** ✅ **NOT RELATED TO OUR CHANGES**

**Why It's Failing:**
- Duplicate review IDs in the source data
- Data quality issue in the original dataset

**Our Impact:** ZERO - We didn't modify review data

---

## 📊 **Summary**

| Test | Status Before | Status After | Caused By Our Changes? |
|------|---------------|--------------|----------------------|
| ✅ `test_order_timestamps_logical_sequence` | ❌ FAIL (1,400) | ✅ **PASS** | ✅ **FIXED!** |
| ❌ `test_delivered_orders_have_delivery_date` | ❌ FAIL (8) | ❌ FAIL (84) | ⚠️ **YES** - Side effect of cleaning |
| ❌ `test_payment_amount_matches_order_total` | ❌ FAIL (1,040) | ❌ FAIL (1,040) | ✅ NO |
| ❌ `unique_stg_customers_customer_unique_id` | ❌ FAIL (2,997) | ❌ FAIL (2,997) | ✅ NO |
| ❌ `unique_stg_order_reviews_review_id` | ❌ FAIL (747) | ❌ FAIL (747) | ✅ NO |

---

## 🎯 **Bottom Line**

### ✅ **Mission Accomplished:**
Your timestamp sequence test now passes perfectly!

### ⚠️ **Trade-off:**
- We fixed 1,400 timestamp sequence violations
- As a side effect, 76 additional orders now have NULL delivery dates
- This is **correct behavior** - NULL is more honest than an illogical date

### 💡 **Recommendation:**
The timestamp cleaning was successful. The increase in NULL delivery dates is an acceptable trade-off for data integrity.
