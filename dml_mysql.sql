### 1. -------------LOADING AND CLEANING THE DATASET-----------------------

### base 
drop table if exists `amz_sales`;
CREATE TABLE `amz_sales` (
  `index` int DEFAULT NULL,
  `Order ID` text,
  `Date` text,
  `Status` text,
  `Fulfilment` text,
  `Sales Channel` text,
  `ship-service-level` text,
  `Style` text,
  `SKU` text,
  `Category` text,
  `Size` text,
  `ASIN` text,
  `Courier Status` text,
  `Qty` int DEFAULT NULL,
  `currency` text,
  `Amount` double DEFAULT NULL,
  `ship-city` text,
  `ship-state` text,
  `ship-postal-code` double DEFAULT NULL,
  `ship-country` text,
  `promotion-ids` text,
  `B2B` text,
  `fulfilled-by` text,
  `Unnamed: 22` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

### loading the dataset
drop table if exists amz_copy;
create table amz_copy like amz_sales;
SET GLOBAL local_infile=1;
LOAD DATA LOCAL INFILE 'C:/Amazon Sale Report.csv' ### to replicate, specify your own directory
INTO TABLE amz_copy
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 lines;

### normalizing column names
ALTER TABLE `ecommerce_db`.`amz_copy` 
CHANGE COLUMN `Order ID` order_id 				VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Date` `order_date_text` 			TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Status` `order_status` 			VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Fulfilment` `fulfilment` 		VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Sales Channel` `sales_chnl` 		VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `ship-service-level` `ship_lvl` 	VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Style` `item_style` 				VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Category` `item_cat` 			VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Size` `item_size` 				VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Courier Status` `courier_status` VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Qty` `item_qty` 					INT NULL DEFAULT NULL ,
CHANGE COLUMN `Amount` `price` 					FLOAT NULL DEFAULT NULL ,
CHANGE COLUMN `ship-city` `ship_city` 			VARCHAR(200) NULL DEFAULT NULL ,
CHANGE COLUMN `ship-state` `ship_state` 		VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `ship-postal-code` `ship_postal`	TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `ship-country` `ship_country`	 	TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `promotion-ids` `promo_id` 		TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `fulfilled-by` `fulfilled_by` 	VARCHAR(50) NULL DEFAULT NULL ,
CHANGE COLUMN `Unnamed: 22` `unnamed` 			VARCHAR(50) NULL DEFAULT NULL
;

### deleting duplicates
delete from amz_copy where order_id in (
SELECT order_id
FROM (
    SELECT *, 
           row_number() OVER(
           PARTITION BY order_id, order_date_text, order_status, fulfilment,
           sales_chnl, ship_lvl, item_style, sku, item_cat, item_size, asin, courier_status
           ) as row_num
    FROM amz_copy
) t
WHERE row_num > 1);


### converting column types
### 1. date
alter table amz_copy add order_date date after order_date_text;
update amz_copy set order_date = str_to_date(order_date_text, "%m-%d-%Y");
alter table amz_copy drop order_date_text;

### 2. binary
alter table amz_copy add is_b2b int;
update amz_copy set is_b2b = case when b2b like '%true%' then 1 else 0 end;


### handling missing values
update amz_copy set courier_status = "Cancelled" where courier_status = '';

### normalizing size
alter table amz_copy add item_size_num int after item_size;
update amz_copy set item_size_num = 1	where item_size = "XS"	;
update amz_copy set item_size_num = 2 	where item_size = "S"	;
update amz_copy set item_size_num = 3 	where item_size = "M"	;
update amz_copy set item_size_num = 4	where item_size = "Free";
update amz_copy set item_size_num = 5	where item_size = "L"	;
update amz_copy set item_size_num = 6 	where item_size = "XL"	;
update amz_copy set item_size_num = 7 	where item_size = "XXL"	;
update amz_copy set item_size_num = 8 	where item_size = "3XL"	;
update amz_copy set item_size_num = 9 	where item_size = "4XL"	;
update amz_copy set item_size_num = 10 	where item_size = "5XL"	;
update amz_copy set item_size_num = 11 	where item_size = "6XL"	;



### normalizing promo_id
alter table amz_copy add promo_id_norm varchar(50) after promo_id;
update amz_copy set promo_id_norm = 'Amazon PLCC'             where promo_id like 'Amazon%';
update amz_copy set promo_id_norm = 'VPC_coupon' 			  where promo_id like 'VPC%';
update amz_copy set promo_id_norm = 'IN Core Free Shippping'  where promo_id like '%IN Core%';
update amz_copy set promo_id_norm = 'Duplicated' 			  where promo_id like 'Duplicated%';
update amz_copy set promo_id_norm = 'No promo' 		where promo_id is NULL or trim(promo_id) = '';



### normalizing categorical fields into binary or tetriary
alter table amz_copy add is_fulfil_amz int after fulfilment;
alter table amz_copy add is_chnl_amz int after sales_chnl;
alter table amz_copy add is_expedited int after ship_lvl;
alter table amz_copy add courier_norm int after courier_status;
alter table amz_copy add is_shipped int after courier_norm;

alter table amz_copy 
		add index ful_idx(fulfilment),
		add index chnl_idx(sales_chnl),
		add index shiplvl_idx(ship_lvl),
		add index courier_idx(courier_status);
update amz_copy set is_fulfil_amz = case when fulfilment like '%Amazon%' then 1 else 0 end;
update amz_copy set is_chnl_amz = case when sales_chnl like 'Amazon%' then 1 else 0 end;
update amz_copy set is_expedited = case when ship_lvl like '%Expedited%' then 1 else 0 end;
update amz_copy set courier_norm = case when courier_status like 'Shipped%' then 2 when courier_status like 'Unshipped%' then 1 else 0 end;
update amz_copy set is_shipped = case when courier_status like 'Shipped%' then 1 when courier_status like 'Cancelled%' then 0 end;



### fixing city address for biggest cities
update amz_copy set ship_city = regexp_replace(ship_city, '[^a-zA-Z\\s]', '');
update amz_copy set ship_city = regexp_replace(ship_city, '[0-9]', '');

update amz_copy set ship_city = 'Bengaluru' 	where ship_city like '%Bangalore%' or ship_city like '%Bengaluru%';
update amz_copy set ship_city = 'Mumbai' 		where (ship_city like '%Mumbai%' and ship_city not like '%Navi%') or ship_city like '%Bombay%';
update amz_copy set ship_city = 'Hyderabad'		where ship_city like '%Hyderabad%' or ship_city like '%Haidarabad%';
update amz_copy set ship_city = 'Delhi' 		where ship_city like '%Delhi%';
update amz_copy set ship_city = 'Chennai' 		where ship_city like '%Chennai%' or ship_city like '%Madras%';
update amz_copy set ship_city = 'Ahmedabad' 	where ship_city like '%Ahmedabad%' or ship_city like '%Amdavad%';
update amz_copy set ship_city = 'Kolkata' 		where ship_city like '%Kolkata%' or ship_city like '%Calcutta%';
update amz_copy set ship_city = 'Pune' 			where ship_city like '%Pune%' or ship_city like '%Poona%';
update amz_copy set ship_city = 'Surat' 		where ship_city like '%Surat%';
update amz_copy set ship_city = 'Jaipur'		where ship_city like '%Jaipur%';
update amz_copy set ship_city = 'Lucknow' 		where ship_city like '%Lucknow%';
update amz_copy set ship_city = 'Kanpur' 		where ship_city like '%Kanpur%' or ship_city like '%Cawnpore%';
update amz_copy set ship_city = 'Nagpur' 		where ship_city like '%Nagpur%';
update amz_copy set ship_city = 'Indore' 		where ship_city like '%Indore%';
update amz_copy set ship_city = 'Thane' 		where ship_city like '%Thane%' and ship_city not like '%Navi%';

update amz_copy set ship_city = concat(upper(left(ship_city, 1)), lower(substring(ship_city, 2)));

### normalizing city
alter table amz_copy add ship_city_norm varchar(50) after ship_city;
update amz_copy
set ship_city_norm = case
  when ship_city in (
    select ship_city from (
      select ship_city, count(*) as ship_count
      from amz_copy
      group by ship_city
      having count(*) > 10
    ) as t
  ) then ship_city
  else 'Other'
end;



### 2. ----------------CLEANING FINISHED, PREPARING FOR ANALYSIS------------------------

### creating a clean copy
drop table if exists amz_clean;
create table amz_clean like amz_copy;
insert into amz_clean select * from amz_copy;


### dropping unnecessary columns
alter table amz_clean 
		drop column ship_country, 
		drop column currency, 
		drop column unnamed, 
		drop column order_status,
		drop column order_id, 
		drop column asin,
		drop column ship_postal,
		drop column promo_id,
		drop column fulfilment,
		drop column fulfilled_by,
		drop column sales_chnl,
		drop column ship_lvl,
		drop column b2b,
        drop column ship_city,
        drop column sku,
		drop column courier_status;



### adding indexes to low cardinality fields
alter table amz_clean 
		add index idx_ship_city(ship_city_norm),
		add index idx_ship_state(ship_state),
		add index idx_item_cat(item_cat),
		add index idx_item_size(item_size_num);
        

alter table amz_clean add column order_month varchar(20) after order_date; 
alter table amz_clean add column order_day varchar(20) after order_month; 

update amz_clean set order_month = month(order_date);
update amz_clean set order_day = dayname(order_date);
delete from amz_clean where courier_norm = 0 and price > 0;
