# MySQL and PowerBI project with an E-commerce dataset
The first part of this project is based in MySQL, featuring two scripts for DML and DQL: Cleaning and Descriptive Statistics respectively. Second part features a dashboard with major KPIs and overview of sales.

The dataset consists of Amazon orders and shipments. It is available at: https://www.kaggle.com/datasets/thedevastator/unlock-profits-with-e-commerce-sales-data/

Final dashboard looks like this:

<img width="1089" height="769" alt="image" src="https://github.com/user-attachments/assets/a87b8146-d30b-480e-944d-6339f61f9287" />

## SQL Skills included:
Outside of general DDL, DML, DQL (CREATE, DROP, ALTER, UPDATE, SELECT)

* CTEs
* JOINs
* Aggregate functions (AVG, COUNT, SUM etc)
* OVER (PARTITION BY)
* ADD INDEX
* REGEXP, LIKE + wildcards '%string%'
  

## Data cleaning steps taken:
1. Column name normalization
2. Dropping full duplicates
3. Converting column types where needed (like binary or date)
4. Normalizing fields  
  * item_size: XL -> 6, XXL -> 7 (example)
  * promo_id: grouping by type
  * categorical fields to 0 1 (fulfilment, sales channel etc)
  * ship_city: fixing most typos, then grouping all small cities into "Other" category
5. Creating a cleaned copy of the table
6. Dropping unnecessary columns
7. Adding indexes for faster queries
8. Adding month and day fields out of order_date

Before:
<img width="1919" height="599" alt="image" src="https://github.com/user-attachments/assets/cd5fcae9-288d-4828-89b6-333a0b5be109" />


After:

<img width="1405" height="406" alt="image" src="https://github.com/user-attachments/assets/e6cae9ac-f920-4f43-92eb-185f89b1ec82" />


## Exploratory Data Analysis:

1. Table 1: Revenue and count of orders per each Item Style

<img width="706" height="208" alt="image" src="https://github.com/user-attachments/assets/276fc862-7031-4855-93fc-cbd9f1dc9430" />


**Most popular:** Set and Kurta by far (77.7% of total orders)

**Most revenue per order:** Set, Saree and Western Dress

Although Set and Kurta cumulatively add to approx 77% of both orders and revenue, **Set brings 22% more revenue than Kurta**.

<br>
<br>

2. Table 2: Revenue and count of orders per each Item Size

<img width="759" height="232" alt="image" src="https://github.com/user-attachments/assets/bf460c5e-f42e-41b0-a417-8b336ab4db16" />

**Most popular:** M and L sizes, most customers on average ordering somewhere in between.

**Most revenue per order**: The further from the middle the higher the price. Highest average revenue is for 4XL and above 

<br>
<br>

3. Table 3: Revenue and count of orders per Shipping city

<img width="693" height="348" alt="image" src="https://github.com/user-attachments/assets/dc7627e2-752b-4c95-af89-84d245b17dc2" />

Bengaluru, Hyderabad, Mumbai and Delhi amount to 36.6% of all orders and revenue. 10.7% of all orders were shipped to cities with less than 10 total shipments (this includes typos)

There is no significant difference between Revenue and number of orders per city.
<br>
<br>

4. Table 4 and 5: Average revenue and order density per month and day of week.

<img width="369" height="119" alt="image" src="https://github.com/user-attachments/assets/03c2a3fb-ea00-42e9-9167-56368f48bf5e" />

<br>

<img width="367" height="171" alt="image" src="https://github.com/user-attachments/assets/b483a347-e36f-41ed-9f8e-2e3a1098f985" />


April had worse average revenue by about 5%

Thursday and Friday on average have less orders with less average revenue
<br>
<br>

5. Table 6: Do B2B orders have more average revenue?

<img width="181" height="60" alt="image" src="https://github.com/user-attachments/assets/25863436-1836-4e5f-9e4e-5b062a143afb" />

B2B orders have abount 10% higher average revenue (this could mean higher amount ordered or more expensive items.
<br>
<br>
6. Table 7: Does Amazon ship more successfully?

   <img width="223" height="66" alt="image" src="https://github.com/user-attachments/assets/b50d8a1f-d09e-43c2-b7b8-e4ef7d83d3a7" />

Amazon has 1.5% lower shipment rate compared to non-Amazon merchants. Although the difference is negligible

After this, the data was imported into PowerBI for visualisation purposes



