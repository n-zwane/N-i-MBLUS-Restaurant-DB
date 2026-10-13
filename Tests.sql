-- File name: Tests.sql
-- Team name: N-i-MBLUS (CSC312 Practical Assignment 2)
-- Run this after Script.sql. It tries a set of invalid changes to check that the constraints
-- reject them, then checks the sample data against values we worked out by hand.
-- Every change is rolled back, so the data in restaurant_db is left exactly as it was.
-- The last statement prints one table with a PASS or FAIL for each test.

USE restaurant_db;

DROP TEMPORARY TABLE IF EXISTS test_results;
CREATE TEMPORARY TABLE test_results (
    test_no  INT AUTO_INCREMENT PRIMARY KEY,
    test     VARCHAR(60),
    expected VARCHAR(60),
    actual   VARCHAR(200),
    result   VARCHAR(4)
);

DROP PROCEDURE IF EXISTS expect_error;

DELIMITER $$
-- Runs one statement that should be rejected, records the error MySQL returns, then rolls back.
CREATE PROCEDURE expect_error(IN test_name VARCHAR(60), IN stmt TEXT)
BEGIN
    DECLARE err_no  INT  DEFAULT NULL;
    DECLARE err_msg TEXT DEFAULT NULL;
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
            GET DIAGNOSTICS CONDITION 1 err_no = MYSQL_ERRNO, err_msg = MESSAGE_TEXT;
        START TRANSACTION;
        SET @test_sql = stmt;
        PREPARE test_stmt FROM @test_sql;
        EXECUTE test_stmt;
    END;
    ROLLBACK;
    DEALLOCATE PREPARE test_stmt;
    INSERT INTO test_results (test, expected, actual, result)
    VALUES (test_name, 'Rejected',
            IF(err_no IS NULL, 'Accepted with no error', CONCAT('Error ', err_no, ': ', err_msg)),
            IF(err_no IS NULL, 'FAIL', 'PASS'));
END$$
DELIMITER ;

-- ---------------- Constraint tests (each one should be rejected) ----------------
CALL expect_error('CHECK: table capacity must be above 0',
    'INSERT INTO dining_table (table_number, capacity) VALUES (99, 0)');
CALL expect_error('CHECK: dish price must be above 0',
    'INSERT INTO dish (dish_name, category, price) VALUES (''Test Dish'', ''Starter'', -5)');
CALL expect_error('CHECK: quantity must be above 0',
    'INSERT INTO order_item (order_id, dish_id, chef_id, quantity) VALUES (1, 2, 1, 0)');
CALL expect_error('UNIQUE: customer phone number',
    'INSERT INTO customer (first_name, last_name, phone) VALUES (''Test'', ''Person'', ''0821110001'')');
CALL expect_error('UNIQUE: dish name',
    'INSERT INTO dish (dish_name, category, price) VALUES (''Cheesecake'', ''Dessert'', 70)');
CALL expect_error('UNIQUE: table number',
    'INSERT INTO dining_table (table_number, capacity) VALUES (1, 4)');
CALL expect_error('PK: same dish twice on one order',
    'INSERT INTO order_item (order_id, dish_id, chef_id, quantity) VALUES (1, 1, 1, 1)');
CALL expect_error('FK: order with a waiter that does not exist',
    'INSERT INTO orders (customer_id, table_id, waiter_id, order_date) VALUES (1, 1, 99, NOW())');
CALL expect_error('FK: order item with a dish that does not exist',
    'INSERT INTO order_item (order_id, dish_id, chef_id, quantity) VALUES (1, 99, 1, 1)');
CALL expect_error('FK: delete a dish that has been ordered',
    'DELETE FROM dish WHERE dish_id = 1');
CALL expect_error('NOT NULL: customer first name',
    'INSERT INTO customer (first_name, last_name) VALUES (NULL, ''Person'')');

-- ---------------- Data checks (actual value should match the expected value) ----------------
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Row count: customer', '10', COUNT(*), IF(COUNT(*) = 10, 'PASS', 'FAIL') FROM customer;
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Row count: waiter', '4', COUNT(*), IF(COUNT(*) = 4, 'PASS', 'FAIL') FROM waiter;
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Row count: chef', '3', COUNT(*), IF(COUNT(*) = 3, 'PASS', 'FAIL') FROM chef;
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Row count: dining_table', '6', COUNT(*), IF(COUNT(*) = 6, 'PASS', 'FAIL') FROM dining_table;
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Row count: dish', '14', COUNT(*), IF(COUNT(*) = 14, 'PASS', 'FAIL') FROM dish;
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Row count: orders', '15', COUNT(*), IF(COUNT(*) = 15, 'PASS', 'FAIL') FROM orders;
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Row count: order_item', '46', COUNT(*), IF(COUNT(*) = 46, 'PASS', 'FAIL') FROM order_item;
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Cancelled orders in the sample data', '1', COUNT(*), IF(COUNT(*) = 1, 'PASS', 'FAIL')
FROM orders WHERE status = 'Cancelled';
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Orders with no items', '0', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM orders o WHERE NOT EXISTS (SELECT 1 FROM order_item oi WHERE oi.order_id = o.order_id);
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Customers who never ordered', '2', COUNT(*), IF(COUNT(*) = 2, 'PASS', 'FAIL')
FROM customer c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);
INSERT INTO test_results (test, expected, actual, result)
SELECT 'Revenue without the cancelled order', '10101.00', SUM(oi.quantity * d.price),
       IF(SUM(oi.quantity * d.price) = 10101.00, 'PASS', 'FAIL')
FROM orders o
INNER JOIN order_item oi ON o.order_id = oi.order_id
INNER JOIN dish d        ON oi.dish_id = d.dish_id
WHERE o.status <> 'Cancelled';

DROP PROCEDURE expect_error;

SELECT * FROM test_results ORDER BY test_no;
