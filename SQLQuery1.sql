USE pizza_sales;

--QUESTION: 1   Retrieve the total number of orders placed.

SELECT COUNT(order_id) as total_number_of_order
FROM orders;

--QUESTION: 2    Calculate the total revenue generated from pizza sales.

SELECT ROUND(SUM(quantity * price),2) as total_revenue
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id;

--QUESTION: 3  Identify the highest-priced pizza.

SELECT TOP 1 pizza_types.name, pizzas.price--, MAX(price) as highest_price_pizza 
FROM pizzas
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC;

--QUESTON: 4  Identify the most common pizza size ordered.

SELECT pizzas.size, COUNT(order_details.order_details_id)as order_count
FROM pizzas
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC

 --QUESTION 5:  List the top 5 most ordered pizza types along with their quantities.

 SELECT TOP 5 pizza_types.name , SUM(order_details.quantity) as quantity_of_order
 FROM pizzas
 JOIN order_details
 ON order_details.pizza_id = pizzas.pizza_id
 JOIN pizza_types
 ON pizzas.pizza_type_id = pizza_types.pizza_type_id
 GROUP BY pizza_types.name
 ORDER BY quantity_of_order DESC;

 --QUESTION 6:    Join the necessary tables to find the total quantity of each pizza category ordered.

 SELECT  pizza_types.category , SUM(order_details.quantity) as quantity_of_order
 FROM pizzas
 JOIN order_details
 ON order_details.pizza_id = pizzas.pizza_id
 JOIN pizza_types
 ON pizzas.pizza_type_id = pizza_types.pizza_type_id
 GROUP BY pizza_types.category
 ORDER BY quantity_of_order DESC;

 --QUESTION 7:  Determine the distribution of orders by hour of the day.

 SELECT HOUR(time) AS Hour_of_the_day, COUNT(order_id)  AS order_count
 FROM orders
 GROUP BY DAY(time);

 --QUESTION 8: Join relevant tables to find the category-wise distribution of pizzas.

 SELECT category, COUNT(pizza_type_id) as total_number
 FROM pizza_types
GROUP BY category;

--QUESTION 9:  Group the orders by date and calculate the average number of pizzas ordered per day.

	WITH CTE AS (
				SELECT orders.date, ROUND(sum(order_details.quantity),0) as sum_of_quantity
				FROM orders
				JOIN order_details
				ON orders.order_id = order_details.order_id
				GROUP BY orders.date
				)
				SELECT ROUND(AVG(sum_of_quantity),0)  avg_of_order_per_day
				FROM CTE;

--QUESTION 10: Determine the top 3 most ordered pizza types based on revenue.

SELECT TOP 3 name, SUM(quantity * price) as Revenue
FROM order_details
JOIN pizzas 
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY name
ORDER BY SUM(quantity * price) DESC;

--QUESTION 11:  Calculate the percentage contribution of each pizza type to total revenue.

SELECT category, ROUND(SUM(quantity * price) /  (SELECT ROUND(SUM(quantity * price),2) as total_revenue
											FROM order_details
											JOIN pizzas
											ON order_details.pizza_id = pizzas.pizza_id)*100,2) as Revenue
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY category
ORDER BY Revenue;

--QUESTION 12: Analyze the cumulative revenue generated over time.

WITH CTE AS (
			SELECT date, SUM(price * quantity) as total_revenue
			FROM orders
			JOIN order_details
			ON orders.order_id = order_details.order_id
			JOIN pizzas
			ON pizzas.pizza_id = order_details.pizza_id
			GROUP BY date
			)
			SELECT date, total_revenue, SUM(total_revenue) OVER (ORDER BY date) AS cum_revenue
			FROM CTE;

--QUESTION 13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, Revenue, category
FROM
	(
	 SELECT category, name, Revenue, RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS RN
	 FROM 
		 (
			SELECT category, name, SUM(quantity * price) as Revenue
			FROM order_details
			JOIN pizzas
			ON order_details.pizza_id = pizzas.pizza_id
			JOIN pizza_types
		    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
			GROUP BY category, name
		 ) AS a
	) AS b
WHERE RN <= 3;




SELECT * FROM order_details
SELECT * FROM orders
SELECT * FROM pizza_types
SELECT * FROM pizzas