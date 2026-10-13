/*
 * File name: NiMBLUS_RestaurantQueries.java
 * Team name: N-i-MBLUS
 * Module:    CSC312 Practical Assignment 2
 *
 * Team members (student numbers):
 *   Urim Fortein                 4458952
 *   Lucia Dimakatse Malamba      4458611
 *   Bongani Peter Nyirenda       4426924
 *   Marc Wydeman                 4494008
 *   Sibusisiwe Zulu              4270237
 *   Nicoroy Lehlohonolo Zwane    4426412
 */

import java.sql.*;

/** Basic JDBC program: runs the 10 restaurant_db queries and prints the results. */
public class NiMBLUS_RestaurantQueries {

    // Change these to match your MySQL Workbench connection
    static final String URL  = "jdbc:mysql://172.21.12.21:YOUR_PORT/restaurant_db";
    static final String USER = "YOUR_USERNAME";
    static final String PASS = "YOUR_PASSWORD";

    public static void main(String[] args) {
        String[][] queries = {
            {
             " the full menu grouped by category and sorted by price, used for the printed menu.",
             "SELECT dish_name, category, price\n"
             + "FROM dish\n"
             + "ORDER BY category, price\n"},
            {
             " tables that can seat a group of 4 or more, used by the host when taking bookings.",
             "SELECT table_number, capacity, section\n"
             + "FROM dining_table\n"
             + "WHERE capacity >= 4\n"
             + "ORDER BY capacity DESC, table_number\n"},
            {
             " total sales and average order value per waiter. Management can use this to reward top performers and identify waiters needing coaching.",
             "SELECT CONCAT(w.first_name,' ',w.last_name) AS waiter,\n"
             + "       COUNT(DISTINCT o.order_id)           AS orders_served,\n"
             + "       SUM(oi.quantity * d.price)           AS total_sales,\n"
             + "       ROUND(SUM(oi.quantity * d.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value\n"
             + "FROM waiter w\n"
             + "INNER JOIN orders o      ON w.waiter_id = o.waiter_id\n"
             + "INNER JOIN order_item oi ON o.order_id = oi.order_id\n"
             + "INNER JOIN dish d        ON oi.dish_id = d.dish_id\n"
             + "WHERE o.status <> 'Cancelled'\n"
             + "GROUP BY w.waiter_id, w.first_name, w.last_name\n"
             + "ORDER BY total_sales DESC\n"},
            {
             " main courses priced above the menu's average dish price. Helps decide which premium dishes to promote or re-price.",
             "SELECT CONCAT(dish_name,' (R',FORMAT(price,2),')') AS premium_main,\n"
             + "       category\n"
             + "FROM dish\n"
             + "WHERE category LIKE 'Main%'\n"
             + "  AND price > (SELECT AVG(price) FROM dish)\n"
             + "ORDER BY price DESC\n"},
            {
             " every customer's visits, total spend and their biggest single dish line (quantity x price), including customers who never ordered. Used for loyalty/marketing targeting.",
             "SELECT CONCAT(c.first_name,' ',c.last_name) AS customer,\n"
             + "       COUNT(DISTINCT o.order_id)           AS visits,\n"
             + "       COALESCE(SUM(oi.quantity * d.price),0) AS total_spent,\n"
             + "       COALESCE(MAX(oi.quantity * d.price),0) AS biggest_line_item\n"
             + "FROM customer c\n"
             + "LEFT JOIN orders o      ON c.customer_id = o.customer_id AND o.status <> 'Cancelled'\n"
             + "LEFT JOIN order_item oi ON o.order_id = oi.order_id\n"
             + "LEFT JOIN dish d        ON oi.dish_id = d.dish_id\n"
             + "GROUP BY c.customer_id, c.first_name, c.last_name\n"
             + "ORDER BY total_spent DESC\n"},
            {
             " monthly revenue trend to spot busy/slow months for stock and staffing.",
             "SELECT DATE_FORMAT(order_date,'%Y-%m') AS month,\n"
             + "       COUNT(DISTINCT order_id)        AS orders,\n"
             + "       SUM(quantity * price)           AS revenue,\n"
             + "       ROUND(AVG(quantity * price),2)  AS avg_line_value\n"
             + "FROM orders NATURAL JOIN order_item NATURAL JOIN dish\n"
             + "WHERE status <> 'Cancelled'\n"
             + "GROUP BY DATE_FORMAT(order_date,'%Y-%m')\n"
             + "ORDER BY month\n"},
            {
             " \"high-value\" customers whose total spend is above the average spend per customer. These are candidates for VIP offers.",
             "SELECT CONCAT(c.first_name,' ',c.last_name) AS vip_customer,\n"
             + "       COUNT(DISTINCT o.order_id)           AS visits,\n"
             + "       SUM(oi.quantity * d.price)           AS total_spent\n"
             + "FROM customer c\n"
             + "INNER JOIN orders o      ON c.customer_id = o.customer_id\n"
             + "INNER JOIN order_item oi ON o.order_id = oi.order_id\n"
             + "INNER JOIN dish d        ON oi.dish_id = d.dish_id\n"
             + "WHERE o.status <> 'Cancelled'\n"
             + "GROUP BY c.customer_id, c.first_name, c.last_name\n"
             + "HAVING SUM(oi.quantity * d.price) >\n"
             + "       (SELECT AVG(t.spend)\n"
             + "        FROM (SELECT SUM(oi2.quantity * d2.price) AS spend\n"
             + "              FROM orders o2\n"
             + "              INNER JOIN order_item oi2 ON o2.order_id = oi2.order_id\n"
             + "              INNER JOIN dish d2        ON oi2.dish_id = d2.dish_id\n"
             + "              WHERE o2.status <> 'Cancelled'\n"
             + "              GROUP BY o2.customer_id) AS t)\n"
             + "ORDER BY total_spent DESC\n"},
            {
             " slow-selling dishes (fewer than 6 portions sold, including never sold) that are either priced below the average of their own category or cheaper than R100. Candidates for removal or promotion.",
             "SELECT d.dish_name, d.category, d.price,\n"
             + "       COALESCE(SUM(oi.quantity),0) AS portions_sold\n"
             + "FROM dish d\n"
             + "LEFT JOIN order_item oi ON d.dish_id = oi.dish_id\n"
             + "     AND oi.order_id IN (SELECT order_id FROM orders WHERE status <> 'Cancelled')\n"
             + "GROUP BY d.dish_id, d.dish_name, d.category, d.price\n"
             + "HAVING COALESCE(SUM(oi.quantity),0) < 6\n"
             + "   AND (d.price < (SELECT AVG(d2.price) FROM dish d2 WHERE d2.category = d.category)\n"
             + "        OR d.price < 100)\n"
             + "ORDER BY portions_sold, d.price\n"},
            {
             " customers who never visited, or who spent R500+ but have not been back in the last 30 days of trading. These are the people to target with a win-back offer.",
             "SELECT CONCAT(c.first_name,' ',c.last_name) AS customer,\n"
             + "       c.phone, c.email,\n"
             + "       COUNT(DISTINCT o.order_id)             AS past_visits,\n"
             + "       COALESCE(SUM(oi.quantity * d.price),0) AS lifetime_spend,\n"
             + "       DATE(MAX(o.order_date))                AS last_visit,\n"
             + "       DATEDIFF((SELECT MAX(o2.order_date) FROM orders o2 WHERE o2.status <> 'Cancelled'),\n"
             + "                MAX(o.order_date))            AS days_since_visit,\n"
             + "       CASE WHEN MAX(o.order_date) IS NULL THEN 'Never visited'\n"
             + "            ELSE 'Lapsed regular' END         AS segment\n"
             + "FROM customer c\n"
             + "LEFT JOIN orders o      ON c.customer_id = o.customer_id AND o.status <> 'Cancelled'\n"
             + "LEFT JOIN order_item oi ON o.order_id = oi.order_id\n"
             + "LEFT JOIN dish d        ON oi.dish_id = d.dish_id\n"
             + "GROUP BY c.customer_id, c.first_name, c.last_name, c.phone, c.email\n"
             + "HAVING last_visit IS NULL\n"
             + "    OR (days_since_visit > 30 AND lifetime_spend >= 500)\n"
             + "ORDER BY lifetime_spend DESC\n"},
            {
             " the best-selling dish in each menu category (ordered in 3+ separate orders). Tells the restaurant which dish to feature in each section of the menu.",
             "SELECT d.category,\n"
             + "       d.dish_name                AS best_seller,\n"
             + "       SUM(oi.quantity)           AS portions_sold,\n"
             + "       COUNT(DISTINCT o.order_id) AS times_ordered,\n"
             + "       SUM(oi.quantity * d.price) AS revenue\n"
             + "FROM dish d\n"
             + "INNER JOIN order_item oi ON d.dish_id = oi.dish_id\n"
             + "INNER JOIN orders o      ON oi.order_id = o.order_id\n"
             + "WHERE o.status <> 'Cancelled'\n"
             + "GROUP BY d.dish_id, d.category, d.dish_name\n"
             + "HAVING SUM(oi.quantity) = (SELECT MAX(t.qty)\n"
             + "                           FROM (SELECT d2.category, SUM(oi2.quantity) AS qty\n"
             + "                                 FROM dish d2\n"
             + "                                 INNER JOIN order_item oi2 ON d2.dish_id = oi2.dish_id\n"
             + "                                 INNER JOIN orders o2      ON oi2.order_id = o2.order_id\n"
             + "                                 WHERE o2.status <> 'Cancelled'\n"
             + "                                 GROUP BY d2.dish_id, d2.category) AS t\n"
             + "                           WHERE t.category = d.category)\n"
             + "   AND COUNT(DISTINCT o.order_id) >= 3\n"
             + "ORDER BY revenue DESC\n"},
        };

        try (Connection con = DriverManager.getConnection(URL, USER, PASS);
             Statement st = con.createStatement()) {

            for (int i = 0; i < queries.length; i++) {
                System.out.println("\n=== Query " + (i + 1) + " " + " ===\n");
                System.out.println("Context: " + queries[i][0] + "\n");
                try (ResultSet rs = st.executeQuery(queries[i][1])) {
                    printResults(rs);
                } catch (SQLException e) {
                    System.out.println("Query " + (i + 1) + " failed: " + e.getMessage());
                }
            }
        } catch (SQLException e) {
            System.out.println("Could not connect to the database: " + e.getMessage());
        }
    }

    // Prints any result set as simple tab-separated rows
    static void printResults(ResultSet rs) throws SQLException {
        ResultSetMetaData md = rs.getMetaData();
        int cols = md.getColumnCount();
        for (int c = 1; c <= cols; c++) System.out.print(md.getColumnLabel(c) + "\t");
        System.out.println();
        int rows = 0;
        while (rs.next()) {
            for (int c = 1; c <= cols; c++) System.out.print(rs.getString(c) + "\t");
            System.out.println();
            rows++;
        }
        System.out.println("(" + rows + " rows)");
    }
}
