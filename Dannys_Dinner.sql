create database danny_dinner;
use danny_dinner;
CREATE TABLE sales (
  customer_id VARCHAR(255),
  order_date DATE,
  product_id INTEGER
);
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09'),
  ('c', '2021-01-01');
  
  -- 1. What is the total amount each customer spent at the restaurant?
  select sales.customer_id,sum(menu.price)as total_amount_spend from sales 
  inner join menu on sales.product_id = menu.product_id
  group by sales.customer_id;
  
  -- 2. How many days has each customer visited the restaurant?
  select sales.customer_id,count(distinct sales.order_date) as no_days_visited from sales
  group by sales.customer_id;
  
  -- 3. What was the first item from the menu purchased by each customer?
with first_item as (
select sales.customer_id,sales.order_date,menu.product_name,
rank() over( partition by sales.customer_id order by sales.order_date)as rankk
from sales inner join menu on sales.product_id = menu.product_id)
select  customer_id,product_name from first_item where rankk=1 group by customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select menu.product_name,count(sales.product_id)as most_purchased from sales
 inner join menu on sales.product_id=menu.product_id
 group by menu.product_name order by most_purchased desc
 limit 1;
 
 -- 5. Which item was the most popular for each customer?
 WITH most_fav AS (
  SELECT 
    sales.customer_id, 
    menu.product_name, 
    COUNT(menu.product_id) AS order_count,
    DENSE_RANK() OVER (
      PARTITION BY sales.customer_id 
      ORDER BY COUNT(sales.customer_id) DESC) AS rankk
  FROM menu
  INNER JOIN sales
    ON menu.product_id = sales.product_id
  GROUP BY sales.customer_id, menu.product_name
)

SELECT 
  customer_id, 
  product_name, 
  order_count
FROM most_fav 
WHERE rankk = 1;

-- 6. Which item was purchased first by the customer after they became a member?
with as_mem as(select members.customer_id,sales.product_id,row_number()over(partition by
members.customer_id order by sales.order_date)as row_num
from members inner join sales on
members.customer_id = sales.customer_id
and sales.order_date > members.join_date
)
select customer_id,product_name from as_mem
inner join menu on as_mem.product_id=menu.product_id
where row_num=1 order by customer_id asc;

-- 7. Which item was purchased just before the customer became a member?
with bef_mem as(select members.customer_id,sales.product_id,row_number()over(partition by
members.customer_id order by sales.order_date)as row_num
from members inner join sales on
members.customer_id = sales.customer_id
and sales.order_date < members.join_date
)
select customer_id,product_name from bef_mem
inner join menu on bef_mem.product_id=menu.product_id
where row_num=1 order by customer_id asc;

-- 8. What is the total items and amount spent for each member before they became a member?
select sales.customer_id,count(sales.product_id)as total_items,sum(menu.price)as total_spend
from sales inner join members on sales.customer_id =members.customer_id
and sales.order_date < members.join_date
inner join menu on sales.product_id=menu.product_id
group by sales.customer_id
order by sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as(
select menu.product_id,
case when product_id=1 then price*20 
else price*10 end as points from menu
)
SELECT 
  sales.customer_id, 
  SUM(points.points) AS total_points
FROM sales
INNER JOIN points
  ON sales.product_id = points.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates_cte AS (
  SELECT 
    customer_id, 
    join_date, 
    join_date + INTERVAL 6 DAY AS valid_date, 
    DATE_FORMAT('2021-01-31', '%Y-%m-01') + INTERVAL 1 MONTH - INTERVAL 1 DAY AS last_date
  FROM members
)

SELECT 
  s.customer_id, 
  SUM(CASE
    WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
    WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
    ELSE 10 * m.price END) AS points
FROM sales s
INNER JOIN dates_cte d
  ON s.customer_id = d.customer_id
  AND d.join_date <= s.order_date
  AND s.order_date <= d.last_date
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;
