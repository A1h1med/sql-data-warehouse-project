# Sales Analysis From ERP And CRM Sources 

## Project Overview
This project includes an end-to-end ETL process that extracts data from multiple source systems, including ERP and CRM platforms, using SQL for data extraction, cleansing, and transformation. The processed data is then integrated into a centralized data model to support analytics and reporting.
Additionally, I developed an interactive dashboard that provides insights into sales performance, customer behavior, and business trends, enabling data-driven decision-making through clear visualizations and key performance indicators (KPIs).

🏗️ Data Architecture
The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers: Data Architecture

Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics.

## Tools
- Power BI : for visualisation 
- SQL : for ETL process
  
##📂 Repository Structure
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── data_flow.png                   # Draw.io file for the data flow diagram
│   ├── star schema.png                 # Draw.io file for data models (star schema)
│   ├── integration model.png           # how tables are related to each other 
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions

## Projcet Preview
<img width="2726" height="1497" alt="Sales Full journey" src="https://github.com/user-attachments/assets/c5f73745-94e2-4392-8771-0fb8bb1c4f39" />

## Key Insights
- Australia and the United States have the longest delivery delays compared to the expected delivery date.
- Sales peaked in 2013 and declined in 2014.
- The United States generated the highest number of orders.


