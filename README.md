B105 Applied Statistical Modelling individual project
# B105 Applied Statistical Modelling

## Project Overview

This project analyses customer-level revenue using the UCI Online Retail dataset.

The analysis focuses on comparing customer revenue between Germany and the United Kingdom using statistical analysis in R.

## Business Question

Is customer-level revenue significantly different between customers in Germany and the United Kingdom?

## Dataset

The dataset used for this project is the UCI Online Retail dataset.

Dataset source:

https://archive.ics.uci.edu/dataset/352/online+retail

The original dataset contains transactional information including invoice number, product code, quantity, invoice date, unit price, customer ID and country.

## Data Preparation

The analysis includes:

- Data inspection and missing-value checks
- Identification of cancellation and adjustment transactions
- Removal of non-positive quantities
- Removal of non-positive unit prices
- Calculation of transaction revenue
- Selection of Germany and the United Kingdom
- Aggregation of revenue at customer level
- Removal of records without CustomerID for the customer-level analysis
- Log transformation of customer revenue

## Statistical Analysis

The project includes:

- Descriptive statistics
- Exploratory data analysis
- Boxplot analysis
- Q-Q plots
- Shapiro-Wilk normality tests
- Variance assessment
- Welch two-sample t-test
- Confidence interval analysis
- Geometric mean revenue comparison

## Repository Contents

- `script analysis.R` — R code used for the analysis
- `customer_revenue.csv` — customer-level analytical dataset
- `figures/` — figures generated during the analysis
- `B105_Statistical_Modelling_Report.pdf` — project report

## Main Result

The analysis compares mean log-transformed customer revenue between Germany and the United Kingdom using a Welch two-sample t-test.

The statistical results and their interpretation are presented in the project report.

## Author

sunveer kaur 

B105 Applied Statistical Modelling  
GISMA University of Applied Sciences
