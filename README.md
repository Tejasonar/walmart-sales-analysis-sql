# walmart-sales-analysis-sql
# walmart sales data analysis using mysql

## project overview
this project focuses on analyzing walmart retail sales data using mysql to
understand sales performance, customer behavior, and product trends.
the analysis helps identify revenue drivers, high-performing products,
customer segments, and time-based sales patterns.

---

## dataset
- source: walmart sales dataset (kaggle)
- format: csv file
- records: ~1000 rows
  
---

## tools & technologies
- mysql
- mysql workbench
- sql

---

## data loading
the dataset was downloaded from kaggle in csv format.
the `sales` table was created manually using sql.
data was imported into mysql using the **table data import wizard**
available in mysql workbench.
after importing, row counts and null value checks were performed to
validate data integrity.

---

## data wrangling
- verified row counts after data import
- checked for null values across all columns
- ensured correct data types for numerical, date, and time columns

---

## feature engineering
the following derived columns were created to support time-based analysis:
- `time_of_day` (morning, afternoon, evening)
- `day_name` (monday to sunday)
- `month_name` (january to december)

these features helped analyze sales and ratings patterns over time.

---

### analysis performed
### generic analysis
### product analysis
### sales analysis
### customer analysis


## key sql concepts used
- `group by` and aggregate functions
- subqueries
- `case when` logic
- date and time functions
- feature engineering using sql
- data validation queries

---

## business insights
- identified high-revenue cities and branches
- analyzed customer segments contributing most to revenue
- found peak sales times and high-rated time periods
- highlighted top-performing and underperforming product lines
