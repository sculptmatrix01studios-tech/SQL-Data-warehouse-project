# 🚀 Project Requirements  
## Building the Data Warehouse (Data Engineering)

### Objective
Develop a modern data warehouse using **SQL Server** to consolidate sales data from multiple operational systems, enabling reliable analytical reporting and data-driven decision-making.

---

## Specifications

### Data Sources
- Import data from two operational systems: **CRM** and **ERP**
- Source data is provided as **CSV files**
- Data is ingested **without modification** in the initial (**Bronze**) layer to preserve traceability

---

### Data Quality
- Clean and standardize data before analytical consumption
- Handle common data quality issues such as:
  - Duplicates  
  - Invalid values  
  - Inconsistent formats
- Apply validation rules at **each transformation layer**

---

### Integration
- Combine CRM and ERP data into a **single analytical model**
- Use clear data modeling principles to support:
  - Joins  
  - Aggregations  
  - Reporting use cases

---

### Scope
- Focus on the **latest available data only**
- Historical tracking and **Slowly Changing Dimensions (SCD)** are **out of scope** for this project

---

### Documentation
Provide clear documentation of:
- Data flow and lineage
- Layer responsibilities (**Bronze, Silver, Gold**)
- Modeling decisions and transformations

Documentation is designed to support:
- Business users  
- Analytics teams  
- And to serve as **proof of learning and understanding**

---

# 📊 BI: Analytics & Reporting (Data Analysis)

### Objective
Develop **SQL-based analytics** to deliver detailed insights into:

- Customer Behavior  
- Product Performance  
- Sales Trends  

These insights empower stakeholders with **key business metrics**, enabling informed and strategic decision-making.
