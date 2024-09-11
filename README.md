# Case Study #1 - Danny's Diner


## Project Overview

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

📂 Dataset
Danny has shared with you 3 key datasets for this case study:

- Sales Data: The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.

- Menu: The menu table maps the product_id to the actual product_name and price of each menu item.

- Members: The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.

## 🧙‍♂️ Case Study Questions
           
           1. What is the total amount each customer spent at the restaurant?
           2. How many days has each customer visited the restaurant?
           3. What was the first item from the menu purchased by each customer?
           4. What is the most purchased item on the menu and how many times was it purchased by all customers?
           5. Which item was the most popular for each customer?
           6. Which item was purchased first by the customer after they became a member?
           7. Which item was purchased just before the customer became a member?
           8. What is the total items and amount spent for each member before they became a member?
           9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
          10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

## 🚀 Solutions

## Q1. What is the total amount each customer spent at the restaurant?

```Sql
SELECT customer_id,SUM(price) AS Total_spent
FROM sales S JOIN menu M ON S.product_id=m.product_id;
GROUP BY customer_id;
```

## Q2. How many days has each customer visited the restaurant?

```Sql
SELECT customer_id,COUNT(DISTINCT order_date) AS Days FROM sales
GROUP BY customer_id;
```

## Q3. What was the first item from the menu purchased by each customer?

```Sql
WITH CTE1 AS (SELECT S.*,M.product_name,
RANK() OVER(partition by customer_id ORDER BY order_date) AS rnk 
FROM sales S JOIN menu M ON S.product_id=M.product_id
ORDER BY customer_id)

SELECT * FROM CTE1 WHERE rnk=1;
```

## Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```Sql
SELECT M.product_name,COUNT(*) AS Purch
FROM sales S JOIN menu M ON S.product_id=M.product_id
GROUP BY M.product_name;
```

## Q5. Which item was most popular for each customer?

```Sql
WITH CTE1 AS (SELECT S.customer_id,product_name,COUNT(*) As times
FROM sales S
JOIN menu MD ON MD.product_id=S.product_id GROUP BY S.customer_id,product_name ORDER BY times DESC)

SELECT *,RANK() OVER(partition by customer_id ORDER BY times DESC) AS rnk  FROM CTE1;
```

## Q6. Which item was purchased first by the customer after they become a member?

```Sql
WITH CTE1 AS (SELECT S.customer_id,Product_name,RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS rnk FROM members M JOIN sales S ON M.customer_id=S.customer_id
JOIN menu MS ON MS.product_id=S.product_id
WHERE order_date>=join_date)

SELECT * FROM CTE1 WHERE rnk=1;
```

## Q7. Which item was purchased just before the customer became a member?

```Sql
WITH CTE9 AS (SELECT S.customer_id,Product_name,RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS rnk FROM members M JOIN sales S ON M.customer_id=S.customer_id
JOIN menu MS ON MS.product_id=S.product_id
WHERE order_date<join_date)

SELECT * FROM CTE9 WHERE rnk=1;
```

## Q8. What is the total items and amount spent for each member before they became a member?

```Sql
SELECT S.customer_id,COUNT(DISTINCT product_name) As Pd_count,SUM(price) AS Amount FROM members M JOIN sales S ON M.customer_id=S.customer_id
JOIN menu MS ON MS.product_id=S.product_id
WHERE order_date<join_date GROUP BY S.customer_id;
```

## Q9. If each $1 spent equals to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```Sql
WITH CTE22 AS (SELECT S.customer_id,M.product_name,price,
CASE WHEN product_name="sushi" then 2*price else price END AS new_price FROM menu M JOIN sales S ON M.product_id=S.product_id)

SELECT customer_id,SUM(new_price)*10 AS prc FROM CTE22
group by customer_id;
```

# Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi how many points do customer A and B have at the end of January?

```Sql
WITH CTE11 AS (SELECT S.customer_id,S.order_date,ME.product_name,ME.price, CASE WHEN product_name="Sushi" then 2*price
WHEN order_date BETWEEN join_date AND (join_date + interval 6 day) then 2*ME.price
else ME.price END AS New_price
FROM sales S JOIN members M ON S.customer_id=M.customer_id
JOIN menu ME ON ME.product_id=S.product_id
WHERE S.order_date<"2021-01-31")

SELECT customer_id,SUM(New_price)*10 from CTE11
GROUP BY customer_id;
```





