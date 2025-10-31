# 🧮 Subqueries in SQL – Data Transformation & Financial Analysis (BigQuery)

This project demonstrates the use of **subqueries (CTEs)** in SQL to perform data transformations and reporting without creating unnecessary intermediate tables.  
The dataset simulates Greenweez’s e-commerce financial operations including sales, shipping, campaigns, and NPS data.  

---

## 📊 Project Overview

**Objective:**  
To apply subqueries in BigQuery to combine and transform multiple datasets (`gwz_sales_17`, `gwz_ship_17`, `gwz_campaign_17`, `gwz_nps_17`) into meaningful financial and marketing insights.

**Dataset Location:**  
`course17` → EU Multi-Region  

---

## 🧱 Steps & SQL Logic

### **1.1) Combining Sales and Shipping Tables**

**Goal:** Create a financial tracking table by joining sales and shipping data using subqueries.  
**Process:**
- Group `gwz_sales_17` by `orders_id` and `date_date` → calculate `turnover` and `margin`.
- Use a **CTE** to temporarily store these aggregations.
- Join with `gwz_ship_17` to bring in `shipping_fee` and operational costs.

```sql
WITH orders_join AS (
  SELECT date_date,
         orders_id,
         ROUND(SUM(turnover), 2) AS turnover,
         ROUND(SUM(turnover - purchase_cost), 2) AS margin
  FROM `course17.gwz_sales_17`
  GROUP BY date_date, orders_id
)
SELECT o.date_date, o.orders_id, o.turnover, o.margin,
       sh.shipping_fee, sh.log_cost + sh.ship_cost AS operational_cost
FROM orders_join o
LEFT JOIN `course17.gwz_ship_17` sh ON sh.orders_id = o.orders_id;
```

🧠 **KPI:** Turnover, Margin, Operational Cost

---

### **1.2) Merging Orders and Campaigns**

**Goal:** Combine daily financial data with advertising spend.  
**Process:**
- Group both `gwz_orders_join` and `gwz_campaign_17` by `date_date`.
- Join on `date_date` to align sales with campaign costs.

```sql
WITH orders_date AS (
  SELECT date_date,
         SUM(turnover) AS turnover,
         SUM(shipping_fee) AS shipping_fee,
         SUM(operational_cost) AS operational_cost
  FROM `course17.gwz_orders_join`
  GROUP BY date_date
),
campaign_date AS (
  SELECT date_date,
         SUM(ads_cost) AS ads_cost
  FROM `course17.gwz_campaign_17`
  GROUP BY date_date
)
SELECT o.date_date, o.turnover, o.operational_cost, o.shipping_fee, cd.ads_cost
FROM orders_date o
LEFT JOIN campaign_date AS cd USING (date_date);
```

🧠 **KPI:** Turnover, Ads Cost, Shipping Fee, Operational Cost

---

### **2.1) Margin Calculation**

**Goal:** Calculate product-level profit margins and categorize them.  
**Process:**
- Compute `margin = turnover - purchase_cost`.
- Calculate `margin_percent = margin / turnover`.
- Categorize margin performance using CASE logic.

```sql
WITH margin_table AS (
  SELECT orders_id, products_id, turnover,
         turnover - purchase_cost AS margin
  FROM `course17.gwz_sales_17`
),
margin_percent_table AS (
  SELECT orders_id, products_id, margin, turnover,
         ROUND(SAFE_DIVIDE(margin, turnover), 2) AS margin_percent
  FROM margin_table
)
SELECT orders_id, products_id, margin, margin_percent,
  CASE
    WHEN margin_percent < 0.05 THEN "Low"
    WHEN margin_percent BETWEEN 0.05 AND 0.4 THEN "Medium"
    WHEN margin_percent >= 0.4 THEN "High"
  END AS margin_level
FROM margin_percent_table;
```

🧠 **KPI:** Margin %, Margin Level

---

### **2.2) Promotion Classification**

**Goal:** Categorize product promotions based on discount percentage and type.  
**Process:**
- Compute `promo = turnover_before_promo - turnover`
- Calculate `promo_percent = promo / turnover`
- Use CASE logic to assign promo type.

```sql
WITH promo_table AS (
  SELECT orders_id, products_id, turnover, promo_name,
         turnover_before_promo - turnover AS promo
  FROM `course17.gwz_sales_17`
),
promo_percent_table AS (
  SELECT orders_id, products_id, turnover, promo_name, promo,
         ROUND(SAFE_DIVIDE(promo, turnover), 2) AS promo_percent
  FROM promo_table
)
SELECT orders_id, products_id, turnover, promo_name, promo, promo_percent,
  CASE
    WHEN UPPER(promo_name) LIKE "%DLC%" OR UPPER(promo_name) LIKE "%DLUO%" THEN "Short-lived"
    WHEN promo_percent >= 0.30 THEN "High promotion"
    WHEN promo_percent < 0.10 THEN "Low promotion"
    WHEN promo_percent BETWEEN 0.10 AND 0.30 THEN "Medium promotion"
  END AS promo_type
FROM promo_percent_table;
```

🧠 **KPI:** Promo %, Promo Type
