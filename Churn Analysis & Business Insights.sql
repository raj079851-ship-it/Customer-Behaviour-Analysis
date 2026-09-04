----------------------------------------------Churn Analysis---------------------------------------------------
----- 1. Count churned vs non-churned customers

SELECT 
    churn,
    COUNT(*) AS customer_count
FROM customer
GROUP BY churn
ORDER BY churn;

----- 2. Overall Customer Churn Rate

SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END) AS churned_customers,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate_percentage
FROM customer;

----- 3. Churn Rate by Gender

SELECT
    gender,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END) AS churned_customers,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate_percentage
FROM customer
GROUP BY gender
ORDER BY churn_rate_percentage DESC;

----- 4. Churn Rate by Product Category

SELECT
    product_category,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END) AS churned_customers,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate_percentage
FROM customer
GROUP BY product_category
ORDER BY churn_rate_percentage DESC;

----- 5. Churn Rate by Payment Method

SELECT
    payment_method,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END) AS churned_customers,
    ROUND(
        100.0 * COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate_percentage
FROM customer
GROUP BY payment_method
ORDER BY churn_rate_percentage DESC;

----- 6. Churn Rate by Age Group

SELECT
    CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN customer_age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 1 THEN customer_id
    END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate_percentage

FROM customer

GROUP BY age_group

ORDER BY churn_rate_percentage DESC;

----- 7. Churned vs Non-Churned Customer Spending

SELECT
    churn,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(AVG(total_purchase_amount), 2) AS avg_transaction_amount,
    ROUND(SUM(total_purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY churn
ORDER BY churn;

----- 8. Monthly Churn Trend

SELECT
    DATE_TRUNC('month', purchase_date) AS purchase_month,

    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN churn = 1 THEN customer_id
    END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE WHEN churn = 1 THEN customer_id END)
        / COUNT(DISTINCT customer_id),
        2
    ) AS churn_rate_percentage

FROM customer

GROUP BY DATE_TRUNC('month', purchase_date)

ORDER BY purchase_month;

----- 9. Churn Rate Based on Purchase Frequency

WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(*) AS purchase_frequency,
        MAX(churn) AS churn
    FROM customer
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN purchase_frequency = 1 THEN 'One-Time Customer'
        WHEN purchase_frequency BETWEEN 2 AND 5 THEN 'Low Frequency'
        WHEN purchase_frequency BETWEEN 6 AND 10 THEN 'Medium Frequency'
        ELSE 'High Frequency'
    END AS customer_type,

    COUNT(*) AS customers,

    COUNT(CASE WHEN churn = 1 THEN 1 END) AS churned_customers,

    ROUND(
        100.0 *
        COUNT(CASE WHEN churn = 1 THEN 1 END)
        / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM customer_frequency

GROUP BY customer_type

ORDER BY churn_rate_percentage DESC;

----- 10. Identify High-Value Churned Customers

SELECT
    customer_id,
    COUNT(*) AS purchase_frequency,
    ROUND(SUM(total_purchase_amount), 2) AS total_spending,
    ROUND(AVG(total_purchase_amount), 2) AS avg_purchase_amount,
    MAX(purchase_date) AS last_purchase_date
FROM customer
WHERE churn = 1
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 20;

------------------------------------ Business Insights ------------------------------------------
-- 1. Which product category generates the most revenue?
SELECT
    product_category,
    COUNT(*) AS total_transactions,
    ROUND(SUM(total_purchase_amount), 2) AS total_revenue,
    ROUND(AVG(total_purchase_amount), 2) AS avg_purchase_amount
FROM customer
GROUP BY product_category
ORDER BY total_revenue DESC;

-- 2. Which product category has the highest average spending?

SELECT
    product_category,
    ROUND(AVG(total_purchase_amount), 2) AS avg_purchase_amount,
    ROUND(AVG(product_price), 2) AS avg_product_price
FROM customer
GROUP BY product_category
ORDER BY avg_purchase_amount DESC;

-- 3. What is the monthly revenue trend?

SELECT
    DATE_TRUNC('month', purchase_date) AS month,
    COUNT(*) AS transactions,
    ROUND(SUM(total_purchase_amount), 2) AS revenue
FROM customer
GROUP BY DATE_TRUNC('month', purchase_date)
ORDER BY month;

-- 4. Which payment method is most preferred?
SELECT
    payment_method,
    COUNT(*) AS transactions,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS usage_percentage,
    ROUND(SUM(total_purchase_amount), 2) AS revenue
FROM customer
GROUP BY payment_method
ORDER BY transactions DESC;

-- 5. Which age group generates the most revenue?
SELECT
    CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN customer_age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,

    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(total_purchase_amount), 2) AS total_revenue,
    ROUND(AVG(total_purchase_amount), 2) AS avg_purchase
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;

-- 6. Which gender contributes more revenue?

SELECT
    gender,
    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(total_purchase_amount), 2) AS total_revenue,
    ROUND(AVG(total_purchase_amount), 2) AS avg_purchase
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;

-- 7. What is the return rate by product category?

SELECT
    product_category,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN returns = 1 THEN 1 ELSE 0 END) AS returned_transactions,

    ROUND(
        100.0 * SUM(CASE WHEN returns = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS return_rate_percentage

FROM customer
GROUP BY product_category
ORDER BY return_rate_percentage DESC;

-- 8. Identify the top 20 highest-value customers

SELECT
    customer_id,
    COUNT(*) AS purchase_frequency,
    ROUND(SUM(total_purchase_amount), 2) AS total_spending,
    ROUND(AVG(total_purchase_amount), 2) AS avg_purchase_amount,
    MAX(purchase_date) AS last_purchase_date
FROM customer
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 20;

-- 9. Compare one-time and repeat customers

WITH customer_summary AS (
    SELECT
        customer_id,
        COUNT(*) AS purchase_frequency,
        SUM(total_purchase_amount) AS total_spending,
        MAX(churn) AS churn
    FROM customer
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN purchase_frequency = 1
        THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    COUNT(*) AS customers,

    ROUND(AVG(total_spending), 2) AS avg_customer_spending,

    ROUND(AVG(purchase_frequency), 2) AS avg_purchase_frequency,

    ROUND(
        100.0 * SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate

FROM customer_summary
GROUP BY customer_type;

-- 10. Identify high-value customers at risk of churn

SELECT
    customer_id,
    COUNT(*) AS purchase_frequency,
    ROUND(SUM(total_purchase_amount), 2) AS total_spending,
    MAX(purchase_date) AS last_purchase_date,
    MAX(churn) AS churn_status
FROM customer
GROUP BY customer_id
HAVING MAX(churn) = 1
ORDER BY total_spending DESC
LIMIT 20;