/*
==========================================================
BlastAm Analytics Portfolio Project
File: 02_kpis.sql
Purpose: Key Performance Indicators (KPIs)
Author: Magnus Achor
==========================================================

Description:
This script calculates the core business KPIs used to
measure player engagement, gameplay activity,
and monetization performance.

==========================================================
*/

----------------------------------------------------------
-- SECTION 1: PLAYER KPIs
----------------------------------------------------------

-- KPI: Total Registered Players
SELECT
    COUNT(*) AS total_players
FROM public.players;

-- KPI: Active Players
SELECT
    COUNT(DISTINCT player_id) AS active_players
FROM public.sessions;

-- KPI: Paying Players
SELECT
    COUNT(DISTINCT player_id) AS paying_players
FROM public.purchases;

-- KPI: Paying User Rate (%)
SELECT
    ROUND(
        COUNT(DISTINCT player_id) * 100.0 /
        (SELECT COUNT(*) FROM public.players),
        2
    ) AS paying_user_percentage
FROM public.purchases;

----------------------------------------------------------
-- SECTION 2: ENGAGEMENT KPIs
----------------------------------------------------------

-- KPI: Total Sessions
SELECT
    COUNT(*) AS total_sessions
FROM public.sessions;

-- KPI: Average Sessions Per Player
SELECT
    ROUND(
        COUNT(*)::NUMERIC /
        COUNT(DISTINCT player_id),
        2
    ) AS average_sessions_per_player
FROM public.sessions;

-- KPI: Average Session Length (Minutes)
SELECT
    ROUND(AVG(duration_minutes), 2) AS average_session_minutes
FROM public.sessions;

-- KPI: Total Gameplay Time (Minutes)
SELECT
    SUM(duration_minutes) AS total_minutes_played
FROM public.sessions;

----------------------------------------------------------
-- SECTION 3: REVENUE KPIs
----------------------------------------------------------

-- KPI: Total Revenue
SELECT
    ROUND(SUM(amount_usd), 2) AS total_revenue
FROM public.purchases;

-- KPI: Average Purchase Value
SELECT
    ROUND(AVG(amount_usd), 2) AS average_purchase_value
FROM public.purchases;

-- KPI: ARPU (Average Revenue Per User)
SELECT
    ROUND(
        SUM(amount_usd) /
        (SELECT COUNT(*) FROM public.players),
        2
    ) AS arpu
FROM public.purchases;

-- KPI: ARPPU (Average Revenue Per Paying User)
SELECT
    ROUND(
        SUM(amount_usd) /
        COUNT(DISTINCT player_id),
        2
    ) AS arppu
FROM public.purchases;

-- KPI: Top 10 Highest Lifetime Value Players
SELECT
    player_id,
    COUNT(*) AS purchases,
    ROUND(SUM(amount_usd), 2) AS lifetime_value
FROM public.purchases
GROUP BY player_id
ORDER BY lifetime_value DESC
LIMIT 10;

----------------------------------------------------------
-- SECTION 4: GAMEPLAY KPIs
----------------------------------------------------------

-- KPI: Average Highest Level Reached
SELECT
    ROUND(AVG(highest_level), 2) AS average_highest_level
FROM (
    SELECT
        player_id,
        MAX(level_number) AS highest_level
    FROM public.levels
    GROUP BY player_id
) AS player_levels;

-- KPI: Percentage of Players Reaching Level 50
SELECT
    ROUND(
        COUNT(DISTINCT player_id) * 100.0 /
        (SELECT COUNT(*) FROM public.players),
        2
    ) AS level_50_completion_rate
FROM public.levels
WHERE level_number = 50;

-- KPI: Average Weapons Owned Per Player
SELECT
    ROUND(AVG(total_weapons), 2) AS average_weapons_owned
FROM (
    SELECT
        player_id,
        COUNT(*) AS total_weapons
    FROM public.player_weapons
    GROUP BY player_id
) AS player_weapons;

----------------------------------------------------------
-- SECTION 5: BUSINESS KPIs
----------------------------------------------------------

-- KPI: Revenue by Platform
SELECT
    pl.platform,
    ROUND(SUM(pu.amount_usd), 2) AS revenue
FROM public.purchases pu
JOIN public.players pl
    ON pu.player_id = pl.player_id
GROUP BY pl.platform
ORDER BY revenue DESC;

-- KPI: Top 10 Revenue-Generating Countries
SELECT
    c.country_name,
    ROUND(SUM(pu.amount_usd), 2) AS revenue
FROM public.purchases pu
JOIN public.players pl
    ON pu.player_id = pl.player_id
JOIN public.countries c
    ON pl.country_id = c.country_id
GROUP BY c.country_name
ORDER BY revenue DESC
LIMIT 10;

----------------------------------------------------------
-- SECTION 6: SUMMARY
----------------------------------------------------------

-- This file provides the key metrics required for
-- executive reporting and dashboard KPI cards.
--
-- Metrics Included:
-- • Total Players
-- • Active Players
-- • Paying Players
-- • Paying User Rate
-- • Total Sessions
-- • Average Sessions Per Player
-- • Average Session Length
-- • Total Gameplay Time
-- • Total Revenue
-- • Average Purchase Value
-- • ARPU
-- • ARPPU
-- • Top Lifetime Value Players
-- • Average Highest Level
-- • Level 50 Completion Rate
-- • Average Weapons Owned
-- • Revenue by Platform
-- • Top Revenue Countries
--
-- These KPIs will be reused in the Tableau dashboard
-- and project documentation.
