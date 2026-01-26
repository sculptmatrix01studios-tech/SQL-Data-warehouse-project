📘 Walkthrough — Data Warehouse Project (Learning Process)
🎯 Purpose of This Walkthrough

This Walkthrough section is intentionally designed to show my learning process step by step, not just the final polished SQL scripts.

Instead of only presenting “clean” end results, this section focuses on:

🧠 How I thought about the problem

🛠️ How scripts evolved over time

📝 Why certain decisions were made

💬 Heavy inline comments for clarity and learning context

Many scripts here are more verbose and more commented than production-ready code on purpose — the goal is understanding, not brevity.

⚠️ Important Note (Please Read)

The ! Walkthrough -- folder is documentation- and learning-focused

You may find additional or more optimized scripts in folders outside this walkthrough (e.g. /Scripts, /Tests)

Those external scripts represent final or cleaner versions, while this walkthrough shows how I got there

👉 Think of this folder as a learning journal + technical narrative, not just a code dump.

🧭 How to Navigate This Walkthrough (Start Here)

This walkthrough follows a strict linear execution order.
Each step builds context and dependency for the next one.

If you are a recruiter or reviewer, follow this order 👇

📂 Walkthrough Index (Recommended Reading Order)
0️⃣ Introduction

📁 Introduction/

Start here to understand:

What a Data Warehouse is

Core concepts used in this project

High-level mental model before touching SQL

Files include:

Data Warehouse concepts

Visual explanations

Text + markdown versions

1️⃣ Requirements Analysis

📁 1st - Requirements Analysis/

Focus:

Business context

Ownership of data

What problem the warehouse is solving

What the business expects from analytics

This step answers “WHY are we building this?”

2️⃣ Design Data Architecture

📁 2nd - Design Data Architecture/

Focus:

High-level architecture

Source systems (CRM / ERP)

Data flow direction

Bronze → Silver → Gold design choice

This step answers “HOW should the system look?”

3️⃣ Project Initialization

📁 3rd - Project Initialization/

Focus:

Environment setup

Folder structure

Naming conventions

Initial project scaffolding

This step answers “HOW do we start clean?”

4️⃣ Build Bronze Layer

📁 4th - Build Bronze Layer/

Focus:

Raw ingestion from source systems

Minimal transformation

Preserving source fidelity

Includes:

Data flow diagrams

Source analysis

Scripts for ingestion

Validation mindset

This step answers “HOW do we safely land raw data?”

5️⃣ Build Silver Layer

📁 5th - Build Silver Layer/

This is the most detailed learning section.

📁 Scripts/ is organized table by table, in execution order:

1st table silver.crm_cust_info

2nd table silver.crm_prd_info

3rd table silver.sls_sales_details

4th table silver.erp_cust_az12

5th table silver.erp_loc_a101

6th table silver.erp_px_cat_g1v2

Why this structure?

Each script depends on understanding from the previous one

Each folder explains:

Business logic

Transformations

Edge cases

Data quality checks

Also included:

DDL scripts

Load procedures

Data flow & transformation visuals

This step answers “HOW do we clean, standardize, and prepare data?”

6️⃣ Build Gold Layer

📁 6th - Built Gold Layer/

Focus:

Analytics-ready models

Facts vs Dimensions

Star schema logic

Business consumption layer

Scripts are grouped by:

Dimensions

Facts

This step answers “HOW do we make data usable for BI & analytics?”

🧠 Why This Walkthrough Matters

This project is not only about SQL syntax.

It demonstrates:

Data engineering thinking

Dependency awareness

Documentation discipline

Ability to explain technical work clearly

Real-world warehouse design patterns

The walkthrough shows how I learned, not just what I built.

📌 Final Tip for Reviewers

If you want:

Final scripts → check /Scripts

Learning process & reasoning → start in ! Walkthrough --

Architecture understanding → diagrams + walkthrough folders
