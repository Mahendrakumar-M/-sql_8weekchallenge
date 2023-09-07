create database data_bank;
use data_bank;
CREATE TABLE regions (
  region_id INTEGER,
  region_name VARCHAR(9)
);
CREATE TABLE customer_nodes (
  customer_id INTEGER,
  region_id INTEGER,
  node_id INTEGER,
  start_date DATE,
  end_date DATE
);
CREATE TABLE customer_transactions (
  customer_id INTEGER,
  txn_date DATE,
  txn_type VARCHAR(10),
  txn_amount INTEGER
);

-- How many unique nodes are there on the Data Bank system?
select count(distinct node_id)unique_nodes from customer_nodes;

-- What is the number of nodes per region?
select region_name,count(distinct node_id)unique_nodes from regions join customer_nodes on
regions.region_id=customer_nodes.region_id
group by region_name;

--  How many customers are allocated to each region?
select region_id, count(distinct customer_id)no_of_cus from customer_nodes
group by region_id order by region_id;

--  How many days on average are customers reallocated to a different node?
with node_days as(
select customer_id,node_id,end_date - start_date as no_days
from customer_nodes WHERE end_date != '9999-12-31'
group by customer_id,node_id, start_date, end_date
) ,total_days as(
select customer_id,node_id,sum(no_days)total_no_days from node_days 
group by customer_id,node_id)
select avg(total_no_days)avg_days from total_days;

-- customer_transactions
-- What is the unique count and total amount for each transaction type?
select txn_type,count(customer_id)total_customers,sum(txn_amount)total_amount
from customer_transactions group by txn_type;

-- What is the average total historical deposit counts and amounts for all customers?
with deposit as(
select customer_id,count(customer_id)count_cus,avg(txn_amount)avg_amnt
from customer_transactions where txn_type= 'deposit'
group by customer_id)
select round(avg(count_cus)),round(avg(avg_amnt))from deposit;

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with monthly as (select customer_id,month(txn_date)mnth,
sum(case when txn_type='deposit' then 0 else 1 end) deposit_count,
sum(case when txn_type='purchase' then 0 else 1 end) purchase_count,
sum(case when txn_type='withdrawal' then 1 else 0 end) withdrawal_count
from customer_transactions group by customer_id,mnth)
select count(customer_id)count,mnth from monthly
where deposit_count>1 and purchase_count>1 or withdrawal_count>1
group by mnth order by mnth; 

