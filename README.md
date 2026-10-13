# Restaurant Database (CSC312 Practical Assignment 2)

This is our group project for CSC312 at the University of the Western Cape. We designed a small database for a restaurant, built it in MySQL, and wrote a Java program that connects to it and runs our report queries.

## Team N-i-MBLUS

| Name | Student number |
|---|---|
| Urim Fortein | 4458952 |
| Lucia Dimakatse Malamba | 4458611 |
| Bongani Peter Nyirenda | 4426924 |
| Marc Wydeman | 4494008 |
| Sibusisiwe Zulu | 4270237 |
| Nicoroy Lehlohonolo Zwane | 4426412 |

## The scenario

A restaurant has chefs who prepare dishes and waiters who take those dishes to the tables where customers are seated. Every visit is recorded as an order. An order belongs to one customer, is served by one waiter at one table, and can contain many dishes. Each dish on an order is cooked by a specific chef.

Because one order can hold many dishes and one dish can appear on many orders, we resolved that many-to-many relationship with a bridge table called `order_item`. It also stores the quantity and the chef who cooked the item.

## Database tables

| Table | What it stores |
|---|---|
| `customer` | Customer names and contact details |
| `waiter` | Waiters and their hire dates |
| `chef` | Chefs, their specialty and hire dates |
| `dining_table` | Table number, seating capacity and section (Indoor, Patio, Private) |
| `dish` | Menu items with category and price |
| `orders` | Each visit: which customer, table and waiter, plus the date and status |
| `order_item` | Bridge table linking orders to dishes, with quantity and the chef who cooked it |

## What is in this repository

```
N-i-MBLUS-Restaurant-DB/
  Script.sql                          Creates restaurant_db, loads sample data and runs all 10 queries
  Tests.sql                           Checks the constraints and sample data, and prints a PASS or FAIL table
  src/NiMBLUS_RestaurantQueries.java  Java program that connects to the database and prints each query result
  lib/mysql-connector-j-26.7.0.jar    MySQL JDBC driver the Java program needs
  RestaurantProject.iml, .idea/       IntelliJ IDEA project files
```

## What you need

* Access to a MySQL 8 server (we use the one our lecturer set up) and MySQL Workbench
* Java JDK 22 or newer
* IntelliJ IDEA is the easiest way to run the program, but the command line works too

The MySQL driver is already included in the `lib` folder, so there is nothing extra to download.

## How to run it

Follow these steps in order. They assume you are using the MySQL server our lecturer set up for the module, with the host, port, username and password we were given.

### Before you start

* **Be on the university network.** The lecturer's server (`172.21.12.21`) is a campus address. It only works on campus Wi-Fi or when you are connected to the UWC VPN. From home without the VPN, nothing below will connect.
* **Have your login details ready:** the port number, your username and your password from the lecturer.
* **Install the tools:** MySQL Workbench, and Java (JDK 22 or newer). IntelliJ IDEA is optional but makes step 4 easier.

### Step 1: Get the code

Either clone the repository:

```
git clone https://github.com/n-zwane/N-i-MBLUS-Restaurant-DB.git
```

or click the green **Code** button on GitHub, choose **Download ZIP**, and unzip it somewhere easy to find, like your Desktop.

Either way you end up with a folder called `N-i-MBLUS-Restaurant-DB`. Every step below happens inside that folder.

### Step 2: Build the database in MySQL Workbench

**Create the connection (you only do this once):**

1. Open MySQL Workbench.
2. On the home screen, click the **+** icon next to **MySQL Connections**.
3. Fill in the form:
   * **Connection Name:** anything you like, for example `CSC312 Lecturer Server`
   * **Hostname:** `172.21.12.21`
   * **Port:** the port number from the lecturer
   * **Username:** your username from the lecturer
   * **Password:** click **Store in Vault...** and type your password
4. Click **Test Connection**. You should see "Successfully made the MySQL connection". If you get an error instead, check that you are on the campus network or VPN and that the port is right.
5. Click **OK**. The connection now appears as a tile on the home screen.

**Run the script:**

1. Click the connection tile to open it.
2. Go to **File > Open SQL Script...** and choose `Script.sql` from the project folder.
3. Click the plain lightning bolt icon in the toolbar (**Execute**, not "Execute the statement under the insertion point"). This runs the whole file from top to bottom.
4. Check the **Output** panel at the bottom. Every line should have a green tick. The last lines are the 10 queries, and their results open as tabs in the result grid.
5. In the **Schemas** panel on the left, click the refresh icon. You should now see `restaurant_db` with 7 tables inside: `chef`, `customer`, `dining_table`, `dish`, `order_item`, `orders` and `waiter`.

**If the script fails on the very first lines** with an error like `Access denied for user ... to database 'restaurant_db'`, your account is not allowed to create new databases. The lecturer has probably given you one database that already exists. To work around it:

1. Find your database name in the **Schemas** panel. It is often the same as your username.
2. At the top of `Script.sql`, delete these three lines:
   ```sql
   DROP DATABASE IF EXISTS restaurant_db;
   CREATE DATABASE restaurant_db;
   USE restaurant_db;
   ```
3. Put this line in their place, using your own database name:
   ```sql
   USE your_database_name;
   ```
4. Run the script again. Remember this database name, because you need it in step 3.

The script is safe to run more than once. It starts by deleting the old copy, so you always get a fresh database with the same sample data.

### Step 3: Put your login details into the Java program

Open `src/NiMBLUS_RestaurantQueries.java` in any editor and find these three lines near the top:

```java
static final String URL  = "jdbc:mysql://172.21.12.21:YOUR_PORT/restaurant_db";
static final String USER = "YOUR_USERNAME";
static final String PASS = "YOUR_PASSWORD";
```

Replace `YOUR_PORT`, `YOUR_USERNAME` and `YOUR_PASSWORD` with your own details. Keep the quotes. For example, with made-up values:

```java
static final String URL  = "jdbc:mysql://172.21.12.21:3307/restaurant_db";
static final String USER = "s1234567";
static final String PASS = "myPassword";
```

If you used your own database name in step 2, replace `restaurant_db` at the end of the URL with that name as well.

> **Do not commit or push this file with your real password in it.** The repository is public, so anyone could read it. When you are done, undo your changes with `git restore src/NiMBLUS_RestaurantQueries.java` (or just don't upload that file).

### Step 4: Run the program

**Option A: IntelliJ IDEA**

1. Open IntelliJ and choose **File > Open...**, then select the `N-i-MBLUS-Restaurant-DB` folder.
2. If IntelliJ shows a yellow bar saying the project SDK is not set up, click it and pick your installed JDK (22 or newer). You can also set it under **File > Project Structure > Project > SDK**.
3. In the project panel on the left, open `src`, right click `NiMBLUS_RestaurantQueries.java` and choose **Run 'NiMBLUS_RestaurantQueries.main()'**.

The MySQL driver in the `lib` folder is already linked to the project, so you do not need to add it yourself.

**Option B: Command line**

Open a terminal inside the project folder and run the two commands for your system.

On Windows (PowerShell or Command Prompt):

```
javac -cp lib\mysql-connector-j-26.7.0.jar -d out src\NiMBLUS_RestaurantQueries.java
java -cp "out;lib\mysql-connector-j-26.7.0.jar" NiMBLUS_RestaurantQueries
```

On macOS or Linux:

```
javac -cp lib/mysql-connector-j-26.7.0.jar -d out src/NiMBLUS_RestaurantQueries.java
java -cp "out:lib/mysql-connector-j-26.7.0.jar" NiMBLUS_RestaurantQueries
```

If your folder path has spaces in it, wrap the path in quotes when you `cd` into it, for example `cd "C:\Users\My Name\Desktop\N-i-MBLUS-Restaurant-DB"`.

### What you should see

The program prints each query in turn: a heading like `=== Query 1 ===`, a line starting with `Context:` that explains why the query matters to the business, the result rows, and a row count. With the sample data, the row counts should be:

| Query | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Rows | 14 | 4 | 4 | 5 | 10 | 4 | 2 | 3 | 4 | 4 |

If your counts match, everything is working.

If one query has a problem, the program prints `Query N failed:` followed by the MySQL error and carries on with the rest, so you still see every other result. If it cannot log in or reach the server at all, it prints `Could not connect to the database:` followed by the reason.

### Step 5 (optional): Run the tests

`Tests.sql` checks that the database rejects bad data and that the sample data is what we expect. Open it in MySQL Workbench on the same connection and run the whole file, just like you did with `Script.sql` in step 2. It finishes with one result table listing 22 tests, and every row should say `PASS`.

The tests try things like a table with 0 seats, a negative dish price, a duplicate phone number and an order for a waiter who does not exist. Each attempt is rolled back straight away, so running the tests never changes your data. If you renamed the database in step 2, change the `USE restaurant_db;` line at the top of `Tests.sql` too.

### If something goes wrong

| Error message | What it usually means and how to fix it |
|---|---|
| `Communications link failure` | The program cannot reach the server. Check that you are on the campus network or VPN, and that the port in the URL is correct. |
| `Access denied for user` | The username or password in the Java file is wrong. Check for typos and make sure the quotes are still there. |
| `Unknown database 'restaurant_db'` | Either step 2 did not finish, or your database has a different name. Fix the name at the end of the URL. |
| `Table '...waiter' doesn't exist` | The tables were not created. Run `Script.sql` again and check the Output panel for red errors. |
| `Public Key Retrieval is not allowed` | Add `?allowPublicKeyRetrieval=true&useSSL=false` to the end of the URL, for example `.../restaurant_db?allowPublicKeyRetrieval=true&useSSL=false`. |
| `No suitable driver found` | The driver jar is not on the classpath. In IntelliJ, open the folder itself (not just the Java file). On the command line, run the commands from inside the project folder exactly as written. |
| `javac is not recognized` | Java is not installed or not on your PATH. Install a JDK (22 or newer) and open a new terminal. |

## The queries

Cancelled orders are left out of all sales and revenue figures.

| # | Level | What it answers |
|---|---|---|
| 1 | Simple | The full menu, grouped by category and sorted by price |
| 2 | Simple | Tables that can seat a group of 4 or more |
| 3 | Medium | Total sales and average order value for each waiter |
| 4 | Medium | Main courses priced above the menu average |
| 5 | Medium | Every customer's visits, total spend and biggest single dish line, including people who never ordered |
| 6 | Medium | Revenue per month, to plan stock and staffing |
| 7 | Complex | VIP customers whose spend is above the average customer spend |
| 8 | Complex | Slow sellers that are cheap or priced below their category average |
| 9 | Complex | Customers to win back: people who never visited, or who spent R500+ but have not been in for over 30 days |
| 10 | Complex | The best-selling dish in each menu category |

The full SQL and the reason behind each query are written as comments in `Script.sql`.

## Testing

We tested everything on MySQL 8.0:

* `Script.sql` runs from start to finish without errors, and all 10 queries return the row counts listed above.
* `Tests.sql` passes all 22 tests. 11 of them confirm that the CHECK, UNIQUE, PRIMARY KEY, FOREIGN KEY and NOT NULL constraints reject bad data. The other 11 compare row counts and revenue totals with values we worked out by hand.
* The Java program connects and prints every result set. We also tried it with a wrong password, which gives a clear connection error, and with one broken query, which is reported while the other 9 still run.

The sample data includes one cancelled order on purpose, so we could check that it is left out of every sales and revenue figure.
