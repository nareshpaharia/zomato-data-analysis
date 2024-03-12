CREATE DATABASE zomato;

SELECT * FROM zomato.users;
SELECT * FROM zomato.restraurants;
SELECT * FROM zomato.orders_details;
SELECT * FROM zomato.orders;
SELECT * FROM zomato.menu;
SELECT * FROM zomato.food;
SELECT * FROM zomato.delivery_partner;

-- ZOMATO CASE STUDY

/* 1. Find customers who have never ordered  */

SELECT name FROM users 
WHERE user_id 
NOT IN (SELECT user_id FROM  zomato.orders);


/* 2. Average Price/dish */

SELECT f.f_name,m.f_id,AVG(price) AS avg_price 
FROM menu AS m 
JOIN zomato.food AS f ON f.f_id=m.f_id
GROUP BY f.f_name,m.f_id;


/* 3. Find top restraurant in term of numbers of orders for a June month */

SELECT *,monthname(date) AS month 
FROM zomato.orders;

SELECT *,monthname(date) AS month 
FROM zomato.orders
WHERE monthname(date)='June';

SELECT r.r_name,count(*) AS month 
FROM zomato.orders o 
JOIN restraurants AS r ON o.r_id=r.r_id
WHERE monthname(date)='June'
GROUP BY r.r_name
ORDER BY month DESC
LIMIT 3;


/* 4. Restraurant with monthly sales > 500 for */

SELECT r_id,sum(amount) AS 'revenue', monthname(date) AS month 
FROM zomato.orders
WHERE monthname(date)='June'
GROUP BY r_id,monthname(date);

SELECT r_id,sum(amount) AS 'revenue', monthname(date) AS month 
FROM zomato.orders
WHERE monthname(date)='June'
GROUP BY r_id,monthname(date)
HAVING revenue>500;

SELECT r_name,sum(amount) AS 'revenue', monthname(date) AS month 
FROM zomato.orders AS o JOIN restraurants AS r ON o.r_id=r.r_id
WHERE monthname(date)='June'
GROUP BY r_name,monthname(date)
HAVING revenue>500;



/* 5. Show all orders with all order details for a 
      particular customer(Ankit) in a particular date range*/
  
SELECT * 
FROM zomato.users;  
  
SELECT * 
FROM zomato.orders
WHERE user_id =(SELECT user_id from zomato.users WHERE name='Ankit');

SELECT * 
FROM zomato.orders
WHERE user_id =(SELECT user_id FROM zomato.users WHERE name='Ankit')
AND (date >'2022-06-10'AND date <'2022-07-10');


SELECT o.order_id,r.r_name 
FROM zomato.orders AS o join zomato.restraurants AS r ON o.r_id=r.r_id
WHERE user_id =(SELECT user_id FROM zomato.users WHERE name='Ankit')
AND (date >'2022-06-10'AND date <'2022-07-10');


SELECT o.order_id,r.r_name,f.f_name
FROM zomato.orders AS o 
JOIN zomato.restraurants AS r ON o.r_id=r.r_id
JOIN orders_details AS od ON o.order_id=od.order_id
JOIN zomato.food AS f on f.f_id=od.f_id
WHERE user_id =(SELECT user_id FROM zomato.users WHERE name='Vartika')
AND (date >'2022-06-10'AND date <'2022-07-10');


      
/* 6. Find restraurants with max reaptead customer*/

SELECT * 
FROM zomato.orders;

SELECT user_id,r_id,count(*) AS 'Visit'
FROM zomato.orders
GROUP BY user_id,r_id;

SELECT user_id,r_id,count(*) AS 'Visit'
FROM zomato.orders
GROUP BY user_id,r_id
HAVING Visit>1;

SELECT r_name,count(*) AS loyal_customer
FROM (
     SELECT r_id,user_id,count(*) AS 'Visit'
     FROM zomato.orders
     GROUP BY r_id,user_id
     HAVING Visit>1
) AS t 
JOIN restraurants AS r ON r.r_id=t.r_id
GROUP BY r_name
ORDER BY  loyal_customer DESC
LIMIT 1;


/* 7. Month over month revenue of Zomato*/

SELECT month,((revenue-prev)/prev)*100 revnue FROM (
WITH sales AS 
(SELECT monthname(date) as month,sum(amount) AS revenue
FROM zomato.orders
GROUP BY month)

SELECT month,revenue,LAG(revenue,1) OVER(ORDER BY  revenue) AS 'prev'FROM sales) AS t;

/*SELECT * FROM zomato.users;
SELECT * FROM zomato.restraurants;
SELECT * FROM zomato.orders_details;
SELECT * FROM zomato.orders;
SELECT * FROM zomato.menu;
SELECT * FROM zomato.food;
SELECT * FROM zomato.delivery_partner;*/

/* 8. Customer favorite food */

WITH temp AS 
(       SELECT o.user_id,od.f_id ,count(*) AS frequency
	    FROM zomato.orders AS o 
        JOIN zomato.orders_details AS od ON o.order_id=od.order_id
        GROUP BY o.user_id,od.f_id
)
SELECT u.name,f.f_name,frequency FROM 
     temp AS t1 
     JOIN users AS u ON u.user_id=t1.user_id
     JOIN food AS f ON f.f_id=t1.f_id
WHERE t1.frequency =(SELECT max(frequency) 
FROM temp AS t2 
WHERE t2.user_id=t1.user_id);

-- -----------------------


/*9.  Percentage of total refers to the percantage or proportion of a specific value in
relation to the total value.It is a commonly use matric to represent the relative importance
or contribution of a particulat value within a large group or
population. */

SELECT * FROM zomato.users;
SELECT * FROM zomato.restraurants;
SELECT * FROM zomato.orders_details;
SELECT * FROM zomato.orders;
SELECT * FROM zomato.menu;
SELECT * FROM zomato.food;

SELECT f_name,(total_value/sum(total_value) over())*100 AS percentage_of_total
FROM(
SELECT f_id,sum(amount) AS total_value
FROM zomato.orders o JOIN zomato.orders_details  od ON o.order_id=od.order_id
WHERE r_id=1
GROUP BY f_id)AS t
JOIN zomato.food AS f ON t.f_id=f.f_id
ORDER BY total_value/SUM(total_value) OVER() DESC ;

SELECT f_name ,(total_value/SUM(total_value) OVER()*100) AS percentage_of_total
FROM 
(SELECT f_id,sum(amount) AS total_value
FROM zomato.orders AS o JOIN zomato.orders_details AS od ON o.order_id=od.order_id
WHERE r_id=1
GROUP BY f_id) AS t 
JOIN zomato.food AS f ON t.f_id=f.f_id
ORDER BY (total_value/sum(total_value) OVER()*100) DESC;


SELECT f_name,type,(total_value/sum(total_value) OVER()*100 ) AS percantage_of_total
FROM
(SELECT f_id,sum(amount) AS total_value
FROM zomato.orders AS o JOIN zomato.orders_details od ON o.order_id=od.order_id
WHERE r_id=1
GROUP BY f_id) AS t
JOIN zomato.food AS f ON t.f_id=f.f_id;







