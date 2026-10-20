-- Project: Retail Banking Transactions Analysis
-- Tool: MySQL 8.0
-- Goal: Analyze customer segments, account activity, loan repayment risk, and card usage
-- Tables: customers, branches, accounts, transactions, cards, loans, loan_payments

DROP DATABASE IF EXISTS retail_banking;
CREATE DATABASE retail_banking;
USE retail_banking;

-- 1. Customers Table (Parent)
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(50),
    customer_since DATE,
    kyc_status VARCHAR(20),
    segment VARCHAR(30),
    annual_income DECIMAL(12,2),
    credit_score INT,
    is_active VARCHAR(3) DEFAULT 'Yes'
);

-- 2. Branches Table (Parent)
CREATE TABLE branches (
    branch_id VARCHAR(10) PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(30),
    opening_date DATE,
    employee_count INT
);

-- 3. Accounts Table (Child of Customers & Branches)
CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    branch_id VARCHAR(10) NOT NULL,
    account_type VARCHAR(30) NOT NULL,
    open_date DATE NOT NULL,
    close_date DATE,
    current_balance DECIMAL(15,2) DEFAULT 0.00,
    interest_rate DECIMAL(5,2),
    overdraft_limit DECIMAL(12,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- 4. Transactions Table (Child of Accounts)
CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_time TIME,
    transaction_type VARCHAR(30) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    channel VARCHAR(30),
    description VARCHAR(50),
    balance_after DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'Completed',
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 5. Cards Table (Child of Accounts)
CREATE TABLE cards (
    card_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    card_type VARCHAR(20) NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    credit_limit DECIMAL(12,2) DEFAULT 0.00,
    outstanding_balance DECIMAL(12,2) DEFAULT 0.00,
    reward_points INT DEFAULT 0,
    is_active VARCHAR(3) DEFAULT 'Yes',
    network VARCHAR(20),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- 6. Loans Table (Child of Customers & Branches)
CREATE TABLE loans (
    loan_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    branch_id VARCHAR(10) NOT NULL,
    loan_type VARCHAR(30) NOT NULL,
    principal_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2),
    tenure_months INT,
    disbursement_date DATE,
    maturity_date DATE,
    emi_amount DECIMAL(12,2),
    outstanding_balance DECIMAL(15,2),
    loan_status VARCHAR(30),
    purpose VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- 7. Loan Payments Table (Child of Loans)
CREATE TABLE loan_payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    loan_id VARCHAR(20) NOT NULL,
    payment_date DATE NOT NULL,
    scheduled_amount DECIMAL(12,2),
    paid_amount DECIMAL(12,2),
    principal_paid DECIMAL(12,2),
    interest_paid DECIMAL(12,2),
    penalty DECIMAL(12,2) DEFAULT 0.00,
    days_late INT DEFAULT 0,
    payment_method VARCHAR(30),
    status VARCHAR(20),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);

-- Verify table counts
SELECT 'customers' AS table_name, COUNT(*) AS total FROM customers
UNION ALL
SELECT 'branches', COUNT(*) FROM branches
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'cards', COUNT(*) FROM cards
UNION ALL
SELECT 'loans', COUNT(*) FROM loans
UNION ALL
SELECT 'loan_payments', COUNT(*) FROM loan_payments;


-- Q1. What is the total number of customers?
SELECT COUNT(*) AS total_customers 
FROM customers;

-- Q2. What is the total number of accounts?
SELECT COUNT(*) AS total_accounts 
FROM accounts;

-- Q3. What are the different account types available?
SELECT DISTINCT account_type 
FROM accounts;

-- Q4. How many customers are currently active?
SELECT COUNT(*) AS active_customers 
FROM customers 
WHERE is_active = 'Yes';

-- Q5. What are the different transaction types available?
SELECT DISTINCT transaction_type 
FROM transactions;

-- Q6. What is the total amount of completed transactions?
SELECT SUM(amount) AS total_completed_amount 
FROM transactions 
WHERE status = 'Completed';

-- Q7. What are the different loan types available?
SELECT DISTINCT loan_type 
FROM loans;

-- Q8. What is the total number of loans?
SELECT COUNT(*) AS total_loans 
FROM loans;

-- Q9. What are the different card types available?
SELECT DISTINCT card_type 
FROM cards;

-- Q10. What is the total outstanding loan balance?
SELECT SUM(outstanding_balance) AS total_outstanding_loan_balance 
FROM loans;

-- Q11. How are customers distributed across segments, 
-- and how do their income and credit scores differ?
SELECT 
    segment,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(annual_income), 2) AS avg_annual_income,
    MIN(annual_income) AS min_income,
    MAX(annual_income) AS max_income,
    ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM customers
GROUP BY segment
ORDER BY avg_annual_income DESC;

-- Q12. How many customers are there in each city?
SELECT 
    city,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

-- Q13. How are customers distributed by gender?
SELECT 
    gender,
    COUNT(*) AS total_customers
FROM customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Q14. Which customer segments have the highest average credit score?
SELECT 
    segment,
    ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM customers
GROUP BY segment
ORDER BY avg_credit_score DESC;
-- Q15. How many customers are active vs inactive?
SELECT 
    is_active,
    COUNT(*) AS total_customers
FROM customers
GROUP BY is_active;

-- Q16. How many customers have completed KYC?
SELECT 
    kyc_status,
    COUNT(*) AS total_customers
FROM customers
GROUP BY kyc_status
ORDER BY total_customers DESC;

-- Q17. Which cities have the highest average annual income?
SELECT 
    city,
    ROUND(AVG(annual_income), 2) AS avg_annual_income
FROM customers
GROUP BY city
ORDER BY avg_annual_income DESC;

-- Q18. Which customers have a credit score above 750?
SELECT 
    customer_id,
    first_name,
    last_name,
    credit_score,
    segment
FROM customers
WHERE credit_score > 750
ORDER BY credit_score DESC;

-- Q19. How many accounts are there for each account type?
SELECT 
    account_type,
    COUNT(*) AS total_accounts
FROM accounts
GROUP BY account_type
ORDER BY total_accounts DESC;

-- Q20. What is the average balance for each account type?
SELECT 
    account_type,
    ROUND(AVG(current_balance), 2) AS avg_balance
FROM accounts
GROUP BY account_type
ORDER BY avg_balance DESC;

-- Q21. Which branches have the highest number of accounts?
SELECT 
    b.branch_id,
    b.branch_name,
    b.city,
    COUNT(a.account_id) AS total_accounts
FROM branches b
JOIN accounts a 
    ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_accounts DESC;

-- Q22. What is the total balance held in each branch?
SELECT 
    b.branch_name,
    b.city,
    ROUND(SUM(a.current_balance), 2) AS total_balance
FROM branches b
JOIN accounts a 
    ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name, b.city
ORDER BY total_balance DESC;

-- Q23. How many accounts are active and closed?
SELECT 
    status,
    COUNT(*) AS total_accounts
FROM accounts
GROUP BY status;

-- Q24. What is the average interest rate for each account type?
SELECT 
    account_type,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM accounts
GROUP BY account_type
ORDER BY avg_interest_rate DESC;

-- Q25. Which customers have more than one account?
SELECT 
    customer_id,
    COUNT(account_id) AS total_accounts
FROM accounts
GROUP BY customer_id
HAVING COUNT(account_id) > 1
ORDER BY total_accounts DESC;

-- Q26. Which transaction types are most common?
SELECT 
    transaction_type,
    COUNT(*) AS total_transactions
FROM transactions
GROUP BY transaction_type
ORDER BY total_transactions DESC;

-- Q27. Which channels are used most frequently?
SELECT 
    channel,
    COUNT(*) AS total_transactions
FROM transactions
GROUP BY channel
ORDER BY total_transactions DESC;

-- Q28. What is the total transaction amount for each transaction type? (completed only)
SELECT 
    transaction_type,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
WHERE status = 'Completed'
GROUP BY transaction_type
ORDER BY total_amount DESC;

-- Q29. What is the average transaction amount for each channel?
SELECT 
    channel,
    ROUND(AVG(amount), 2) AS avg_transaction_amount
FROM transactions
WHERE status = 'Completed'
GROUP BY channel
ORDER BY avg_transaction_amount DESC;

-- Q30. What are the top 10 largest transactions?
SELECT 
    transaction_id,
    account_id,
    transaction_type,
    amount,
    channel,
    transaction_date
FROM transactions
WHERE status = 'Completed'
ORDER BY amount DESC
LIMIT 10;

-- Q31. How are transactions distributed by status?
SELECT 
    status,
    COUNT(*) AS total_transactions
FROM transactions
GROUP BY status;

-- Q32. Which accounts have the highest transaction activity?
SELECT 
    account_id,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS total_transaction_amount
FROM transactions
WHERE status = 'Completed'
GROUP BY account_id
ORDER BY total_transactions DESC
LIMIT 10;

-- Q33. How many loans are there for each loan type?
SELECT 
    loan_type,
    COUNT(*) AS total_loans
FROM loans
GROUP BY loan_type
ORDER BY total_loans DESC;

-- Q34. What is the average loan amount for each loan type?
SELECT 
    loan_type,
    ROUND(AVG(principal_amount), 2) AS avg_loan_amount
FROM loans
GROUP BY loan_type
ORDER BY avg_loan_amount DESC;

-- Q35. What is the total outstanding balance for each loan type?
SELECT 
    loan_type,
    ROUND(SUM(outstanding_balance), 2) AS total_outstanding
FROM loans
GROUP BY loan_type
ORDER BY total_outstanding DESC;

-- Q36. How many loans are there for each loan status?
SELECT 
    loan_status,
    COUNT(*) AS total_loans
FROM loans
GROUP BY loan_status;

-- Q37. Which loans have repayment delays?
SELECT 
    payment_id,
    loan_id,
    payment_date,
    scheduled_amount,
    paid_amount,
    days_late,
    penalty
FROM loan_payments
WHERE days_late > 0
ORDER BY days_late DESC;

-- Q38. Which loan types have the highest average payment delay?
SELECT 
    l.loan_type,
    ROUND(AVG(lp.days_late), 2) AS avg_days_late
FROM loans l
JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY l.loan_type
ORDER BY avg_days_late DESC;

-- Q39. What is the total penalty collected for each loan type?
SELECT 
    l.loan_type,
    ROUND(SUM(lp.penalty), 2) AS total_penalty
FROM loans l
JOIN loan_payments lp
    ON l.loan_id = lp.loan_id
GROUP BY l.loan_type
ORDER BY total_penalty DESC;

-- Q40. Which payment methods are most commonly used?
SELECT 
    payment_method,
    COUNT(*) AS total_payments
FROM loan_payments
GROUP BY payment_method
ORDER BY total_payments DESC;

-- Q41. How many cards are there for each card type?
SELECT 
    card_type,
    COUNT(*) AS total_cards
FROM cards
GROUP BY card_type
ORDER BY total_cards DESC;

-- Q42. What is the average credit limit for each card type?
SELECT 
    card_type,
    ROUND(AVG(credit_limit), 2) AS avg_credit_limit
FROM cards
GROUP BY card_type
ORDER BY avg_credit_limit DESC;

-- Q43. Which cards have the highest outstanding balances?
SELECT 
    card_id,
    account_id,
    card_type,
    credit_limit,
    outstanding_balance
FROM cards
ORDER BY outstanding_balance DESC
LIMIT 10;
-- Q44. How many active and inactive cards are there?
SELECT 
    is_active,
    COUNT(*) AS total_cards
FROM cards
GROUP BY is_active;

-- Q45. Which card networks are most commonly used?
SELECT 
    network,
    COUNT(*) AS total_cards
FROM cards
GROUP BY network
ORDER BY total_cards DESC;

-- Q46. Which card types generate the most reward points?
SELECT 
    card_type,
    SUM(reward_points) AS total_reward_points,
    ROUND(AVG(reward_points), 2) AS avg_reward_points
FROM cards
GROUP BY card_type
ORDER BY total_reward_points DESC;

-- Q47. Which customers use accounts, cards, and loans?
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COUNT(DISTINCT ca.card_id) AS total_cards,
    COUNT(DISTINCT l.loan_id) AS total_loans
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN cards ca
    ON a.account_id = ca.account_id
LEFT JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name
HAVING 
    COUNT(DISTINCT a.account_id) > 0
    AND COUNT(DISTINCT ca.card_id) > 0
    AND COUNT(DISTINCT l.loan_id) > 0
ORDER BY total_accounts DESC;

-- Q48. How many customers use all three products (account, card, and loan)?
SELECT COUNT(*) AS customers_using_all_three_products
FROM (
    SELECT 
        c.customer_id
    FROM customers c
    LEFT JOIN accounts a
        ON c.customer_id = a.customer_id
    LEFT JOIN cards ca
        ON a.account_id = ca.account_id
    LEFT JOIN loans l
        ON c.customer_id = l.customer_id
    GROUP BY c.customer_id
    HAVING 
        COUNT(DISTINCT a.account_id) > 0
        AND COUNT(DISTINCT ca.card_id) > 0
        AND COUNT(DISTINCT l.loan_id) > 0
) AS product_users;

-- Q49. [CTE + LAG] What is the month-over-month growth in completed transaction value?
WITH monthly AS (
    SELECT 
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(amount) AS total_amount
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
)
SELECT 
    month,
    ROUND(total_amount, 2) AS total_amount,
    ROUND(
        (total_amount - LAG(total_amount) OVER (ORDER BY month))
        / LAG(total_amount) OVER (ORDER BY month) * 100, 2
    ) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- Q50. [CTE + running total] What is the cumulative transaction value over time?
WITH monthly AS (
    SELECT 
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(amount) AS total_amount
    FROM transactions
    WHERE status = 'Completed'
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
)
SELECT 
    month,
    ROUND(total_amount, 2) AS monthly_amount,
    ROUND(SUM(total_amount) OVER (ORDER BY month), 2) AS running_total
FROM monthly
ORDER BY month;

-- Q51. [DENSE_RANK + PARTITION BY] Who are the top 3 customers by total balance in each segment?
SELECT * 
FROM (
    SELECT 
        c.segment,
        c.customer_id,
        c.first_name,
        c.last_name,
        ROUND(SUM(a.current_balance), 2) AS total_balance,
        DENSE_RANK() OVER (
            PARTITION BY c.segment 
            ORDER BY SUM(a.current_balance) DESC
        ) AS rnk
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    GROUP BY c.segment, c.customer_id, c.first_name, c.last_name
) ranked
WHERE rnk <= 3
ORDER BY segment, rnk;

-- Q52. [RANK] How do branches rank by total balance within their region?
SELECT 
    b.region,
    b.branch_name,
    ROUND(SUM(a.current_balance), 2) AS total_balance,
    RANK() OVER (
        PARTITION BY b.region 
        ORDER BY SUM(a.current_balance) DESC
    ) AS rank_in_region
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY b.region, b.branch_id, b.branch_name
ORDER BY b.region, rank_in_region;

-- Q53. [CTE + JOIN] Which customers earn above their segment average but have a credit score below 600?
WITH segment_avg AS (
    SELECT segment, AVG(annual_income) AS avg_income
    FROM customers
    GROUP BY segment
)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.segment,
    c.annual_income,
    c.credit_score
FROM customers c
JOIN segment_avg s ON c.segment = s.segment
WHERE c.annual_income > s.avg_income
  AND c.credit_score < 600
ORDER BY c.annual_income DESC;

-- Q54. [CASE WHEN] How are loan payments distributed by delay bucket?
SELECT 
    CASE 
        WHEN days_late = 0 THEN '1. On time'
        WHEN days_late <= 30 THEN '2. 1-30 days late'
        WHEN days_late <= 90 THEN '3. 31-90 days late'
        ELSE '4. 90+ days late'
    END AS delay_bucket,
    COUNT(*) AS total_payments,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_payments
FROM loan_payments
GROUP BY delay_bucket
ORDER BY delay_bucket;

-- Q55. [CASE WHEN] What is the failed transaction rate by channel?
SELECT 
    channel,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS failure_rate_pct
FROM transactions
GROUP BY channel
ORDER BY failure_rate_pct DESC;

-- Q56. [Subquery / NOT EXISTS] Which active accounts have no card? (cross-sell opportunity)
SELECT 
    a.account_id,
    a.customer_id,
    a.account_type,
    a.current_balance
FROM accounts a
WHERE a.status = 'Active'
  AND NOT EXISTS (
      SELECT 1 FROM cards ca WHERE ca.account_id = a.account_id
  )
ORDER BY a.current_balance DESC;

 -- Q57. [CTE + AVG OVER] Which transactions are unusually large (more than 3x the account's own average)?
WITH txn_with_avg AS (
    SELECT 
        transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        amount,
        AVG(amount) OVER (PARTITION BY account_id) AS account_avg_amount
    FROM transactions
    WHERE status = 'Completed'
)
SELECT 
    transaction_id,
    account_id,
    transaction_date,
    transaction_type,
    amount,
    ROUND(account_avg_amount, 2) AS account_avg_amount,
    ROUND(amount / account_avg_amount, 2) AS times_above_avg
FROM txn_with_avg
WHERE amount > 3 * account_avg_amount
ORDER BY times_above_avg DESC
LIMIT 20;

-- Q58. [SUM OVER, partitioned] What is the cumulative amount paid on each loan over time?
SELECT 
    loan_id,
    payment_date,
    paid_amount,
    SUM(paid_amount) OVER (
        PARTITION BY loan_id 
        ORDER BY payment_date
    ) AS cumulative_paid
FROM loan_payments
ORDER BY loan_id, payment_date
LIMIT 100;

 
 








