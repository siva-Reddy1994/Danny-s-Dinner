/* What is the total amount each customer spent at the restaurant*/

SELECT customer_id,SUM(price) AS Total_spent FROM sales S JOIN menu M ON S.product_id=m.product_id
GROUP BY customer_id;

/* How many days has each customer visited the restaurant*/

SELECT customer_id,COUNT(DISTINCT order_date) AS Days FROM sales
GROUP BY customer_id;

/* What was the first item from the menu purchased by each customer*/

WITH CTE1 AS (SELECT S.*,M.product_name,
RANK() OVER(partition by customer_id ORDER BY order_date) AS rnk 
FROM sales S JOIN menu M ON S.product_id=M.product_id
ORDER BY customer_id)

SELECT * FROM CTE1 WHERE rnk=1;

/* What is the most purchased item on the menu and how many times was it purchased by all customers*/

SELECT M.product_name,COUNT(*) AS Purch
FROM sales S JOIN menu M ON S.product_id=M.product_id
GROUP BY M.product_name;

/* Which item was most popular for each customer*/

WITH CTE1 AS (SELECT S.customer_id,product_name,COUNT(*) As times
FROM sales S
JOIN menu MD ON MD.product_id=S.product_id GROUP BY S.customer_id,product_name ORDER BY times DESC)

SELECT *,RANK() OVER(partition by customer_id ORDER BY times DESC) AS rnk  FROM CTE1;

/* Which item was purchased first by the customer after they become a member*/

WITH CTE1 AS (SELECT S.customer_id,Product_name,RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS rnk FROM members M JOIN sales S ON M.customer_id=S.customer_id
JOIN menu MS ON MS.product_id=S.product_id
WHERE order_date>=join_date)

SELECT * FROM CTE1 WHERE rnk=1;


/* What is the total item and amount spent for each member before they became a member*/


WITH CTE100 AS (SELECT S.customer_id,Product_name,price,RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) AS rnk FROM members M JOIN sales S ON M.customer_id=S.customer_id
JOIN menu MS ON MS.product_id=S.product_id
WHERE order_date<join_date)

SELECT customer_id,COUNT(DISTINCT product_name) AS PN,SUM(price) AS prc FROM CTE100
group by customer_id;

/* If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each
customer have*/

WITH CTE55 AS (SELECT S.customer_id,product_name,price,
CASE WHEN product_name="Sushi" THEN 2*price ELSE Price END AS n_price FROM sales S LEFT JOIN menu M ON S.product_id=M.product_id)

SELECT customer_id,SUM(n_price)*10 AS Over_all FROM CTE55
GROUP BY customer_id;


/* In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
not just sushi - how many points do customer A and B have at the end of January?*/

WITH CTE111 AS (SELECT S.customer_id,product_name,price,
CASE WHEN product_name="Sushi" then 2*price
     WHEN order_date between join_date AND (join_date + Interval 6 day) 
THEN 2*price ELSE Price END AS n_price 
FROM sales S JOIN menu M ON S.product_id=M.product_id
JOIN members MS ON S.customer_id=MS.customer_id WHERE S.order_date<"2021-01-31")

SELECT customer_id,SUM(n_price)*10 AS T_P FROM CTE111
GROUP BY customer_id;





