# E-Commerce Operational & Marketing Analytics Pipeline (MySQL)

## 📊 Project Overview
This project demonstrates the design and implementation of an end to end relational database for an e-commerce platform using **MySQL**. Instead of just querying flat files, I built a normalized schema from scratch to track transactional behaviors and solve real world business challenges.

The project applies advanced SQL techniques to clean raw data pipelines, track company financial growth, and evaluate customer retention.

---

## 🏗️ Database Architecture (3NF Schema)
The database structure is normalized to Third Normal Form (3NF) to ensure data integrity and eliminate redundancies. It consists of 4 core tables:
*   `customers`: Handles user profiles, signup dates, and regional locations.
*   `products`: Stores inventory stock counts, product categories, and baseline pricing.
*   `orders`: Tracks execution paths and transactional lifecycles (`Shipped`, `Pending`, `Cancelled`).
*   `order_items`: A bridge table resolving many-to-many relationships, documenting item quantities and snapshot unit pricing.

---

## 💻 Core Business Analysis Queries Included

### 1. Financial Analytics: Month-over-Month (MoM) Revenue Growth
* **Objective:** Determine financial stability by evaluating monthly trends.
* **SQL Skills Utilized:** Common Table Expressions (CTEs), `SUM()` aggregations, and the `LAG()` window function.
* **Business Logic:** Automatically isolates completed sales invoices while filtering out unfulfilled or cancelled items to prevent financial skew.

### 2. Marketing Analytics: RFM Behavioral Customer Segmentation
* **Objective:** Categorize users into distinct operational groups based on buying patterns.
* **SQL Skills Utilized:** Complex `CASE WHEN` logical expressions, date mathematics via `DATEDIFF()`, and historical aggregation filters (`MAX()`).
* **Segmentation Rules applied:**
    *   `VIP / Champion`: Active within the last 30 days with frequent interaction.
    *   `At-Risk`: Needs re-engagement flags based on increasing drop-off days.
    *   `Churned`: Accounts with no recorded purchase behavior in over a year.

---

## 🛠️ How to Run the Project
1. Clone this repository or download the `.sql` file.
2. Open **MySQL Workbench**.
3. Import and execute the `master_script.sql` file to completely reconstruct the database schema, insert the operational mock data, and display the analytical results dashboards.
