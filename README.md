# Retail Banking Transactions Analysis (MySQL)

SQL project analyzing a retail bank's customers, accounts, transactions, cards and loans to uncover customer segments, channel usage, loan repayment risk and cross-sell opportunities.

## Project Goal

Answer 58 business questions across five areas:

- **Customers:** segments, income, credit scores, KYC status
- **Accounts:** types, balances, branch and region performance
- **Transactions:** types, channels, failure rates, month-over-month trends
- **Loans:** types, outstanding balances, late payments, penalties
- **Cards:** credit limits, outstanding balances, reward points, networks

## Tool

MySQL 8.0 (any MySQL client works: Workbench, DBeaver, CLI)

## Database Schema (7 tables)

| Table | Description | Linked to |
|---|---|---|
| `customers` | Customer profile, segment, income, credit score | none (parent) |
| `branches` | Branch location, region, employee count | none (parent) |
| `accounts` | Account type, balance, interest rate, status | customers, branches |
| `transactions` | Every transaction with channel, amount, status | accounts |
| `cards` | Card type, credit limit, outstanding balance | accounts |
| `loans` | Loan type, principal, EMI, status | customers, branches |
| `loan_payments` | Payment history, days late, penalties | loans |

## SQL Concepts Used

- Aggregations: `GROUP BY`, `HAVING`
- Joins across multiple tables
- Subqueries and `NOT EXISTS`
- CTEs
- Window functions: `RANK`, `DENSE_RANK`, `LAG`, running totals with `SUM() OVER`
- `CASE WHEN` bucketing

## How to Run

1. Install MySQL 8.0.
2. Run `retail-banking-sql-analysis.sql`. It creates the `retail_banking` database and all 7 tables.
3. Load your data into the tables.
4. Run queries Q1 to Q58 one by one.

## Repository Structure

```text
.
├── README.md
└── retail-banking-sql-analysis.sql
```
