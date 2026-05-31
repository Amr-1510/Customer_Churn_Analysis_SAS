# Customer Churn Analysis — SAS Project

A full end-to-end customer churn analysis pipeline built in SAS, covering data import, exploratory analysis, visualization, data cleaning, feature engineering, and predictive modeling using Logistic Regression.

---

## Project Structure

```
DsToolsProj.sas
│
├── 1. Data Import
├── 2. Exploratory Data Analysis (EDA)
├── 3. Visualizations
├── 4. Data Cleaning
├── 5. Feature Engineering
└── 6. Model Building & Evaluation
```

---

## Dataset

**File:** `final_churn_project_data.csv`

**Key Variables:**

| Variable | Type | Description |
|---|---|---|
| `CustomerID` | Numeric | Unique customer identifier |
| `Age` | Numeric | Customer age |
| `Gender` | Categorical | Male / Female |
| `Tenure` | Numeric | Months as a customer |
| `Usage Frequency` | Numeric | How often the service is used |
| `Support Calls` | Numeric | Number of support calls made |
| `Payment Delay` | Numeric | Days of payment delay |
| `Total Spend` | Numeric | Total amount spent |
| `Last Interaction` | Numeric | Days since last interaction |
| `Subscription Type` | Categorical | Basic / Standard / Premium |
| `Contract Length` | Categorical | Monthly / Quarterly / Annual |
| `Churn` | Categorical (Target) | Yes / No |

---

## Pipeline Steps

### 1. Data Import
- Imports the CSV file into a SAS work dataset (`work.churn_data`) using `PROC IMPORT`.

### 2. Exploratory Data Analysis (EDA)
- **Dataset structure** — variable names and types via `PROC CONTENTS`
- **Data preview** — first 10 rows via `PROC PRINT`
- **Missing values check** — counts via `PROC MEANS`
- **Summary statistics** — mean, median, Q1, Q3, min, max, std for all numeric variables
- **Frequency distributions** — for Gender, Subscription Type, Contract Length, and Churn
- **Correlation matrix** — among all numeric variables
- **Group comparison** — average numeric values segmented by Churn status

### 3. Visualizations
13 plots covering outlier detection and churn pattern analysis:

| Plot | Description |
|---|---|
| Boxplots (×7) | Outlier detection for Age, Tenure, Usage Frequency, Support Calls, Payment Delay, Total Spend, Last Interaction |
| Plot 1 | Overall Churn Distribution (bar chart) |
| Plot 2 | Age Distribution by Churn (histogram + KDE) |
| Plot 3 | Tenure by Churn (boxplot) |
| Plot 4 | Contract Length vs Churn (clustered bar) |
| Plot 5 | Subscription Type vs Churn (stacked bar) |
| Plot 6 | Support Calls by Churn (boxplot) |
| Plot 7 | Payment Delay vs Support Calls (scatter + regression line) |
| Plot 8 | Churn Rate by Tenure Decile (line + band chart) |
| Plot 9 | Heatmap: Support Calls × Payment Delay vs Churn Rate |
| Plot 10 | Usage Frequency Density by Churn (KDE) |
| Plot 11 | Gender vs Churn (clustered bar) |
| Plot 12 | Subscription Type Distribution (pie chart) |
| Plot 13 | Mean Comparison across Key Variables by Churn |
| Plot 17 | Subscription Type vs Churn — Paneled by Contract Length |

### 4. Data Cleaning
1. **Duplicate row removal** — fully duplicate rows dropped via `PROC SORT NODUPKEY`
2. **Duplicate CustomerID removal** — keeping one record per customer
3. **Invalid value detection** — flags negative values and out-of-range ages (< 0 or > 100) and Total Spend > 10,000
4. **Gender standardization** — normalizes `F/M/FEMALE/MALE` to `Female/Male`; unrecognized values set to missing
5. **Median imputation** — missing values in `Age` and `Total Spend` replaced with their medians
6. **Mode imputation** — missing `Gender` values replaced with the most frequent category
7. **Outlier capping (IQR method)** — Age and Total Spend capped at Q1 − 1.5×IQR and Q3 + 1.5×IQR

### 5. Feature Engineering
New variables derived from the cleaned dataset:

| Feature | Formula | Description |
|---|---|---|
| `Engagement_Score` | `Usage Frequency / Tenure` | Measures usage intensity over time |
| `Problem_Ratio` | `Support Calls / (Usage Frequency + 1)` | Ratio of problems to usage |
| `Sub_Score` | 1 / 2 / 3 | Ordinal encoding of Subscription Type (Basic → Premium) |
| `Contract_Score` | 1 / 2 / 3 | Ordinal encoding of Contract Length (Monthly → Annual) |
| `Gender_Female` | 0 or 1 | One-hot encoding for Female |
| `Gender_Male` | 0 or 1 | One-hot encoding for Male |
| `Churn_Num` | 0 or 1 | Binary encoding of target variable |

### 6. Model Building & Evaluation

**Train/Test Split:** 70% training / 30% test (random uniform split)

**Model:** Logistic Regression (`PROC LOGISTIC`) with stepwise variable selection

**Predictors used:**
- Age, Tenure, Usage Frequency, Engagement Score, Problem Ratio
- Total Spend, Last Interaction, Support Calls, Payment Delay
- Sub Score, Contract Score

**Evaluation:**
- Confusion Matrix (`PROC FREQ` on actual vs predicted)
- Baseline comparison of key variables by churn group
- Summary table of actual vs predicted churn by Total Spend and Tenure
- ROC Curve (via `PLOTS(ONLY)=ROC`)
- Model fit statistics (`FITSTAT`)

---

## How to Run

1. Open SAS Studio or SAS Enterprise Guide.
2. Place `final_churn_project_data.csv` at `/home/u64509879/` (or update the `DATAFILE` path in the `PROC IMPORT` step).
3. Run `DsToolsProj.sas` in its entirety.
4. Results and plots will appear in the SAS output and results panels.

---

## Requirements

- SAS 9.4 or SAS Studio (University Edition or higher)
- Input file: `final_churn_project_data.csv`
- No additional macros or external libraries required
