-- File name: Script.sql
-- Team name: N-i-MBLUS (CSC312 Practical Assignment 2)
-- Builds restaurant_db, loads sample data and runs the 10 report queries.

DROP DATABASE IF EXISTS restaurant_db;
CREATE DATABASE restaurant_db;
USE restaurant_db;

-- ---------------- DDL ----------------
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(30) NOT NULL,
    last_name   VARCHAR(30) NOT NULL,
    phone       VARCHAR(15) UNIQUE,
    email       VARCHAR(50)
);
CREATE TABLE waiter (
    waiter_id  INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name  VARCHAR(30) NOT NULL,
    hire_date  DATE NOT NULL
);
CREATE TABLE chef (
    chef_id    INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name  VARCHAR(30) NOT NULL,
    specialty  VARCHAR(30) NOT NULL,
    hire_date  DATE NOT NULL
);
CREATE TABLE dining_table (
    table_id     INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL UNIQUE,
    capacity     INT NOT NULL CHECK (capacity > 0),
    section      VARCHAR(20) NOT NULL DEFAULT 'Indoor'
);
CREATE TABLE dish (
    dish_id   INT AUTO_INCREMENT PRIMARY KEY,
    dish_name VARCHAR(50) NOT NULL UNIQUE,
    category  VARCHAR(30) NOT NULL,
    price     DECIMAL(8,2) NOT NULL CHECK (price > 0)
);
CREATE TABLE orders (
    order_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    table_id    INT NOT NULL,
    waiter_id   INT NOT NULL,
    order_date  DATETIME NOT NULL,
    status      VARCHAR(15) NOT NULL DEFAULT 'Served',
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (table_id)    REFERENCES dining_table(table_id),
    FOREIGN KEY (waiter_id)   REFERENCES waiter(waiter_id)
);
-- Bridge entity: resolves Orders M:N Dish
CREATE TABLE order_item (
    order_id INT NOT NULL,
    dish_id  INT NOT NULL,
    chef_id  INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    PRIMARY KEY (order_id, dish_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (dish_id)  REFERENCES dish(dish_id),
    FOREIGN KEY (chef_id)  REFERENCES chef(chef_id)
);
CREATE INDEX idx_orders_date ON orders(order_date);

-- ---------------- DML ----------------
INSERT INTO customer (first_name, last_name, phone, email) VALUES
('Thabo','Mokoena','0821110001','thabo@mail.com'),
('Ayesha','Patel','0821110002','ayesha@mail.com'),
('Liam','van Wyk','0821110003','liam@mail.com'),
('Nomsa','Dlamini','0821110004','nomsa@mail.com'),
('Sipho','Khumalo','0821110005','sipho@mail.com'),
('Emma','Jacobs','0821110006','emma@mail.com'),
('Kagiso','Molefe','0821110007','kagiso@mail.com'),
('Zinhle','Ndlovu','0821110008','zinhle@mail.com'),
('Pieter','Botha','0821110009','pieter@mail.com'),
('Lerato','Sithole','0821110010','lerato@mail.com');

INSERT INTO waiter (first_name, last_name, hire_date) VALUES
('Anele','Zulu','2022-03-01'),('Megan','Smith','2023-06-15'),
('Tumi','Radebe','2021-01-10'),('Jaco','Pretorius','2024-02-20');

INSERT INTO chef (first_name, last_name, specialty, hire_date) VALUES
('Marco','Rossi','Italian','2019-05-01'),
('Naledi','Mahlangu','Grill','2020-09-12'),
('Chen','Wei','Seafood','2021-07-30');

INSERT INTO dining_table (table_number, capacity, section) VALUES
(1,2,'Indoor'),(2,2,'Indoor'),(3,4,'Indoor'),
(4,4,'Patio'),(5,6,'Patio'),(6,8,'Private');

INSERT INTO dish (dish_name, category, price) VALUES
('Bruschetta','Starter',55.00),('Calamari Rings','Starter',75.00),
('Garden Salad','Starter',50.00),('Beef Burger','Main Course',110.00),
('Grilled Ribeye','Main Course',195.00),('Chicken Alfredo','Main Course',130.00),
('Seafood Platter','Main Course',240.00),('Margherita Pizza','Main Course',95.00),
('Lamb Chops','Main Course',185.00),('Chocolate Brownie','Dessert',60.00),
('Malva Pudding','Dessert',58.00),('Cheesecake','Dessert',65.00),
('Fresh Juice','Beverage',35.00),('Cappuccino','Beverage',32.00);

INSERT INTO orders (customer_id, table_id, waiter_id, order_date, status) VALUES
(1,3,1,'2026-07-04 18:30:00','Served'),(2,1,2,'2026-07-11 19:10:00','Served'),
(3,5,1,'2026-07-18 20:00:00','Served'),(1,6,3,'2026-07-25 19:45:00','Served'),
(4,2,2,'2026-08-02 13:15:00','Served'),(5,4,3,'2026-08-09 12:40:00','Served'),
(2,5,1,'2026-08-15 18:50:00','Served'),(6,3,4,'2026-08-22 19:20:00','Served'),
(3,6,3,'2026-08-29 20:10:00','Served'),(7,1,2,'2026-09-05 13:00:00','Served'),
(1,5,1,'2026-09-12 19:30:00','Served'),(4,4,4,'2026-09-19 18:15:00','Served'),
(8,6,3,'2026-09-26 20:30:00','Served'),(5,3,2,'2026-10-03 12:30:00','Served'),
(2,6,1,'2026-10-08 19:55:00','Cancelled');

INSERT INTO order_item (order_id, dish_id, chef_id, quantity) VALUES
(1,1,1,2),(1,4,2,2),(1,10,1,2),
(2,3,1,1),(2,6,1,1),(2,14,1,2),
(3,2,3,3),(3,5,2,2),(3,7,3,1),(3,12,1,3),
(4,1,1,4),(4,9,2,3),(4,7,3,2),(4,11,1,4),(4,13,1,4),
(5,8,1,1),(5,14,1,1),
(6,4,2,2),(6,13,1,2),
(7,2,3,2),(7,6,1,2),(7,5,2,2),(7,10,1,2),
(8,8,1,2),(8,3,1,2),(8,12,1,1),
(9,7,3,3),(9,5,2,3),(9,9,2,2),(9,12,1,4),(9,2,3,4),
(10,3,1,1),(10,14,1,1),
(11,1,1,3),(11,6,1,3),(11,9,2,2),(11,10,1,3),
(12,4,2,2),(12,11,1,2),
(13,7,3,2),(13,5,2,2),(13,2,3,2),(13,12,1,2),
(14,8,1,1),(14,13,1,1),
(15,5,2,1);

-- ============ QUERIES (cancelled orders excluded from revenue) ============

-- Q1 (Simple: single table, ORDER BY)
-- Context: the full menu grouped by category and sorted by price, used for the printed menu.
SELECT dish_name, category, price
FROM dish
ORDER BY category, price;

-- Q2 (Simple: single table, WHERE, ORDER BY)
-- Context: tables that can seat a group of 4 or more, used by the host when taking bookings.
SELECT table_number, capacity, section
FROM dining_table
WHERE capacity >= 4
ORDER BY capacity DESC, table_number;

-- Q3 (Medium: INNER JOIN, SUM/COUNT/AVG, GROUP BY)
-- Context: sales and average order value per waiter, to reward top performers and coach others.
SELECT CONCAT(w.first_name,' ',w.last_name) AS waiter,
       COUNT(DISTINCT o.order_id)           AS orders_served,
       SUM(oi.quantity * d.price)           AS total_sales,
       ROUND(SUM(oi.quantity * d.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM waiter w
INNER JOIN orders o      ON w.waiter_id = o.waiter_id
INNER JOIN order_item oi ON o.order_id = oi.order_id
INNER JOIN dish d        ON oi.dish_id = d.dish_id
WHERE o.status <> 'Cancelled'
GROUP BY w.waiter_id, w.first_name, w.last_name
ORDER BY total_sales DESC;

-- Q4 (Medium: subquery in WHERE, LIKE, CONCAT, AVG)
-- Context: main courses priced above the menu average, to decide which premium dishes to promote.
SELECT CONCAT(dish_name,' (R',FORMAT(price,2),')') AS premium_main, category
FROM dish
WHERE category LIKE 'Main%'
  AND price > (SELECT AVG(price) FROM dish)
ORDER BY price DESC;

-- Q5 (Medium: LEFT JOIN, COUNT/SUM/MAX, GROUP BY)
-- Context: each customer's visits, total spend and biggest single dish line (quantity x price),
-- including customers who never ordered (loyalty targeting).
SELECT CONCAT(c.first_name,' ',c.last_name) AS customer,
       COUNT(DISTINCT o.order_id)           AS visits,
       COALESCE(SUM(oi.quantity * d.price),0) AS total_spent,
       COALESCE(MAX(oi.quantity * d.price),0) AS biggest_line_item
FROM customer c
LEFT JOIN orders o      ON c.customer_id = o.customer_id AND o.status <> 'Cancelled'
LEFT JOIN order_item oi ON o.order_id = oi.order_id
LEFT JOIN dish d        ON oi.dish_id = d.dish_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Q6 (Medium: NATURAL JOIN, date function, SUM/COUNT/AVG, GROUP BY)
-- Context: monthly revenue trend, to plan stock and staffing for busy/slow months.
SELECT DATE_FORMAT(order_date,'%Y-%m') AS month,
       COUNT(DISTINCT order_id)        AS orders,
       SUM(quantity * price)           AS revenue,
       ROUND(AVG(quantity * price),2)  AS avg_line_value
FROM orders NATURAL JOIN order_item NATURAL JOIN dish
WHERE status <> 'Cancelled'
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY month;

-- Q7 (Complex: nested subquery inside HAVING, 4 tables)
-- Context: customers spending above the average customer spend, as candidates for VIP offers.
SELECT CONCAT(c.first_name,' ',c.last_name) AS vip_customer,
       COUNT(DISTINCT o.order_id)           AS visits,
       SUM(oi.quantity * d.price)           AS total_spent
FROM customer c
INNER JOIN orders o      ON c.customer_id = o.customer_id
INNER JOIN order_item oi ON o.order_id = oi.order_id
INNER JOIN dish d        ON oi.dish_id = d.dish_id
WHERE o.status <> 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(oi.quantity * d.price) >
       (SELECT AVG(t.spend)
        FROM (SELECT SUM(oi2.quantity * d2.price) AS spend
              FROM orders o2
              INNER JOIN order_item oi2 ON o2.order_id = oi2.order_id
              INNER JOIN dish d2        ON oi2.dish_id = d2.dish_id
              WHERE o2.status <> 'Cancelled'
              GROUP BY o2.customer_id) AS t)
ORDER BY total_spent DESC;

-- Q8 (Complex: LEFT JOIN, correlated nested subquery, HAVING with AND/OR)
-- Context: slow sellers (<6 portions, including never sold) priced below their category average
-- or under R100; candidates for removal or promotion.
SELECT d.dish_name, d.category, d.price,
       COALESCE(SUM(oi.quantity),0) AS portions_sold
FROM dish d
LEFT JOIN order_item oi ON d.dish_id = oi.dish_id
     AND oi.order_id IN (SELECT order_id FROM orders WHERE status <> 'Cancelled')
GROUP BY d.dish_id, d.dish_name, d.category, d.price
HAVING COALESCE(SUM(oi.quantity),0) < 6
   AND (d.price < (SELECT AVG(d2.price) FROM dish d2 WHERE d2.category = d.category)
        OR d.price < 100)
ORDER BY portions_sold, d.price;

-- Q9 (Complex: 4-table LEFT JOIN, nested subquery, CASE, DATEDIFF, HAVING with OR/AND)
-- Context: customers who never visited, or who spent R500+ but have not been back in the last
-- 30 days of trading; targets for a win-back offer.
SELECT CONCAT(c.first_name,' ',c.last_name) AS customer,
       c.phone, c.email,
       COUNT(DISTINCT o.order_id)             AS past_visits,
       COALESCE(SUM(oi.quantity * d.price),0) AS lifetime_spend,
       DATE(MAX(o.order_date))                AS last_visit,
       DATEDIFF((SELECT MAX(o2.order_date) FROM orders o2 WHERE o2.status <> 'Cancelled'),
                MAX(o.order_date))            AS days_since_visit,
       CASE WHEN MAX(o.order_date) IS NULL THEN 'Never visited'
            ELSE 'Lapsed regular' END         AS segment
FROM customer c
LEFT JOIN orders o      ON c.customer_id = o.customer_id AND o.status <> 'Cancelled'
LEFT JOIN order_item oi ON o.order_id = oi.order_id
LEFT JOIN dish d        ON oi.dish_id = d.dish_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.phone, c.email
HAVING last_visit IS NULL
    OR (days_since_visit > 30 AND lifetime_spend >= 500)
ORDER BY lifetime_spend DESC;

-- Q10 (Complex: 3-table join, correlated nested subquery inside HAVING, HAVING with AND)
-- Context: the best-selling dish in each menu category (ordered in 3+ separate orders),
-- to decide which dish to feature in each section of the menu.
SELECT d.category,
       d.dish_name                AS best_seller,
       SUM(oi.quantity)           AS portions_sold,
       COUNT(DISTINCT o.order_id) AS times_ordered,
       SUM(oi.quantity * d.price) AS revenue
FROM dish d
INNER JOIN order_item oi ON d.dish_id = oi.dish_id
INNER JOIN orders o      ON oi.order_id = o.order_id
WHERE o.status <> 'Cancelled'
GROUP BY d.dish_id, d.category, d.dish_name
HAVING SUM(oi.quantity) = (SELECT MAX(t.qty)
                           FROM (SELECT d2.category, SUM(oi2.quantity) AS qty
                                 FROM dish d2
                                 INNER JOIN order_item oi2 ON d2.dish_id = oi2.dish_id
                                 INNER JOIN orders o2      ON oi2.order_id = o2.order_id
                                 WHERE o2.status <> 'Cancelled'
                                 GROUP BY d2.dish_id, d2.category) AS t
                           WHERE t.category = d.category)
   AND COUNT(DISTINCT o.order_id) >= 3
ORDER BY revenue DESC;