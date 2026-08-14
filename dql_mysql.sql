
#------------------- SELECT ALL ---------------------------
SELECT * FROM amz_clean;



#-----------------------------------------------------------
### Testing Assumptions
### 1. not shipped has 0 price
select courier_norm, avg(price) from amz_clean group by courier_norm;
### 2. quantity directly correlates with price
select distinct item_qty, avg(price) as average_price from amz_clean group by item_qty order by item_qty asc;
### 3. dates are correct
select distinct order_date, count(*) as count from amz_clean group by order_date order by order_date desc limit 10000;

#----------------------------------------------------------------------------------


### SELECT COUNT AND PERCENTAGE

### ITEM 
with cte_countall as (select count(*) as `Out of total`, sum(price) as `Out of total revenue` from amz_clean) select 
	a.item_cat,
	count(*) as `How many orders`,
	round(count(*)*100 / sum(count(*)) over(), 1) as percentage, 
    b.`Out of total`,
    sum(a.price) as `Revenue`,
    round(sum(a.price)*100 / sum(sum(a.price)) over(), 1) as percentage,
    b.`Out of total revenue`, 
    round(avg(a.price), 1) as `Average_revenue`
from amz_clean a
cross join cte_countall b
group by a.item_cat, b.`Out of total`, b.`Out of total revenue`
order by `How many orders` desc;

### ITEM (BUT PRETTIER)
WITH cte_countall AS (
    SELECT COUNT(*) AS total_orders, SUM(price) AS total_revenue
    FROM amz_clean
)
SELECT 
    a.item_cat,
    FORMAT(COUNT(*), 0) AS `How many orders`,
    CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1), '%') AS order_percentage,
    FORMAT(b.total_orders, 0) AS `Out of total`,
    CONCAT('₹', FORMAT(SUM(a.price), 0)) AS `Revenue`,
    CONCAT(ROUND(SUM(a.price) * 100 / SUM(SUM(a.price)) OVER (), 1), '%') AS revenue_percentage,
    CONCAT('₹', FORMAT(b.total_revenue, 0)) AS `Out of total revenue`
FROM amz_clean a
CROSS JOIN cte_countall b
GROUP BY a.item_cat, b.total_orders, b.total_revenue
ORDER BY COUNT(*) DESC;


### ITEM SIZE
with cte_avg_size as (select avg(item_size_num) as avg_size, avg(price) as avg_price from amz_clean) select 
	a.item_size_num,
    a.item_size,
	concat(round(count(*)*100 / sum(count(*)) over(), 1), '%') as `Percentage of Orders`,
	concat(round(sum(price)*100 / sum(sum(price)) over(), 1), '%') as `Percentage of Revenue`,
    CONCAT('₹', round(avg(a.price), 1)) as `Average Revenue`,
	b.avg_size as `Global Average Size`,
    CONCAT('₹', round(b.avg_price, 1)) as `Global Average Revenue`
from amz_clean a cross join cte_avg_size b
group by item_size_num, avg_size, item_size
order by 1 asc;

### SHIP CITY EDA
WITH cte_countall AS (
    SELECT COUNT(*) AS total_orders, SUM(price) AS total_revenue
    FROM amz_clean
)
SELECT 
    a.ship_city_norm as `Shipment city`,
    FORMAT(COUNT(*), 0) AS `How many orders`,
    CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1), '%') AS order_percentage,
    FORMAT(b.total_orders, 0) AS `Out of total`,
    CONCAT('₹', FORMAT(SUM(a.price), 0)) AS `Revenue`,
    CONCAT(ROUND(SUM(a.price) * 100 / SUM(SUM(a.price)) OVER (), 1), '%') AS revenue_percentage,
    CONCAT('₹', FORMAT(b.total_revenue, 0)) AS `Out of total revenue`
FROM amz_clean a
CROSS JOIN cte_countall b
GROUP BY a.ship_city_norm, b.total_orders, b.total_revenue
ORDER BY COUNT(*) DESC;


### SHIP STATE (no need for big select)
select 
	ship_state,
	count(*) as item_count,
	count(*)*100 / sum(count(*)) over() as percentage 
from amz_clean 
group by ship_state 
order by count(*) desc;





### ORDER MONTH
select 
	order_month,
	count(*) as `How many orders`,
	count(*)*100 / sum(count(*)) over() as percentage,
    round(avg(price), 1) as `Average Revenue`
from amz_clean 
group by order_month 
order by 1 asc;


### ORDER DAY
select 
	order_day,
	concat(round(count(*)*100 / sum(count(*)) over(), 1), '%') as `Out of Orders`,
	concat(round(sum(price)*100 / sum(sum(price)) over(), 1), '%') as `Out of Revenue`,
    concat('₹', round(avg(price), 1)) as `Average Revenue`
from amz_clean 
group by order_day 
order by field (order_day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') ;


### IS B2B MORE AVG MONEY?? (yes)
select is_b2b, avg(price) as `Average Revenue` from amz_clean group by is_b2b;

select is_shipped from amz_clean where is_chnl_amz = 0;


### success of shipments

select item_cat, avg(is_chnl_amz) as average_completion from amz_clean group by item_cat order by average_completion desc;


select is_fulfil_amz, avg(is_shipped) as average_completion from amz_clean group by is_fulfil_amz order by average_completion desc;

select is_chnl_amz, avg(is_shipped) as average_completion from amz_clean group by is_chnl_amz order by average_completion desc;

select is_expedited, avg(is_shipped) as average_completion from amz_clean where is_fulfil_amz = 1 group by is_expedited order by average_completion desc;

select ship_lvl, count(*) from amz_copy where fulfilment like 'Amazon%' group by ship_lvl ;
select fulfilment, count(*) from amz_copy where ship_lvl like 'Standard%' group by fulfilment;