/*
=============================================================================
Banking Risk and Fraud Analytics Dashboard - SQL Backend
Author: Harsh Kumar Aman
=============================================================================
*/

-- 1. Database & Schema Setup
CREATE DATABASE IF NOT EXISTS Fraud_Analytics;
USE Fraud_Analytics;

DROP TABLE IF EXISTS raw_transactions;
CREATE TABLE raw_transactions (
    transaction_id VARCHAR(100),
    timestamp DATETIME,
    customer_id VARCHAR(100),
    card_id VARCHAR(100),
    device_id VARCHAR(100),
    ip_address VARCHAR(100),
    merchant_id VARCHAR(100),
    merchant_category VARCHAR(100),
    merchant_country VARCHAR(100),
    merchant_city VARCHAR(100),
    merchant_latitude DECIMAL(10,6),
    merchant_longitude DECIMAL(10,6),
    transaction_type VARCHAR(100),
    amount DECIMAL(12,2),
    currency VARCHAR(10),
    is_fraud INT,
    fraud_type VARCHAR(100)
);

-- 2. Feature Engineering: Customer Risk Profile
CREATE VIEW customer_risk_summary AS
SELECT 
    customer_id,
    COUNT(transaction_id) AS total_transactions,
    SUM(amount) AS total_spent,
    AVG(amount) AS average_transaction_value
FROM raw_transactions
GROUP BY customer_id;

-- 3. Exploratory Data Analysis (EDA)

-- Identify the top 10 highest-spending customers
SELECT * 
FROM customer_risk_summary 
ORDER BY total_spent DESC 
LIMIT 10;

-- Calculate the overall dataset fraud rate
SELECT 
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_fraud_cases,
    (SUM(is_fraud) / COUNT(*)) * 100 AS fraud_percentage
FROM raw_transactions;

-- Isolate the riskiest merchant categories
SELECT 
    merchant_category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_cases
FROM raw_transactions
GROUP BY merchant_category
ORDER BY fraud_cases DESC;

-- Investigate high-value transaction anomalies (> $500)
SELECT 
    transaction_id, 
    customer_id, 
    merchant_category, 
    amount,
    is_fraud
FROM raw_transactions 
WHERE amount > 500 
ORDER BY amount DESC;

-- 4. Final Executive KPI Calculations for Power BI
SELECT 
    COUNT(transaction_id) AS total_transactions,
    SUM(is_fraud) AS total_fraud_cases,
    SUM(CASE WHEN is_fraud = 1 THEN amount ELSE 0 END) AS total_money_lost,
    (SUM(is_fraud) / COUNT(transaction_id)) * 100 AS fraud_rate_percentage
FROM raw_transactions;