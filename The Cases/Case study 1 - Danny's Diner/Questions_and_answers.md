# The Danny's Diner

## Questions and Answers


### 1. What is the total amount each customer spent at the restaurant?

```
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
```

**Steps:**

- Use **SUM** and **GROUP BY** to get ```amount_spent_per_customer``` for each customer.
- Use **LEFT JOIN** to merge ```sales``` and ```menu``` tables on ```product_id.```

**Results:**

 customer_id  |	amount_spent_per_customer|
--------------+--------------------------+
 A	      |	76                       |           
 B	      |	74                       |            
 C	      |	36                       |            


| customer_id                                | amount_spent_per_customer |   |
|--------------------------------------------|---------------------------|---|
| --------------+--------------------------+ |                           |   |
| A                                          | 76                        |   |
| B                                          | 74                        |   |
| C                                          | 36                        |   |

### 2. How many days has each customer visited the restaurant?

```
SELECT
    customer_id,
    COUNT(DISTINCT order_date) AS NUMBER_OF_DAYS
FROM
    dannys_diner.sales
GROUP BY 
    customer_id
ORDER BY 
    customer_id;

```

**Steps:**

- Use **COUNT DISTINCT** on ```order_date``` to calculate the number of visits to the restaurant for each customer called ```number_of_days```.
- Use the **GROUP BY** to get ```number_of_days``` of each customer

**Results:**

customer_id |number_of_days|
------------+--------------+
A           | 4            |
B           | 6            |
C           | 2            |

| customer_id                  | number_of_days |
|------------------------------|----------------|
| ------------+--------------+ |                |
| A                            | 4              |
| B                            | 6              |
| C                            | 2              |


### 3. What was the first item from the menu purchased by each customer?

```
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
```

**Steps:**

- Create a sub-query in the **FROM** statement called ```SUB```, selecting ```customer_id,``` ```order_date,``` ```product_name.```
- Use the windows function **RANK()** to create a new column ```rank``` based on ```order_date.```
- Use the **LEFT JOIN**  to merge the ```menu``` and ```sales``` table.
- Select the **DISTINCT** ```customer_id,``` ```product_name,``` and subset using **WHERE** ```rank = 1.```

**Results:**

customer_id | product_name | rank|
------------+--------------+-----+
A           | curry        | 1   |      
A           | sushi        | 1   |
B           | curry        | 1   |
C           | ramen        | 1   |

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```
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
```

**Steps:**

- Select the ```product_name``` and **COUNT** the number of ```product_name``` as ```TOTAL_NUMBER_OF_PURCHASED_ITEMS.```
- Use the **LEFT JOIN**  to merge the ```menu``` and ```sales``` table.
- Use the **GROUP BY** statement to group the result by ```product_name.```
- Use the **LIMIT** 1 to output the most purchased item only.

**Results:**

product_name| total_number_of_purchased_items|
------------+--------------------------------+
ramen       | 8                              |


### 5. Which item was the most popular for each customer?

```
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
```

**Steps:**

- Create a sub-query in the **FROM** statement called ```SUB```, selecting ```customer_id,``` ```product_name,``` and **COUNT** the number     of orders as ```order_count.```
- Use the windows function **RANK()** to create a new column ```COUNT``` based on ```customer_id``` in descending order.
- Select the ```customer_id``` and the ```product_name.```
- Use the **WHERE** statement to subset the results where the ```COUNT = 1```.

**Results:**

customer_id| product_name|
-----------+-------------+
A          | ramen       |
B          | sushi       |
B          | curry       |
B          | ramen       |   
C          | ramen       |

### 6. Which item was purchased first by the customer after they became a member?

```
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

```

**Steps:**

- Create a sub-query in the **FROM** statement called ```SUB```, selecting ```customer_id```, ```product_name```, ```order_date```, and       ```join_date```.
- Use the window function **RANK()** to create a new column called ```RANK``` based on ```S.order_date``` in ascending order. This ranks the   orders by ```order_date``` for each customer.
- Select the columns ```customer_id```, ```product_name```, and ```order_date```.
- Use the **INNER JOIN** clause to connect the sales_table(S) and the menu_table(M) on the ```product_id```, allowing you to link sales       with product_names.
- Add another **INNER JOIN** to connect the sales_table(S) with the members_table(ME) on the ```customer_id``` to check if the order date is   greater than or equal to the customer's ```join_date```.
- In the **WHERE** clause, filter the results to include only records where the ```order_date``` is greater than or equal to the               ```join_date```, ensuring that only orders placed after joining are considered.   
- In the outer query, select the results by filtering records where the **RANK** is equal to 1. This gives you the earliest product ordered   by each customer after they joined.

**Results:**

customer_id| product_name| order_date|
-----------+-------------+-----------+
A          | curry       | 2021-01-07|
B          | sushi       | 2021-01-11|

### 7. Which item was purchased just before the customer became a member?

```
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
```

**Steps:**

- Create a sub-query in the FROM statement called ```SUB```, selecting ```customer_id```, ```product_name```, ```order_date```, and           ```join_date```.       
- Use the window function **RANK()** to create a new column called ```RANK``` based on ```order_date``` in descending order within each       customer's orders. This will rank orders from the latest to the earliest for each customer.
- Select the columns ```customer_id```, ```product_name```, and ```order_date```.
- Use the **INNER JOIN** clause to connect the sales_table(S) and the menu_table(M) on the ```product_id```, allowing you to link sales with   product_names.
- Add another **INNER JOIN** to connect the sales_table(S) with the members_table(ME) on the ```customer_id``` to check if the                 ```order_date``` is earlier than the customer's ```join_date```.                   
- In the **WHERE** clause, filter the results to include only records where the order_date is less than the ```join_date```, ensuring that     only orders placed before joining are considered.
- In the outer query, select the results by filtering records where the **RANK** is equal to 1. This will give you the latest product         ordered by each customer before they joined.

**Results:**

customer_id| product_name| order_date|
-----------+-------------+-----------+
A          | sushi       | 2021-01-01|
A          | curry       | 2021-01-01|
B          | sushi       | 2021-01-04|


### 8. What is the total items and amount spent for each member before they became a member?

```
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
```

**Steps:**

- Calculate the total number of items purchased and the total amount spent by each customer before their ```join_date``` as a member.
- Utilize the **COUNT(*)** function to count the total number of items purchased and the **SUM(M.price)** function to calculate the total     amount spent by each customer.
- Group the results by ```customer_id``` to compute totals for each customer.
- The **INNER JOIN** clauses connect the sales and menu_tables(M) on the ```product_id```, allowing sales data to be associated with the       corresponding menu item information. Another **INNER JOIN** associates the sales table with the members_table(ME) using the                 ```customer_id``` to check join dates.             
- In the **WHERE** clause, filter the results to include only records where the order date is less than the ```join_date```, ensuring that     only orders placed before joining are considered.
- The results are ordered by ```customer_id``` in ascending order using the **ORDER BY** clause to organize the final output.

**Results:**

customer_id| total_items| total_amount|
-----------+------------+-------------+
A          | 2          |  25         |
B          | 3          |  40         |


### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```
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
```

**Steps:**

- Use a **SUM** function combined with a **CASE statement** to determine the points for each product. If the product is 'sushi,' the points   are calculated as 10 times the price times 2 (a multiplier), otherwise, it's calculated as 10 times the regular price.
- Group the results by ```customer_id``` to compute the total points earned by each customer.
- Utilize a **LEFT JOIN** to associate the sales and menu tables using the ```product_id```, allowing sales data to be linked with the         corresponding  menu item information.
- The **GROUP BY** clause ensures that the results are grouped by ```customer_id```, so the points are calculated per customer.
- The results are then ordered by ```customer_id``` in ascending order to organize the final output.

**Results:**

customer_id| points|
-----------+-------+
A          | 860   |
B          | 940   |
C          | 360   |

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how

```
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
```

**Steps:**

- Utilize a **SUM** function combined with a **CASE statement** to determine the points for each product. If the product is 'sushi' or the     order date is within 6 days of joining (considered as a special promotion), the points are calculated as 10 times the price times 2 (a       multiplier), otherwise, it's calculated as 10 times the regular price.
- In the **WHERE** clause, filter the results to include only customers with IDs ```'A'``` or ```'B'``` and orders placed in January (month   extracted from the ```order_date```).
- The **INNER JOIN** clauses connect the sales and menu tables on the ```product_id```, allowing sales data to be associated with the         corresponding menu item information. Another **INNER JOIN** associates the sales table with the members table using the ```customer_id```   to check join dates.
- The results are grouped by ```customer_id``` to compute the total points earned by each customer.

**Results:**

customer_id| points|
-----------+-------+
A          | 1370  |
B          | 820   |

## BONUS QUESTIONS

**1. JOIN ALL THINGS**

```
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
```

**Results:**

customer_id| order_date	| product_name | price | member |
-----------+------------+--------------+-------+--------+
A          | 2021-01-01 | sushi        | 10    | N      |
A          | 2021-01-01 | curry        | 15    | N      |      
A          | 2021-01-07 | curry        | 15    | Y      |
A          | 2021-01-10 | ramen        | 12    | Y      |
A          | 2021-01-11 | ramen        | 12    | Y      |
A          | 2021-01-11 | ramen        | 12    | Y      |
B          | 2021-01-01 | curry        | 15    | N      |
B          | 2021-01-02 | curry        | 15    | N      |
B          | 2021-01-04 | sushi        | 10    | N      |
B          | 2021-01-11 | sushi        | 10    | Y      |
B          | 2021-01-16 | ramen        | 12    | Y      |
B          | 2021-02-01 | ramen        | 12    | Y      |
C          | 2021-01-01 | ramen        | 12    | N      |
C          | 2021-01-01 | ramen        | 12    | N      |
C          | 2021-01-07 | ramen        | 12    | N      |

**2. RANK ALL THE THINGS**

```
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
```

**Results:**

customer_id| order_date | product_name | price | member | ranking|
-----------+------------+--------------+-------+--------+--------+
A          | 2021-01-01 | curry        | 15    | N      |        |
A          | 2021-01-01 | sushi        | 10    | N      |        |
A          | 2021-01-07 | curry        | 15    | Y      | 1      |
A          | 2021-01-10 | ramen        | 12    | Y      | 2      |
A          | 2021-01-11 | ramen        | 12    | Y      | 3      |
A          | 2021-01-11 | ramen        | 12    | Y      | 3      |
B          | 2021-01-01 | curry        | 15    | N      |        |
B          | 2021-01-02 | curry        | 15    | N      |        |
B          | 2021-01-04 | sushi        | 10    | N      |        |
B          | 2021-01-11 | sushi        | 10    | Y      | 1      |
B          | 2021-01-16 | ramen        | 12    | Y      | 2      |
B          | 2021-02-01 | ramen        | 12    | Y      | 3      |
C          | 2021-01-01 | ramen        | 12    | N      |        |
C          | 2021-01-01 | ramen        | 12    | N      |        |
C          | 2021-01-07 | ramen        | 12    | N      |        |



