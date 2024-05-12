/* --------------------
Case Study Questions
--------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	S.customer_id,
	SUM(M.price) AS AMOUNT_SPENT_PER_CUSTOMER
FROM
	dannys_diner.sales AS S
LEFT JOIN 
	dannys_diner.menu as M
USING(product_id)
GROUP BY 
	S.customer_id
ORDER BY 
	S.customer_id;
	
-- Results:
customer_id	| amount_spent_per_customer|
------------+--------------------------+
A	        | 76                       |
B	        | 74 					   |
C	        | 36					   |

-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
	COUNT(DISTINCT order_date) AS NUMBER_OF_DAYS
FROM
	dannys_diner.sales
GROUP BY 
	customer_id
ORDER BY 
	customer_id;

-- Results:

customer_id |number_of_days|
------------+--------------+
A			| 4			   |
B			| 6			   |
C			| 2            |
	
-- 3. What was the first item from the menu purchased by each customer?
SELECT 
	DISTINCT customer_id,
	product_name,
	RANK
FROM(
	SELECT
		S.customer_id,
		S.order_date,
		M.product_name,
	RANK() OVER(PARTITION BY S.customer_id ORDER BY S.order_date) AS RANK
	FROM
		dannys_diner.sales AS S
	LEFT JOIN 
		dannys_diner.menu as M
	USING(product_id)
)AS SUB
WHERE RANK = 1;

-- Results:

customer_id | product_name | rank|
------------+--------------+-----+
A			| curry	       | 1   |      
A			| sushi		   | 1   |
B			| curry		   | 1   |
C			| ramen		   | 1   |

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	M.product_name,
	COUNT(*) AS TOTAL_NUMBER_OF_PURCHASED_ITEMS
FROM
	dannys_diner.sales AS S
LEFT JOIN 
	dannys_diner.menu as M
USING(product_id)
GROUP BY
	M.product_name
LIMIT 1;

-- Results:

product_name| total_number_of_purchased_items|
------------+--------------------------------+
ramen	    | 8                              |

-- 5. Which item was the most popular for each customer?
SELECT
	customer_id,
	product_name
FROM (
	SELECT
		S.customer_id,
		M.product_name,
		COUNT(*) AS order_count,
		RANK() OVER(PARTITION BY S.customer_id ORDER BY COUNT(S.customer_id) DESC) AS COUNT
	FROM
		dannys_diner.sales AS S
	LEFT JOIN 
		dannys_diner.menu as M
	USING(product_id)
	GROUP BY
		S.customer_id, M.product_name
	ORDER BY
		S.customer_id
) AS SUB
WHERE COUNT = 1;

-- Results:

customer_id| product_name|
-----------+-------------+
A		   | ramen       |
B		   | sushi       |
B	       | curry       |
B	       | ramen       |   
C	       | ramen       |

-- 6. Which item was purchased first by the customer after they became a member?
SELECT
	customer_id,
	product_name,
	order_date
FROM (
		SELECT
		S.customer_id,
		M.product_name,
		S.order_date,
		ME.join_date,
		RANK() OVER(PARTITION BY S.customer_id ORDER BY S.order_date) AS RANK
	FROM
		dannys_diner.sales AS S
	INNER JOIN 
			dannys_diner.menu as M
	ON
		S.product_id = M.product_id
	INNER JOIN
		dannys_diner.members AS ME
	ON 
		S.customer_id = ME.customer_id
	WHERE 
		S.order_date >= ME.join_date
) AS SUB
WHERE RANK =1;

-- Results:

customer_id| product_name| order_date|
-----------+-------------+-----------+
A		   | curry	     | 2021-01-07|
B	       | sushi       | 2021-01-11|

-- 7. Which item was purchased just before the customer became a member?
SELECT
	customer_id,
	product_name,
	order_date
FROM (
		SELECT
		S.customer_id,
		M.product_name,
		S.order_date,
		ME.join_date,
		RANK() OVER(PARTITION BY S.customer_id ORDER BY S.order_date DESC) AS RANK
	FROM
		dannys_diner.sales AS S
	INNER JOIN 
			dannys_diner.menu as M
	ON
		S.product_id = M.product_id
	INNER JOIN
		dannys_diner.members AS ME
	ON 
		S.customer_id = ME.customer_id
	WHERE 
		S.order_date < ME.join_date
) AS SUB
WHERE RANK = 1;

-- Results:

customer_id| product_name| order_date|
-----------+-------------+-----------+
A		   | sushi		 | 2021-01-01|
A		   | curry		 | 2021-01-01|
B		   | sushi		 | 2021-01-04|


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT
		S.customer_id,
		COUNT(*) AS TOTAL_ITEMS,
		SUM(M.price) AS TOTAL_AMOUNT
FROM
	dannys_diner.sales AS S
INNER JOIN 
	dannys_diner.menu as M
ON
	S.product_id = M.product_id
INNER JOIN
	dannys_diner.members AS ME
ON 
	S.customer_id = ME.customer_id
WHERE 
	S.order_date < ME.join_date
GROUP BY 
	S.customer_id
ORDER BY 
	S.customer_id;
	
-- Results:

customer_id| total_items| total_amount|
-----------+------------+-------------+
A		   | 2	        |  25         |
B		   | 3	        |  40         |

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	S.customer_id,
	SUM(CASE WHEN M.product_name = 'sushi' THEN M.price*10*2
			 ELSE M.price*10 END) AS POINTS
FROM 
	dannys_diner.sales AS S
LEFT JOIN 
	dannys_diner.menu as M
USING
	(product_id)
GROUP BY
	S.customer_id
ORDER BY 
	S.customer_id;
	
-- Results:

customer_id| points|
-----------+-------+
A		   | 860   |
B		   | 940   |
C		   | 360   |

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT
	S.customer_id,
	SUM(CASE WHEN M.product_name = 'sushi' 
	OR S.order_date BETWEEN CAST(ME.join_date AS TIMESTAMP) 
	AND CAST(ME.join_date AS TIMESTAMP) + INTERVAL '6 DAY' THEN M.price*10*2
	ELSE M.price*10 END) AS POINTS
FROM
	dannys_diner.sales AS S
INNER JOIN 
	dannys_diner.menu as M 
ON
	S.product_id = M.product_id
INNER JOIN
	dannys_diner.members AS ME
ON 
	S.customer_id = ME.customer_id	
WHERE 
	S.customer_id IN ('A', 'B') 
	AND EXTRACT(MONTH FROM S.order_date) = 1
GROUP BY
	S.customer_id;

-- Results:

customer_id| points|
-----------+-------+
A		   | 1370  |
B		   | 820   |

--join ALL THINGS
SELECT
	S.customer_id,
	S.order_date, 
	M.product_name,
	M.price,
	CASE WHEN S.order_date >= ME.join_date THEN 'Y'
	ELSE 'N' END AS MEMBER
FROM
	dannys_diner.sales AS S
LEFT JOIN 
	dannys_diner.menu as M
ON
	S.product_id = M.product_id
LEFT JOIN
	dannys_diner.members AS ME
ON 
	S.customer_id = ME.customer_id
ORDER BY
	S.customer_id, S.order_date, M.price;
	
-- Results:

customer_id| order_date	| product_name | price | member |
-----------+------------+--------------+-------+--------+
A		   | 2021-01-01	| sushi	       | 10    | N      |
A		   | 2021-01-01	| curry	       | 15	   | N      |      
A		   | 2021-01-07	| curry	       | 15    | Y      |
A		   | 2021-01-10	| ramen	       | 12	   | Y      |
A		   | 2021-01-11	| ramen	       | 12	   | Y      |
A	       | 2021-01-11	| ramen	       | 12	   | Y      |
B	       | 2021-01-01	| curry	       | 15	   | N      |
B	       | 2021-01-02	| curry	       | 15	   | N      |
B	       | 2021-01-04	| sushi	       | 10	   | N      |
B	       | 2021-01-11	| sushi	       | 10	   | Y      |
B	       | 2021-01-16	| ramen	       | 12	   | Y      |
B	       | 2021-02-01	| ramen	       | 12	   | Y      |
C	       | 2021-01-01	| ramen	       | 12	   | N      |
C	       | 2021-01-01	| ramen	       | 12	   | N      |
C	       | 2021-01-07	| ramen	       | 12	   | N      |

--ranking all the things

WITH customer_ranking AS (
	SELECT
		S.customer_id,
		S.order_date, 
		M.product_name,
		M.price,
		CASE WHEN S.order_date >= ME.join_date THEN 'Y'
		ELSE 'N' END AS MEMBER
	FROM
		dannys_diner.sales AS S
	LEFT JOIN 
		dannys_diner.menu as M
	ON
		S.product_id = M.product_id
	LEFT JOIN
		dannys_diner.members AS ME
	ON 
		S.customer_id = ME.customer_id
	ORDER BY
		S.customer_id, S.order_date, M.price DESC
	)
	
SELECT 
	*,
	CASE WHEN member = 'N' THEN NULL
	WHEN member = 'Y' THEN
	RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date) END AS RANKING
FROM customer_ranking;

-- Results:

customer_id| order_date | product_name | price | member | ranking|
-----------+------------+--------------+-------+--------+--------+
A          | 2021-01-01	| curry        | 15	   | N	    |        |
A	       | 2021-01-01	| sushi	       | 10	   | N	    |        |
A	       | 2021-01-07	| curry	       | 15	   | Y	    | 1      |
A	       | 2021-01-10	| ramen        | 12	   | Y	    | 2      |
A	       | 2021-01-11	| ramen	       | 12	   | Y	    | 3      |
A		   | 2021-01-11	| ramen	       | 12	   | Y	    | 3      |
B          | 2021-01-01	| curry	       | 15	   | N	    |        |
B		   | 2021-01-02	| curry	       | 15	   | N	    |        |
B		   | 2021-01-04	| sushi	       | 10	   | N	    |        |
B	       | 2021-01-11	| sushi		   | 10    | Y		| 1      |
B		   | 2021-01-16 | ramen        | 12	   | Y      | 2      |
B		   | 2021-02-01	| ramen	       | 12	   | Y	    | 3      |
C	       | 2021-01-01	| ramen	       | 12	   | N	    |        |
C	       | 2021-01-01	| ramen	       | 12	   | N	    |        |
C		   | 2021-01-07	| ramen	       | 12	   | N	    |        |

