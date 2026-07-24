/*
==========================================================
BlastAm Analytics Portfolio Project
File: 01_eda.sql
Purpose: Exploratory Data Analysis (EDA)
Author: Magnus Achor
==========================================================

Description:
This script explores the BlastAm game dataset to understand
player demographics, engagement, gameplay behavior,
weapon usage, and monetization.

==========================================================
*/

----------------------------------------------------------
-- SECTION 1: DATASET OVERVIEW
----------------------------------------------------------

-- Total Players
SELECT COUNT(*) AS total_players
FROM public.players;

-- Total Sessions
SELECT COUNT(*) AS total_sessions
FROM public.sessions;

-- Total Purchases
SELECT COUNT(*) AS total_purchases
FROM public.purchases;

-- Total Levels Completed
SELECT COUNT(*) AS total_levels_completed
FROM public.levels;

-- Total Weapons Owned
SELECT COUNT(*) AS total_weapons_owned
FROM public.player_weapons;

----------------------------------------------------------
-- SECTION 2: PLAYER DEMOGRAPHICS
----------------------------------------------------------

-- Players by Country
SELECT
    c.country_name,
    COUNT(*) AS players
FROM public.players p
JOIN public.countries c
    ON p.country_id = c.country_id
GROUP BY c.country_name
ORDER BY players DESC;

-- Players by Platform
SELECT
    platform,
    COUNT(*) AS players
FROM public.players
GROUP BY platform
ORDER BY players DESC;

-- Gender Distribution
SELECT
    gender,
    COUNT(*) AS players
FROM public.players
GROUP BY gender;

-- Average Age
SELECT
    ROUND(AVG(age), 1) AS average_age
FROM public.players;

----------------------------------------------------------
-- SECTION 3: SESSION ANALYSIS
----------------------------------------------------------

-- Average Session Length
SELECT
    ROUND(AVG(duration_minutes), 2) AS avg_session_minutes
FROM public.sessions;

-- Longest Session
SELECT
    MAX(duration_minutes) AS longest_session
FROM public.sessions;

-- Shortest Session
SELECT
    MIN(duration_minutes) AS shortest_session
FROM public.sessions;

-- Sessions Per Player
SELECT
    MIN(total_sessions) AS min_sessions,
    MAX(total_sessions) AS max_sessions,
    ROUND(AVG(total_sessions), 2) AS avg_sessions
FROM (
    SELECT
        player_id,
        COUNT(*) AS total_sessions
    FROM public.sessions
    GROUP BY player_id
) s;

----------------------------------------------------------
-- SECTION 4: LEVEL PROGRESSION
----------------------------------------------------------

-- Highest Level Reached
SELECT
    MAX(level_number) AS highest_level
FROM public.levels;

-- Average Highest Level
SELECT
    ROUND(AVG(highest_level), 2) AS average_highest_level
FROM (
    SELECT
        player_id,
        MAX(level_number) AS highest_level
    FROM public.levels
    GROUP BY player_id
) l;

-- Players Reaching Level 50
SELECT
    COUNT(DISTINCT player_id) AS players_reaching_level_50
FROM public.levels
WHERE level_number = 50;

----------------------------------------------------------
-- SECTION 5: PURCHASE ANALYSIS
----------------------------------------------------------

-- Total Revenue
SELECT
    ROUND(SUM(amount_usd), 2) AS total_revenue
FROM public.purchases;

-- Average Purchase Value
SELECT
    ROUND(AVG(amount_usd), 2) AS average_purchase_value
FROM public.purchases;

-- Paying Players
SELECT
    COUNT(DISTINCT player_id) AS paying_players
FROM public.purchases;

-- Revenue by Platform
SELECT
    pl.platform,
    ROUND(SUM(pu.amount_usd), 2) AS revenue
FROM public.purchases pu
JOIN public.players pl
    ON pu.player_id = pl.player_id
GROUP BY pl.platform
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 6: WEAPON ANALYSIS
----------------------------------------------------------

-- Most Popular Weapons
SELECT
    w.weapon_name,
    COUNT(*) AS owners
FROM public.player_weapons pw
JOIN public.weapons w
    ON pw.weapon_id = w.weapon_id
GROUP BY w.weapon_name
ORDER BY owners DESC;

-- Weapon Type Distribution
SELECT
    w.weapon_type,
    COUNT(*) AS total_owned
FROM public.player_weapons pw
JOIN public.weapons w
    ON pw.weapon_id = w.weapon_id
GROUP BY w.weapon_type;

----------------------------------------------------------
-- SECTION 7: TIME TRENDS
----------------------------------------------------------

-- Monthly Player Signups
SELECT
    DATE_TRUNC('month', signup_date) AS signup_month,
    COUNT(*) AS players
FROM public.players
GROUP BY signup_month
ORDER BY signup_month;

-- Monthly Revenue
SELECT
    DATE_TRUNC('month', purchase_date) AS revenue_month,
    ROUND(SUM(amount_usd), 2) AS revenue
FROM public.purchases
GROUP BY revenue_month
ORDER BY revenue_month;
