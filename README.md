# 🛒 E-Commerce Sales & Revenue Analysis (SQL | MySQL)

## 📌 Project Overview
This project analyzes e-commerce sales data using **SQL (MySQL)** to uncover insights related to revenue performance, customer purchasing behavior, product effectiveness, order fulfillment, and revenue leakage. The goal is to translate raw transactional data into **actionable business insights** that support decision-making in sales strategy, inventory planning, and operational efficiency.

---

## 🎯 Business Objectives
- Understand overall revenue performance and trends
- Analyze customer behavior (one-time vs repeat buyers)
- Identify top-performing and underperforming products
- Evaluate order fulfillment health and cancellations
- Quantify revenue leakage and operational inefficiencies
- Provide data-driven business recommendations

---

## 🗂️ Dataset Description
The analysis is based on the following tables:

- **customers**: customer_id, first_name, last_name, gender, signup_date, region  
- **orders**: order_id, customer_id, order_date, order_status, payment_mode, order_amount  
- **order_items**: order_id, product_id, quantity, price  
- **products**: product_id, product_name, category  

> Note: `order_amount` was created as a derived metric using order_items to standardize revenue calculations across analyses.

---

## 🛠️ Tools & Skills Used
- SQL (MySQL Workbench)
- Joins, Subqueries, CTEs
- Aggregations & Window Functions
- Business Metrics & KPI Analysis
- Data Cleaning & Assumption Handling

---

## 📌 Executive Summary
The platform generates **~₹407K in total revenue**, driven primarily by **one-time buyers**, indicating strong initial purchase value but weak retention. While product demand and category performance are healthy, growth is constrained by **low repeat purchases**, **order cancellations (~₹97K revenue loss)**, and **revenue stuck in pending/processing orders**.  

The analysis highlights opportunities to grow revenue **without increasing customer acquisition**, by improving fulfillment efficiency, reducing cancellations, and converting valuable first-time buyers into repeat customers.

---

## 📊 Key Insights & Findings

### 🔹 Step 2: Revenue & Sales Performance
- Total revenue generated: **~₹407K**
- **561 out of 1000 orders** generated revenue
- Average spend per order: **~₹1,190**
- Revenue shows **seasonal patterns**
- **~₹97K revenue lost due to cancellations**
- Significant revenue stuck in *Processing* status

---

### 🔹 Step 3: Customer Purchase Behavior
- **641 out of 1000 customers** made at least one purchase
- **316 One-Time Buyers**, **108 Repeat Buyers**
- One-Time Buyers contribute more total revenue due to volume
- Average orders per customer: **1.32**
- Avg revenue per customer: **~₹1,400**
- Very small fraction of customers purchase more than 3 times

---

### 🔹 Step 4: Product & Category Performance
- Top revenue products:  
  *Headphones, Children’s Books, Loafers, Lipsticks, Mascara*
- Top revenue categories:  
  *Electronics, Apparels, Footwear, Books*
- High-volume leaders:  
  *Headphones, Hoodies, Smartphones*
- High-value but low-volume products:  
  *Gaming Consoles, Sneakers, Bluetooth Speakers*
- Worst-performing products include low-demand items like  
  *Eyeshadow Palettes, Biographies, Cheeses*

---

### 🔹 Step 5: Order Funnel & Fulfillment
- Order distribution:
  - **482 Completed**
  - **229 Processing**
  - **136 Cancelled**
- Completion rate: **~48%**
- Cancellation rate: **~14%**
- Cancellations increasing over time
- Fulfillment pipeline remains healthy, but early-stage drop-offs exist
- **~₹97K revenue lost due to cancellations**

---

### 🔹 Step 6: Advanced Insights
- A **small % of customers drive a large % of revenue**
- Top-selling products are also top revenue drivers
- Revenue leakage is measurable and actionable
- Faster order completion can unlock trapped revenue

---

## 💡 Business Recommendations

1. **Improve Customer Retention**
   - Introduce post-purchase offers and loyalty incentives
   - Focus on converting one-time buyers into repeat customers

2. **Reduce Revenue Leakage**
   - Identify and intervene on high-risk orders
   - Improve checkout and payment completion flows

3. **Optimize Product Strategy**
   - Promote high-margin, low-volume products
   - Bundle slow-moving items with top sellers

4. **Enhance Fulfillment Efficiency**
   - Reduce processing delays
   - Monitor cancellation-prone stages in the order funnel

5. **Target High-Value Customers**
   - Segment and prioritize top revenue contributors
   - Offer personalized incentives and priority services

---

## 📈 Business Value Delivered
- Quantified revenue loss due to cancellations
- Identified high-impact customer and product segments
- Highlighted operational bottlenecks
- Provided actionable insights for revenue growth and efficiency
