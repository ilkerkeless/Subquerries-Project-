# 🧮 Subqueries in SQL – Data Transformation & Financial Analysis (BigQuery)

This project demonstrates the use of **subqueries (CTEs)** in SQL to perform data transformations and reporting without creating unnecessary intermediate tables.  
The dataset simulates e‑commerce financial operations including sales, shipping, campaigns, and NPS data.

---

## 📊 Project Overview

**Objective:**  
To apply subqueries in BigQuery to combine and transform multiple datasets (`gwz_sales_17`, `gwz_ship_17`, `gwz_campaign_17`, `gwz_nps_17`) into meaningful financial and marketing insights.

**Dataset Location:**  
`course17` → EU Multi‑Region

---

## 🧱 Steps & SQL Logic

### **1.1) Combining Sales & Shipping Tables**

**🎯 Purpose**  
To calculate total turnover and margin per order, and combine it with shipping and operational costs.

**🧠 SQL Logic**  
```sql
WITH orders_join AS (
  SELECT date_date,
         orders_id,
         ROUND(SUM(turnover),2) AS turnover,
         ROUND(SUM(turnover - purchase_cost),2) AS margin
  FROM `course17.gwz_sales_17`
  GROUP BY date_date, orders_id
)
SELECT o.date_date, o.orders_id, o.turnover, o.margin,
       sh.shipping_fee, sh.log_cost + sh.ship_cost AS operational_cost
FROM orders_join o
LEFT JOIN `course17.gwz_ship_17` sh
  ON sh.orders_id = o.orders_id;
```

**📈 Query Output (BigQuery Result Preview)**  
![First Join](https://github.com/ilkerkeless/Subquerries-Project-/blob/main/Workintech%20Subquerries%20Project/Outputs%20of%20Querries/Subquerries-%20First%20Join%20.png)

**💬 Interpretation**  
This result shows each order’s turnover and margin alongside shipping and operational costs, enabling order‑level profitability tracking.

---

### **1.2) Merging Orders & Campaigns**

**🎯 Purpose**  
To combine daily financial data with advertising spend in order to evaluate the effect of campaigns on sales performance.

**🧠 SQL Logic**  
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
LEFT JOIN campaign_date cd
  USING (date_date);
```

**📈 Query Output**  
![Merging Orders and Campaigns](https://github.com/ilkerkeless/Subquerries-Project-/blob/main/Workintech%20Subquerries%20Project/Outputs%20of%20Querries/Merging%20Orders%20and%20Campaigns%20.png)

**💬 Interpretation**  
This output aligns the turnover and operational costs with ads cost per day, so you can analyze campaign influence on sales.

---

### **2.1) Margin Calculation**

**🎯 Purpose**  
Calculate product‑level margins and categorize them into “Low”, “Medium”, “High” based on margin percent thresholds.

**🧠 SQL Logic**  
```sql
WITH margin_table AS (
  SELECT orders_id, products_id, turnover,
         turnover - purchase_cost AS margin
  FROM `course17.gwz_sales_17`
),
margin_percent_table AS (
  SELECT orders_id, products_id, margin, turnover,
         ROUND(SAFE_DIVIDE(margin, turnover),2) AS margin_percent
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

**📈 Query Output**  
![Margin Calculation](https://github.com/ilkerkeless/Subquerries-Project-/blob/main/Workintech%20Subquerries%20Project/Outputs%20of%20Querries/Margin%20Calculation.png)

**💬 Interpretation**  
Each product’s margin percent is calculated and categorized, helping identify products with high vs low profitability.

---

### **2.2) Promotion Classification**

**🎯 Purpose**  
Classify promotions into “Short‑lived”, “High promotion”, “Medium promotion”, and “Low promotion” based on discount percent and promo type.

**🧠 SQL Logic**  
```sql
WITH promo_table AS (
  SELECT orders_id, products_id, turnover, promo_name,
         turnover_before_promo - turnover AS promo
  FROM `course17.gwz_sales_17`
),
promo_percent_table AS (
  SELECT orders_id, products_id, turnover, promo_name, promo,
         ROUND(SAFE_DIVIDE(promo, turnover),2) AS promo_percent
  FROM promo_table
)
SELECT orders_id, products_id, turnover, promo_name, promo, promo_percent,
  CASE
    WHEN UPPER(promo_name) LIKE "%DLC%" OR UPPER(promo_name) LIKE "%DLUO%" THEN "Short‑lived"
    WHEN promo_percent >= 0.30 THEN "High promotion"
    WHEN promo_percent < 0.10 THEN "Low promotion"
    WHEN promo_percent BETWEEN 0.10 AND 0.30 THEN "Medium promotion"
  END AS promo_type
FROM promo_percent_table;
```

**📈 Query Output**  
![Promotion Classification](https://github.com/ilkerkeless/Subquerries-Project-/blob/main/Workintech%20Subquerries%20Project/Outputs%20of%20Querries/Promotion%20Classification.png)

**💬 Interpretation**  
Promotion percentages are computed and classified—this assists in identifying effectiveness of different promo strategies.

---

## 💡 Key Takeaways

- CTEs (Common Table Expressions) enhance SQL readability and reduce unnecessary intermediate tables.  
- JOINs outperform correlated subqueries in multi‑table analytical contexts (KISS principle: Keep It Simple, Stupid!).  
- This project covers data aggregation, categorization, and business metric computation from raw e‑commerce datasets.

---

## 🧰 Tools & Environment

- **Platform:** Google BigQuery  
- **Language:** Standard SQL  
- **Region:** EU (multi‑region)  
- **Dataset:** `course17` (contains sales, shipping, campaign, NPS data)

---

## 📈 Author

**İlker Keleş**  
*Aspired Data Analyst | Workintech Data Analyst Program*  
[GitHub](https://github.com/ilkerkeless) • [LinkedIn](https://www.linkedin.com/in/ilkerkeless)
