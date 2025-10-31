
#1.1 


#
select orders_id,
date_date,
Round(sum(turnover),2) as turnover,
Round(Sum(turnover- purchase_cost),2) as margin from `course17.gwz_sales_17`
group by date_date,orders_id;

# gwz_orders & gwz_ship join
select o.date_date,
o.margin,
o.orders_id,
o.turnover,
s.shipping_fee,
s.log_cost + s.ship_cost as operational_cost
from `course17.gwz_orders_17`  as o 
left join `course17.gwz_ship_17` s on s.orders_id = o.orders_id;


# 1.1 Subquerry çözüm

with orders_join as (
select date_date,
orders_id,
Round(SUM(turnover),2) as turnover,
Round(Sum(turnover-purchase_cost),2) as margin
from `course17.gwz_sales_17`
Group by date_date,orders_id
)
select o.date_date,o.orders_id,o.turnover,o.margin,sh.shipping_fee,sh.log_cost + sh.ship_cost as operational_cost  from orders_join o
left join `course17.gwz_ship_17` sh on sh.orders_id = o.orders_id;

#1.2

with orders_date as (
select date_date,
SUM(turnover) as turnover,
SUM(shipping_fee) as shipping_fee,
SUM(operational_cost) as operational_cost from `course17.gwz_orders_join`
Group By date_date
),
campaign_date as(
select date_date,
SUM(ads_cost) as ads_cost,
 from `course17.gwz_campaign_17`
group by date_date
)
select o.date_date,
o.turnover,
o.operational_cost,
o.shipping_fee,
cd.ads_cost
 from orders_date o
left join campaign_date AS cd USING (date_date);

#2
 with margin_table as (
select orders_id,products_id,
turnover,
turnover-purchase_cost as margin from `course17.gwz_sales_17` 
),
margin_percent_table as (
select orders_id,
margin,
turnover,
products_id,
ROUND(SAFE_DIVIDE(margin,turnover),2) AS margin_percent from margin_table
)
 select orders_id,
 products_id,
 margin,
 margin_percent,
 case 
  when margin_percent < 0.05 then "DÜŞÜK"
  when margin_percent BETWEEN 0.05 and 0.4 then "ORTA"
  when margin_percent >=0.4 then "YÜKSEK"
 end as margin_level
from margin_percent_table;
 
#2.2
WITH promo_table AS (
 SELECT 
 orders_id, products_id, 
 turnover, promo_name, 
 turnover_before_promo - turnover AS promo 
 FROM course17.gwz_sales_17 
), 
promo_percent_table AS (
 SELECT 
 orders_id, products_id, 
 turnover, promo_name, promo, 
 ROUND(SAFE_DIVIDE(promo,turnover),2) AS promo_percent 
 FROM promo_table 
) 

SELECT 
 orders_id, products_id, 
 turnover, promo_name, promo, promo_percent, 
 CASE 
 WHEN UPPER(promo_name) LIKE "%DLC%" OR UPPER(promo_name) LIKE "%DLUO%" THEN "short-lived" 
 WHEN promo_percent >= 0.30 THEN "High promotion" 
 WHEN promo_percent < 0.10 THEN "Low promotion" 
 WHEN promo_percent >= 0.10 AND promo_percent < 0.30 THEN "Medium promotion" 
 ELSE NULL 
 END AS promo_type 
FROM promo_percent_table
 
 
 
 
 


