# 🚚 Quick Commerce Logistics Execution Engine
### **End-to-End Data Analytics Project: From Raw Data to Actionable Insights**

---

## **📌 Project Overview**
This project simulates and analyzes the operational data of a **Quick Commerce** platform (modeled after services like Blinkit or Zepto). The core objective was to build a robust system to track logistics performance, identify root causes for delivery delays (SLA Breaches), and analyze customer sentiment across various "Dark Stores" in **Gurugram**.

---

## **🛠 Tech Stack & Tools**
* **Python**: Used for initial data generation and synthetic dataset creation.
* **SQL (MySQL/PostgreSQL)**: Performed complex ETL processes and standardized 20+ variations of Gurugram area names (e.g., "Sec 45", "Sector-45").
* **Power BI**: Developed a comprehensive 3-page interactive dashboard for executive and operational stakeholders.
* **DAX**: Engineered custom measures to track key metrics like SLA Breach % and Sentiment scores.

---

## **📊 Dashboard Highlights**

### **1. Executive Overview (Page 1)**
* **Key KPIs**: Monitored Total Revenue (**$12.89M**), SLA Breach (**36%**), Customer Satisfaction (**14%**), and total Order Volume (**9950**).
* **Revenue Trajectory**: A combined visual showing daily order volume and revenue trends over time.
* **Regional Performance**: Detailed revenue breakdown for major areas including **Sector 45**, **Cyber Hub**, and **Sohna Road**.

### **2. Logistics Deep-Dive & Root Cause Analysis (Page 2)**
* **Root Cause Breakdown**: Utilized a **Decomposition Tree** to trace delivery delays back to specific regions and sentiment groups.
* **Operational Bottlenecks**: Analyzed the "Prep vs. Transit" efficiency to determine if delays were caused by store preparation issues or rider transit delays.
* **Efficiency Matrix**: A scatter plot identifying store performance against "Target Prep" and "Target Transit" benchmarks.

### **3. Customer Experience & Sentiment Analytics (Page 3)**
* **Sentiment Split**: A visual breakdown showing Positive (**66.95%**), Negative (**26.46%**), and Neutral feedback.
* **Voice of the Customer**: A **Word Cloud** highlighting the most frequent keywords in reviews, such as "Late," "Poor," and "Fast".
* **Satisfaction Forecast**: Integrated time-series forecasting to predict future customer sentiment trends based on historical performance.

---

## **💡 Technical Problem Solving**

### **The "Delivery Lag" Formula**
To accurately measure operational efficiency, I implemented a custom logic to track delays beyond the promised 10-minute window:

$$Delivery\_Lag = (Prep\_Time + Transit\_Time) - 10 \text{ minutes}$$

### **Data Standardization**
Resolved significant data quality issues in SQL by ensuring the `Actual_Time` was a consistent sum of preparation and transit times, creating a **"Single Source of Truth"** for all reporting.

### **Advanced UI/UX Features**
Designed a **Collapsible Slicer Panel** and a **Navigation Sidebar** using Power BI Bookmarks and the Selection Pane. This allows users to filter by `Area_Name` or `Date` without reducing the space available for data visualizations.

---

## **📈 Key Business Insights**
* **Operational Discovery**: In **Sector 45**, the primary cause of delivery lag is high **Preparation Time** (kitchen efficiency) rather than rider transit.
* **Traffic Trends**: **Cyber Hub** shows increased transit times during specific peak hours, suggesting a need for route optimization or localized rider clusters.
* **Service Impact**: There is a direct correlation between **SLA Breaches** and **Negative Customer Sentiment**, proving that delivery speed is the highest priority for the customer base.
