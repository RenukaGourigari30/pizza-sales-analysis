show databases;
use pizzahut;
create  table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create  table orders_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));
select * from pizzahut;

# calculate the total revenue generated  from pizza sales. 
# total revenue = quantity* price

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;
    # identify the highest_priced pizza.
 SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
  
  # identify the most common pizza  sized order
#select quantity ,count(order_details_id)
 #from orders_details group by quantity; in these we identify the most quantity order details
 SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;
 
 # list the top 5 most ordered  pizza types along with their quantites
 SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

# join the necessary tables  to find the total quantity of each pizza category ordered
SELECT category,

    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;
# determine the distribution of orders by hour of the day

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

# join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from pizza_types
group by category;

# group the orders by date and calculate the average no .of pizzas ordered per day
select round(avg(quantity),0) from 
(SELECT 
    orders.order_date,
    SUM(orders_details.quantity) As quantity
FROM
    orders
        JOIN
    orders_details ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) as order_quantity;
# determine the top 3 most ordered pizza types based on revenue
select  pizza_types.name,
sum(orders_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
 group  by pizza_types.name order by revenue desc
 limit 3;
# calculate the percentage contribution of each pizza type of total revenue
select pizza_types.category,
round(sum(orders_details.quantity*pizzas.price) /(SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN
        pizzas on pizzas.pizza_id = orders_details.pizza_id)*100,2) as revenue
   from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;
# analyse the cumulative revenue generated over time. cumulative means how revenue is increased day by day
select  order_date,
sum(revenue)over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(orders_details.quantity*pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date)  as sales;
# determine the top 3 most orderd pizza types based  on revenue for each pizza category
select name,revenue from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by  pizza_types.category,pizza_types.name)  as a ) as b
where rn<=3;






