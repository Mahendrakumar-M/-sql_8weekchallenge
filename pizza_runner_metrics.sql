create database pizza_runner;
use pizza_runner;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, NULL, '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, NULL, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');



CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, null, null, null, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', null),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', null),
  (9, 2, null, null, null, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', null);


CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- pizza metrics
   -- How many pizzas were ordered?
   select count(*)as total_count from customer_orders ;
   
   
   -- How many unique customer orders were made?
   select count(distinct order_id)as unique_orders from customer_orders;
   
   -- How many successful orders were delivered by each runner?
   select runner_id,count(order_id) from runner_orders
   where distance !=0 group by runner_id;
   
   -- How many of each type of pizza was delivered?
   select p.pizza_name,count(c.pizza_id)as no_of_pizza_delivered from customer_orders as c
   join runner_orders as r on c.order_id = r.order_id
   join pizza_names as p on c.pizza_id = p.pizza_id
   where distance!=0 group by pizza_name;
   
   -- How many Vegetarian and Meatlovers were ordered by each customer?
    select c.customer_id,p.pizza_name,count(c.pizza_id)as no_of_pizza_ordered from customer_orders as c
   join runner_orders as r on c.order_id = r.order_id
   join pizza_names as p on c.pizza_id = p.pizza_id
   where distance!=0 group by customer_id,pizza_name;
   
   -- What was the maximum number of pizzas delivered in a single order?
   with pizza_count as
   (
   select c.order_id,count(c.pizza_id) as pizza_per_order from customer_orders as c join runner_orders as r
   on c.order_id = r.order_id
   where distance!=0 group by order_id
   )
   select max(pizza_per_order) max_order from pizza_count ;
   
   -- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
   select c.customer_id,
   sum(case when c.exclusions <> '' or c.extras <>''then 1 else 0 end)as customized,
   sum(case when c.exclusions = '' and c.extras =''then 1 else 0 end)as not_customized
   from customer_orders as c join runner_orders as r on c.order_id=r.order_id
   where r.distance !=0
   group by customer_id order by customer_id;
   
   -- How many pizzas were delivered that had both exclusions and extras?
   select
   sum(case when c.exclusions is not null and c.extras is not null then 1 else 0 end) as pizza_w_exc_ext
   from customer_orders as c join runner_orders as r on c.order_id=r.order_id
   where r.distance !=0 and exclusions <> '' and extras <>'';
   
   --  What was the total volume of pizzas ordered for each hour of the day?
   select hour(order_time),count(order_id) as order_by_hour
   from customer_orders group by hour(order_time);
   
  -- What was the volume of orders for each day of the week?
  SELECT 
  DATE_FORMAT(DATE_ADD(order_time, INTERVAL 2 DAY), '%W') AS day_of_week,
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY DATE_FORMAT(DATE_ADD(order_time, INTERVAL 2 DAY), '%W');
