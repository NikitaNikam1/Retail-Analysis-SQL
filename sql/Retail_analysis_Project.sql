## create database
create database retail;

use retail;

## create tables 

-- Geolocation 
create table geolocation( 
geolocation_zip_code_prefix int not null,  
geolocation_lat text not null,  
geolocation_lng text not null, 
geolocation_city varchar(225) not null,  
geolocation_state varchar(225) not null); 


-- Customers 
create table customers( 
customer_id varchar(225) primary key, 
customer_unique_id varchar(225) not null, 
customer_zip_code_prefix int not null, 
customer_city varchar(225) not null, 
customer_state varchar(225) not null); 

-- Sellers 
create table sellers( 
seller_id varchar(225) primary key, 
seller_zip_code_prefix int not null, 
seller_city varchar(225) not null, 
seller_state varchar(100) not null); 

-- Products 
create table products( 
product_id varchar(225) primary key, 
`product category` varchar(225) null, 
product_name_length text null, 
product_description_length text null, 
product_photos_qty text null, 
product_weight_g text null, 
product_length_cm text null, 
product_height_cm text null, 
product_width_cm text null); 

-- Orders 
create table orders( 
order_id varchar(225) primary key, 
customer_id varchar(225) not null, 
order_status varchar(225) not null, 
order_purchase_timestamp text not null, 
order_approved_at text null, 
order_delivered_carrier_date text null, 
order_delivered_customer_date text null, 
order_estimated_delivery_date text not null, 
foreign key(customer_id) references customers(customer_id)); 

-- Payments 
create table payments( 
order_id varchar(225), 
payment_sequential tinyint not null, 
payment_type varchar(225) not null, 
payment_installments tinyint not null, 
payment_value decimal not null, 
foreign key(order_id) references orders(order_id)); 

-- Order_review 
create table order_review( 
review_id varchar(225) primary key, 
order_id varchar(225), 
review_score tinyint not null, 
review_comment_title text,  
review_creation_date text not null, 
review_answer_timestamp text not null, 
foreign key(order_id) references orders(order_id)); 

-- order_item 
create table order_item( 
order_id varchar(225), 
order_item_id char(20),  
product_id varchar(225), 
seller_id varchar(225), 
shipping_limit_date text not null, 
price text not null,  
freight_value decimal not null, 
foreign key(order_id) references orders(order_id), 
foreign key(product_id) references products(product_id), 
foreign key(seller_id) references sellers(seller_id)); 


use retail; 
## geolocation 
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/geolocation.csv'
INTO TABLE  geolocation 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(geolocation_zip_code_prefix, geolocation_lat ,geolocation_lng, geolocation_city, geolocation_state); 

SHOW VARIABLES LIKE 'secure_file_priv';

 
## customers 
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv' 
INTO  TABLE  customers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state); 
 
## sellers 
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sellers.csv' 
INTO TABLE  sellers 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(seller_id, seller_zip_code_prefix, seller_city, seller_state ); 

## products 
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv' 
INTO TABLE  products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(product_id, `product category`, product_name_length, product_description_length, product_photos_qty, product_weight_g, 
product_length_cm, product_height_cm, product_width_cm); 


## orders 
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv' 
INTO TABLE  orders 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date,  
order_delivered_customer_date, order_estimated_delivery_date); 


## payments 
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv' 
INTO TABLE  payments 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(order_id ,payment_sequential ,payment_type, payment_installments  ,payment_value ); 
 
## Order_review 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_reviews.csv' 
REPLACE INTO TABLE order_review 
CHARACTER SET utf8mb4 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(review_id, order_id, review_score, review_creation_date, review_answer_timestamp); 

## order_item 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv' 
REPLACE 
INTO TABLE order_item 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS 
(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value );
 
select * from order_item;
select * from order_review;
select * from payments;
select * from products;
select * from sellers;
select * from geolocation;
select * from customers;
select * from orders;


## Customer Analysis

-- 1.  Find the total number of unique customers. 
select count(distinct(customer_unique_id)) as total_unique_customers
from customers;  # 96096


-- 2.  Identify the top 5 states with the highest number of customers. 

select customer_state, count(*) as customer_count
from customers
group by customer_state
order by customer_count desc
limit 5;

--    Calculate customer retention rate (customers who placed more than 1 order). 

select
(count(case when order_count > 1 then 1 end) * 100.0 / count(*)) as retention_rate
from (
    select c.customer_unique_id, count(o.order_id) as order_count
    from customers c
    join orders o on c.customer_id = o.customer_id
    group by c.customer_unique_id
) as customer_orders;



--    Find customers who gave the lowest review scores more than twice.  

select 
    c.customer_unique_id,
    count(r.review_id) as lowest_review_count
from customers c
join orders o 
    on c.customer_id = o.customer_id
join order_review r 
    on o.order_id = r.order_id
where r.review_score = 1
group by c.customer_unique_id
having count(r.review_id) > 2
order by lowest_review_count desc;


## Order & Delivery Analysis
 
-- 1. Count the total number of delivered vs. canceled orders. 

select order_status, COUNT(*) as total_orders
from orders
where order_status in ('delivered', 'canceled')
group by order_status;


-- 2. Calculate the average delivery time for delivered orders.  

SELECT 
    ROUND(
        AVG(
            DATEDIFF(
                CAST(order_delivered_customer_date AS DATE),
                CAST(order_purchase_timestamp AS DATE)
            )
        ), 2
    ) AS avg_delivery_days
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- 3. Identify the top 5 cities with the fastest delivery times.

SELECT 
    c.customer_city,
    ROUND(
        AVG(
            DATEDIFF(
                CAST(o.order_delivered_customer_date AS DATE),
                CAST(o.order_purchase_timestamp AS DATE)
            )
        ), 2
    ) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_city
ORDER BY avg_delivery_days ASC
LIMIT 5;


-- 4. Determine the percentage of orders delivered late vs. estimated date. 

SELECT 
    COUNT(
        CASE 
            WHEN CAST(order_delivered_customer_date AS DATE) 
               > CAST(order_estimated_delivery_date AS DATE)
            THEN 1 
        END
    ) * 100.0 / COUNT(*) AS percentage_late_deliveries
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;



-- Find the month with the maximum number of orders.  

SELECT 
    MONTHNAME(CAST(order_purchase_timestamp AS DATE)) AS order_month,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY total_orders DESC
LIMIT 1;


## Product & Category Analysis.

-- 1. Find the top 10 most sold product categories.

select p.`product category`, count(oi.product_id) as total_sold
from order_item oi
left join products p on oi.product_id = p.product_id
group by p.`product category`
order by total_sold desc
limit 10;


-- 2. Calculate average weight, length, height, and width for products in each category.

SELECT 
    `product category`,
    ROUND(AVG(CAST(product_weight_g AS DECIMAL(10,2))), 2) AS avg_weight,
    ROUND(AVG(CAST(product_length_cm AS DECIMAL(10,2))), 2) AS avg_length,
    ROUND(AVG(CAST(product_height_cm AS DECIMAL(10,2))), 2) AS avg_height,
    ROUND(AVG(CAST(product_width_cm AS DECIMAL(10,2))), 2) AS avg_width
FROM products
GROUP BY `product category`;



-- Identify products with the highest freight-to-price ratio.

SELECT 
    product_id,
    ROUND(freight_value / CAST(price AS DECIMAL(10,2)), 2) AS freight_ratio
FROM order_item
WHERE price > 0
ORDER BY freight_ratio DESC
LIMIT 10;



-- 3. Find the top 3 products (by revenue) in each category.  

WITH CategoryRevenue AS (
    SELECT 
        p.`product category`,
        p.product_id,
        SUM(CAST(oi.price AS DECIMAL(10,2))) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY p.`product category`
            ORDER BY SUM(CAST(oi.price AS DECIMAL(10,2))) DESC
        ) AS rnk
    FROM order_item oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.`product category`, p.product_id
)
SELECT *
FROM CategoryRevenue
WHERE rnk <= 3;
 
    

## Payment & Revenue Analysis

-- 1. Find the most common payment type.

select * from payments;
select payment_type, count(*) as payment_type_count
from payments
group by payment_type
order by payment_type_count desc
limit 1;   


-- 2. Calculate revenue by payment type

SELECT payment_type, SUM(payment_value) AS total_revenue 
FROM payments 
GROUP BY payment_type; 


-- 3. Determine the average number of installments for credit card payments. 

select round(avg(payment_installments),2) as avg_credit_card_installments
from payments
where payment_type = 'credit_card';


-- Find the top 5 highest-value orders and their payment details. 

select o.order_id, p.payment_type, p.payment_value, p.payment_installments
from orders o join payments p on o.order_id = p.order_id
order by p.payment_value desc 
limit 5;


## Review Analysis

-- 1. Find the average review score per product category.

select p.`product category`, round(avg(review_score),2) as avg_rev_score
from order_review od
left join order_item oi on od.order_id = oi.order_id
left join products p on oi.product_id = p.product_id
group by p.`product category`;


-- 2. Identify sellers consistently receiving reviews below 3.

SELECT oi.seller_id, COUNT(*) AS bad_reviews
FROM order_review r
JOIN order_item oi ON r.order_id = oi.order_id
WHERE r.review_score < 3
GROUP BY oi.seller_id
HAVING COUNT(*) > 5;


-- 3. Determine if there is a correlation between delivery time and review score. 

SELECT 
    DATEDIFF(
        CAST(o.order_delivered_customer_date AS DATE),
        CAST(o.order_purchase_timestamp AS DATE)
    ) AS delivery_days,
    r.review_score
FROM orders o
JOIN order_review r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;


-- Find the distribution of review scores across states.

SELECT 
    c.customer_state,
    COUNT(CASE WHEN r.review_score = 5 THEN 1 END) AS score_5,
    COUNT(CASE WHEN r.review_score = 4 THEN 1 END) AS score_4,
    COUNT(CASE WHEN r.review_score = 3 THEN 1 END) AS score_3,
    COUNT(CASE WHEN r.review_score = 2 THEN 1 END) AS score_2,
    COUNT(CASE WHEN r.review_score = 1 THEN 1 END) AS score_1
FROM order_review r
JOIN orders o ON r.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY score_5 DESC;


## Seller & Location Analysis

-- 1. Count the number of sellers per state.

select COUNT(*) AS seller_count, seller_state
from sellers
group by seller_state;


-- 2. Find sellers with the highest total sales revenue.

SELECT 
    s.seller_id, 
    s.seller_state, 
    ROUND(SUM(CAST(oi.price AS DECIMAL(10,2))), 2) AS total_revenue,
    COUNT(oi.order_id) AS total_orders_fulfilled
FROM sellers s
JOIN order_item oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. Identify the top 5 cities with the highest seller density.

select seller_city, COUNT(seller_id) as seller_count
from sellers
group by seller_city
order by seller_count desc
limit 5;

-- 4. Match customers and sellers by zip code to find local transactions.    
  
SELECT COUNT(*) AS local_transactions
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_item oi ON o.order_id = oi.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE c.customer_zip_code_prefix = s.seller_zip_code_prefix;


## Advanced Analytics

-- 1. Calculate monthly revenue growth and plot a trend line.

SELECT 
    DATE_FORMAT(CAST(o.order_purchase_timestamp AS DATE), '%Y-%m') AS month,
    SUM(p.payment_value) AS monthly_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;


-- 2. Analyze customer purchase frequency (one-time vs repeat).

SELECT 
    CASE WHEN order_count = 1 THEN 'One-time Customer' ELSE 'Repeat Customer' END AS customer_type,
    COUNT(*) AS total_customers
FROM (
    SELECT customer_unique_id, COUNT(order_id) AS order_count 
    FROM customers c JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY customer_unique_id
) AS frequency_table
GROUP BY customer_type;


-- Find the contribution percentage of each product category to overall revenue. 

SELECT 
    p.`product category`,
    SUM(CAST(oi.price AS DECIMAL(10,2))) AS category_revenue,
    ROUND(
        SUM(CAST(oi.price AS DECIMAL(10,2))) * 100.0 /
        SUM(SUM(CAST(oi.price AS DECIMAL(10,2)))) OVER (), 
        2
    ) AS contribution_pct
FROM order_item oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.`product category`
ORDER BY contribution_pct DESC;



-- Identify the top 3 sellers in each state by revenue.

SELECT *
FROM (
    SELECT 
        s.seller_state,
        s.seller_id,
        SUM(CAST(oi.price AS DECIMAL(10,2))) AS seller_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY s.seller_state
            ORDER BY SUM(CAST(oi.price AS DECIMAL(10,2))) DESC
        ) AS rnk
    FROM sellers s
    JOIN order_item oi ON s.seller_id = oi.seller_id
    GROUP BY s.seller_state, s.seller_id
) ranked_sellers
WHERE rnk <= 3;


