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
  
## Repository Structure

## 📂 Repository Structure

```text
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── data_flow.png                   # Data flow diagram
│   ├── star_schema.png                 # Star schema model
│   ├── integration_model.png           # Table relationships
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Raw data extraction and loading
│   ├── silver/                         # Data cleansing and transformation
│   ├── gold/                           # Analytical models and reporting views
│
├── tests/                              # Data quality and validation scripts
│
└── README.md                           # Project overview and instructions
```

## Projcet Preview
<img width="2726" height="1497" alt="Sales Full journey" src="https://github.com/user-attachments/assets/c5f73745-94e2-4392-8771-0fb8bb1c4f39" />

## Key Insights
- Australia and the United States have the longest delivery delays compared to the expected delivery date.
- Sales peaked in 2013 and declined in 2014.
- The United States generated the highest number of orders.

## Credits
This project was inspired in part by the following tutorial:
**Data with Baraa** 
The tutorial provided valuable guidance on data warehousing concepts and implementation approaches. While some ideas and workflows were inspired by the tutorial, the project was independently implemented, documented, and extended as part of my learning journey.




