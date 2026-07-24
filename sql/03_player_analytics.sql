/*
==========================================================
BlastAm Analytics Portfolio Project
File: 03_player_analytics.sql
Purpose: Player Behavior & Segmentation Analysis
Author: Magnus Achor
==========================================================

Description:
This script analyzes player demographics, engagement,
progression, gameplay behavior, and spending habits to
identify valuable player segments and opportunities for
game improvement.

==========================================================
*/

----------------------------------------------------------
-- SECTION 1: PLAYER DISTRIBUTION
----------------------------------------------------------

-- Players by Country
SELECT
    c.country_name,
    COUNT(*) AS total_players
FROM public.players p
JOIN public.countries c
    ON p.country_id = c.country_id
GROUP BY c.country_name
ORDER BY total_players DESC;

-- Players by Platform
SELECT
    platform,
    COUNT(*) AS total_players
FROM public.players
GROUP BY platform
ORDER BY total_players DESC;

-- Gender Distribution
SELECT
    gender,
    COUNT(*) AS total_players
FROM public.players
GROUP BY gender
ORDER BY total_players DESC;

-- Age Distribution
SELECT
    age,
    COUNT(*) AS players
FROM public.players
GROUP BY age
ORDER BY age;

----------------------------------------------------------
-- SECTION 2: PLAYER ENGAGEMENT
----------------------------------------------------------

-- Sessions Per Player
SELECT
    p.player_id,
    p.username,
    COUNT(s.session_id) AS total_sessions
FROM public.players p
JOIN public.sessions s
    ON p.player_id = s.player_id
GROUP BY
    p.player_id,
    p.username
ORDER BY total_sessions DESC
LIMIT 20;

-- Average Session Duration Per Player
SELECT
    p.player_id,
    p.username,
    ROUND(AVG(s.duration_minutes),2) AS average_session_duration
FROM public.players p
JOIN public.sessions s
    ON p.player_id = s.player_id
GROUP BY
    p.player_id,
    p.username
ORDER BY average_session_duration DESC
LIMIT 20;

----------------------------------------------------------
-- SECTION 3: PLAYER PROGRESSION
----------------------------------------------------------

-- Highest Level Reached By Player
SELECT
    p.player_id,
    p.username,
    MAX(l.level_number) AS highest_level
FROM public.players p
JOIN public.levels l
    ON p.player_id = l.player_id
GROUP BY
    p.player_id,
    p.username
ORDER BY highest_level DESC
LIMIT 20;

-- Level Completion Distribution
SELECT
    level_number,
    COUNT(DISTINCT player_id) AS players_completed
FROM public.levels
GROUP BY level_number
ORDER BY level_number;

----------------------------------------------------------
-- SECTION 4: PLAYER SPENDING
----------------------------------------------------------

-- Top 20 Highest Spending Players
SELECT
    p.player_id,
    p.username,
    COUNT(pu.purchase_id) AS purchases,
    ROUND(SUM(pu.amount_usd),2) AS lifetime_value
FROM public.players p
JOIN public.purchases pu
    ON p.player_id = pu.player_id
GROUP BY
    p.player_id,
    p.username
ORDER BY lifetime_value DESC
LIMIT 20;

-- Revenue by Age
SELECT
    p.age,
    ROUND(SUM(pu.amount_usd),2) AS revenue
FROM public.players p
JOIN public.purchases pu
    ON p.player_id = pu.player_id
GROUP BY p.age
ORDER BY revenue DESC;

-- Revenue by Gender
SELECT
    p.gender,
    ROUND(SUM(pu.amount_usd),2) AS revenue
FROM public.players p
JOIN public.purchases pu
    ON p.player_id = pu.player_id
GROUP BY p.gender
ORDER BY revenue DESC;

-- Revenue by Platform
SELECT
    p.platform,
    ROUND(SUM(pu.amount_usd),2) AS revenue
FROM public.players p
JOIN public.purchases pu
    ON p.player_id = pu.player_id
GROUP BY p.platform
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 5: PLAYER RETENTION PROXY
----------------------------------------------------------

-- Days Between First and Last Session
SELECT
    p.player_id,
    p.username,
    MIN(s.login_time) AS first_session,
    MAX(s.login_time) AS last_session,
    MAX(s.login_time)::date -
    MIN(s.login_time)::date AS active_days
FROM public.players p
JOIN public.sessions s
    ON p.player_id = s.player_id
GROUP BY
    p.player_id,
    p.username
ORDER BY active_days DESC
LIMIT 20;

----------------------------------------------------------
-- SECTION 6: WEAPON OWNERSHIP
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

-- Weapon Type Popularity
SELECT
    w.weapon_type,
    COUNT(*) AS total_owned
FROM public.player_weapons pw
JOIN public.weapons w
    ON pw.weapon_id = w.weapon_id
GROUP BY w.weapon_type
ORDER BY total_owned DESC;

----------------------------------------------------------
-- SECTION 7: PLAYER SEGMENTATION
----------------------------------------------------------

-- Player Segment by Highest Level
SELECT
    CASE
        WHEN highest_level <= 10 THEN 'Beginner'
        WHEN highest_level <= 20 THEN 'Intermediate'
        WHEN highest_level <= 35 THEN 'Advanced'
        ELSE 'Expert'
    END AS player_segment,
    COUNT(*) AS players
FROM (
    SELECT
        player_id,
        MAX(level_number) AS highest_level
    FROM public.levels
    GROUP BY player_id
) levels
GROUP BY player_segment
ORDER BY players DESC;

-- Player Segment by Spending
SELECT
    CASE
        WHEN lifetime_value < 20 THEN 'Low Spender'
        WHEN lifetime_value < 75 THEN 'Medium Spender'
        WHEN lifetime_value < 150 THEN 'High Spender'
        ELSE 'Whale'
    END AS spending_segment,
    COUNT(*) AS players
FROM (
    SELECT
        player_id,
        SUM(amount_usd) AS lifetime_value
    FROM public.purchases
    GROUP BY player_id
) spenders
GROUP BY spending_segment
ORDER BY players DESC;

----------------------------------------------------------
-- SECTION 8: BUSINESS INSIGHTS
----------------------------------------------------------

-- These analyses help answer questions such as:
--
-- • Which countries have the most players?
-- • Which platform has the highest engagement?
-- • Which players spend the most?
-- • Which age groups generate the highest revenue?
-- • Which weapons are most popular?
-- • How many players become Experts?
-- • How many players become Whales?
--
-- These queries support player segmentation,
-- monetization analysis, marketing strategy,
-- and game balancing decisions.
