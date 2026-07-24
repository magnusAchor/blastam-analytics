/*
==========================================================
BlastAm Analytics Portfolio Project
File: 04_revenue_analytics.sql
Purpose: Revenue & Monetization Analysis
Author: Magnus Achor
==========================================================

Description:
This script analyzes the monetization performance of
BlastAm. It measures revenue trends, spending behavior,
top customers, platform performance, country performance,
and purchasing patterns.

==========================================================
*/

----------------------------------------------------------
-- SECTION 1: REVENUE OVERVIEW
----------------------------------------------------------

-- Total Revenue
SELECT
    ROUND(SUM(amount_usd), 2) AS total_revenue
FROM public.purchases;

-- Total Purchases
SELECT
    COUNT(*) AS total_purchases
FROM public.purchases;

-- Average Purchase Value
SELECT
    ROUND(AVG(amount_usd), 2) AS average_purchase_value
FROM public.purchases;

----------------------------------------------------------
-- SECTION 2: MONTHLY REVENUE
----------------------------------------------------------

SELECT
    DATE_TRUNC('month', purchase_date) AS month,
    COUNT(*) AS purchases,
    ROUND(SUM(amount_usd), 2) AS revenue
FROM public.purchases
GROUP BY month
ORDER BY month;

----------------------------------------------------------
-- SECTION 3: DAILY REVENUE
----------------------------------------------------------

SELECT
    DATE(purchase_date) AS purchase_day,
    COUNT(*) AS purchases,
    ROUND(SUM(amount_usd), 2) AS revenue
FROM public.purchases
GROUP BY purchase_day
ORDER BY purchase_day;

----------------------------------------------------------
-- SECTION 4: REVENUE BY PLATFORM
----------------------------------------------------------

SELECT
    pl.platform,
    COUNT(*) AS purchases,
    ROUND(SUM(p.amount_usd), 2) AS revenue,
    ROUND(AVG(p.amount_usd), 2) AS average_purchase
FROM public.purchases p
JOIN public.players pl
    ON p.player_id = pl.player_id
GROUP BY pl.platform
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 5: REVENUE BY COUNTRY
----------------------------------------------------------

SELECT
    c.country_name,
    COUNT(*) AS purchases,
    ROUND(SUM(p.amount_usd), 2) AS revenue
FROM public.purchases p
JOIN public.players pl
    ON p.player_id = pl.player_id
JOIN public.countries c
    ON pl.country_id = c.country_id
GROUP BY c.country_name
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 6: REVENUE BY GENDER
----------------------------------------------------------

SELECT
    pl.gender,
    COUNT(*) AS purchases,
    ROUND(SUM(p.amount_usd), 2) AS revenue
FROM public.purchases p
JOIN public.players pl
    ON p.player_id = pl.player_id
GROUP BY pl.gender
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 7: REVENUE BY AGE
----------------------------------------------------------

SELECT
    pl.age,
    COUNT(*) AS purchases,
    ROUND(SUM(p.amount_usd), 2) AS revenue
FROM public.purchases p
JOIN public.players pl
    ON p.player_id = pl.player_id
GROUP BY pl.age
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 8: TOP SPENDING PLAYERS
----------------------------------------------------------

SELECT
    pl.player_id,
    pl.username,
    COUNT(*) AS purchases,
    ROUND(SUM(p.amount_usd), 2) AS lifetime_value
FROM public.players pl
JOIN public.purchases p
    ON pl.player_id = p.player_id
GROUP BY
    pl.player_id,
    pl.username
ORDER BY lifetime_value DESC
LIMIT 20;

----------------------------------------------------------
-- SECTION 9: PURCHASE FREQUENCY
----------------------------------------------------------

SELECT
    purchases,
    COUNT(*) AS players
FROM (
    SELECT
        player_id,
        COUNT(*) AS purchases
    FROM public.purchases
    GROUP BY player_id
) purchase_summary
GROUP BY purchases
ORDER BY purchases;

----------------------------------------------------------
-- SECTION 10: PLAYER SPENDING SEGMENTS
----------------------------------------------------------

SELECT
    CASE
        WHEN lifetime_value < 20 THEN 'Low Spender'
        WHEN lifetime_value < 75 THEN 'Medium Spender'
        WHEN lifetime_value < 150 THEN 'High Spender'
        ELSE 'Whale'
    END AS spending_segment,
    COUNT(*) AS players,
    ROUND(AVG(lifetime_value), 2) AS average_ltv
FROM (
    SELECT
        player_id,
        SUM(amount_usd) AS lifetime_value
    FROM public.purchases
    GROUP BY player_id
) spending
GROUP BY spending_segment
ORDER BY average_ltv;

----------------------------------------------------------
-- SECTION 11: PURCHASE PRICE DISTRIBUTION
----------------------------------------------------------

SELECT
    amount_usd,
    COUNT(*) AS purchases
FROM public.purchases
GROUP BY amount_usd
ORDER BY amount_usd;

----------------------------------------------------------
-- SECTION 12: TOP REVENUE COUNTRIES
----------------------------------------------------------

SELECT
    c.country_name,
    ROUND(SUM(p.amount_usd), 2) AS revenue
FROM public.purchases p
JOIN public.players pl
    ON p.player_id = pl.player_id
JOIN public.countries c
    ON pl.country_id = c.country_id
GROUP BY c.country_name
ORDER BY revenue DESC
LIMIT 10;

----------------------------------------------------------
-- SECTION 13: TOP REVENUE PLATFORMS
----------------------------------------------------------

SELECT
    pl.platform,
    ROUND(SUM(p.amount_usd), 2) AS revenue
FROM public.purchases p
JOIN public.players pl
    ON p.player_id = pl.player_id
GROUP BY pl.platform
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 14: TOP REVENUE DAYS
----------------------------------------------------------

SELECT
    DATE(purchase_date) AS purchase_day,
    ROUND(SUM(amount_usd), 2) AS revenue
FROM public.purchases
GROUP BY purchase_day
ORDER BY revenue DESC
LIMIT 10;

----------------------------------------------------------
-- SECTION 15: BUSINESS INSIGHTS
----------------------------------------------------------

-- This script answers:
--
-- • How much revenue did the game generate?
-- • Which countries generate the most revenue?
-- • Which platform spends the most?
-- • What is the average purchase value?
-- • Who are the highest-value players?
-- • How are players distributed by spending level?
-- • Which purchase amounts are most common?
-- • Which days and months generate the most revenue?
--
-- These analyses support pricing strategy,
-- regional expansion,
-- platform optimization,
-- customer segmentation,
-- and monetization improvements.
