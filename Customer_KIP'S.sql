USE customer_purchasing; 

DESCRIBE customer_data;


--- What is the total revenue and average purchase?
SELECT 
    COUNT(*)                                 AS total_customers, 
    ROUND(SUM(`Purchase Amount (USD)`), 2)   AS total_revenue, 
    ROUND(AVG(`Purchase Amount (USD)`), 2)   AS avg_purchase, 
    MIN(`Purchase Amount (USD)`)             AS min_purchase, 
    MAX(`Purchase Amount (USD)`)             AS max_purchase 
FROM customer_data;


--- What is total revenue and customer count by product category?
SELECT 
    Category,
    COUNT(*) AS customer_count,
    ROUND(SUM(`Purchase Amount (USD)`), 0) AS total_revenue,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_purchase,
    ROUND(
        SUM(`Purchase Amount (USD)`) * 100.0 / (SELECT SUM(`Purchase Amount (USD)`) FROM customer_data), 
        1
    ) AS revenue_share_pct
FROM customer_data
GROUP BY Category
ORDER BY total_revenue DESC;


--- What is revenue and average purchase by season?
SELECT
    `Season`,
    COUNT(*)                                       AS total_customers,
    ROUND(SUM(`Purchase Amount (USD)`), 0)         AS total_revenue,
    ROUND(AVG(`Purchase Amount (USD)`), 2)         AS avg_purchase,
    ROUND(MAX(`Purchase Amount (USD)`), 2)         AS max_purchase
FROM customer_data
GROUP BY `Season`
ORDER BY total_revenue DESC;


--- Do subscribers spend more than non-subscribers?
SELECT
    `Subscription Status`,
    COUNT(*)                                     AS customers,
    -- Calculates percentage of total (using 3900 as your total denominator)
    ROUND(COUNT(*) * 100.0 / 3900, 1)            AS pct_of_total,
    ROUND(AVG(`Purchase Amount (USD)`), 2)       AS avg_purchase,
    ROUND(SUM(`Purchase Amount (USD)`), 0)       AS total_revenue,
    ROUND(AVG(`Previous Purchases`), 2)          AS avg_prev_purchases
FROM customer_data
GROUP BY `Subscription Status`
ORDER BY `Subscription Status` DESC;


--- What is revenue by age group?
SELECT
    CASE 
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 34 THEN '18-34'
        WHEN Age BETWEEN 35 AND 50 THEN '35-50'
        ELSE '50+' 
    END AS age_group,
    COUNT(*)                                       AS customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2)         AS avg_purchase,
    ROUND(SUM(`Purchase Amount (USD)`), 0)         AS total_revenue,
    ROUND(AVG(`Previous Purchases`), 2)            AS avg_loyalty
FROM customer_data
GROUP BY 
    CASE 
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 34 THEN '18-34'
        WHEN Age BETWEEN 35 AND 50 THEN '35-50'
        ELSE '50+' 
    END
ORDER BY age_group;


--- Does using a discount increase purchase amounts?
SELECT
    `Discount Applied`,
    COUNT(*)                                     AS customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2)       AS avg_purchase,
    ROUND(SUM(`Purchase Amount (USD)`), 0)       AS total_revenue,
    ROUND(AVG(`Previous Purchases`), 2)          AS avg_loyalty,
    ROUND(AVG(CASE WHEN `Subscription Status` = 'Yes' THEN 1 ELSE 0 END), 3) AS pct_subscribers
FROM customer_data
GROUP BY `Discount Applied`
ORDER BY `Discount Applied` DESC;


--- What is the Customer Value Score segment analysis?
SELECT
    value_segment,
    COUNT(*)                                     AS customers,
    ROUND(AVG(calc_score), 3)                    AS avg_cvs,
    ROUND(AVG(`Purchase Amount (USD)`), 2)       AS avg_purchase,
    ROUND(AVG(`Previous Purchases`), 2)          AS avg_loyalty,
    ROUND(AVG(freq_order), 1)                    AS avg_freq_order,
    ROUND(SUM(`Purchase Amount (USD)`), 0)       AS total_revenue
FROM (
    SELECT 
        `Purchase Amount (USD)`, 
        `Previous Purchases`,
        -- Rename the calculation to avoid the duplicate name error
        (`Purchase Amount (USD)` + (`Previous Purchases` * 10)) AS calc_score,
        CASE 
            WHEN (`Purchase Amount (USD)` + (`Previous Purchases` * 10)) > 500 THEN 'High Value'
            WHEN (`Purchase Amount (USD)` + (`Previous Purchases` * 10)) BETWEEN 200 AND 500 THEN 'Mid Value'
            ELSE 'Low Value'
        END AS value_segment,
        (`Previous Purchases` + 1) AS freq_order
    FROM customer_data
) AS segmented_data
GROUP BY value_segment
ORDER BY avg_cvs DESC;


--- What is category performance by season (Cross-dimensional)?
SELECT
    Category,
    Season,
    COUNT(*)                                       AS customers,
    ROUND(SUM(`Purchase Amount (USD)`), 0)         AS total_revenue,
    ROUND(AVG(`Purchase Amount (USD)`), 2)         AS avg_purchase
FROM customer_data
GROUP BY Category, Season
ORDER BY Category, total_revenue DESC;


--- What is the promo engagement segment analysis?
SELECT
    promo_engagement,
    COUNT(*)                                     AS customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2)       AS avg_purchase,
    ROUND(AVG(`Previous Purchases`), 2)          AS avg_loyalty,
    ROUND(SUM(`Purchase Amount (USD)`), 0)       AS total_revenue
FROM customer_data
GROUP BY promo_engagement
ORDER BY avg_purchase DESC;