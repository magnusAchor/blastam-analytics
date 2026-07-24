/*
==========================================================
BlastAm Analytics Portfolio Project
File: 05_dashboard_views.sql
Purpose: Dashboard Views
Author: Magnus Achor
==========================================================

Description:
This script creates reusable SQL views that power the
BlastAm Tableau dashboard.

These views simplify dashboard development by exposing
business-ready datasets.

==========================================================
*/

----------------------------------------------------------
-- VIEW 1 : Dashboard Summary
----------------------------------------------------------

CREATE OR REPLACE VIEW dashboard_summary AS

SELECT

    (SELECT COUNT(*) FROM public.players) AS total_players,

    (SELECT COUNT(*) FROM public.sessions) AS total_sessions,

    (SELECT COUNT(*) FROM public.purchases) AS total_purchases,

    (SELECT COUNT(DISTINCT player_id)
     FROM public.purchases) AS paying_players,

    (SELECT ROUND(SUM(amount_usd),2)
     FROM public.purchases) AS total_revenue,

    (SELECT ROUND(AVG(duration_minutes),2)
     FROM public.sessions) AS average_session_minutes,

    (SELECT ROUND(AVG(amount_usd),2)
     FROM public.purchases) AS average_purchase_value;

----------------------------------------------------------
-- VIEW 2 : Monthly Revenue
----------------------------------------------------------

CREATE OR REPLACE VIEW monthly_revenue AS

SELECT

    DATE_TRUNC('month', purchase_date) AS month,

    COUNT(*) AS purchases,

    ROUND(SUM(amount_usd),2) AS revenue

FROM public.purchases

GROUP BY month

ORDER BY month;

----------------------------------------------------------
-- VIEW 3 : Monthly Player Signups
----------------------------------------------------------

CREATE OR REPLACE VIEW monthly_signups AS

SELECT

    DATE_TRUNC('month', signup_date) AS month,

    COUNT(*) AS new_players

FROM public.players

GROUP BY month

ORDER BY month;

----------------------------------------------------------
-- VIEW 4 : Revenue by Country
----------------------------------------------------------

CREATE OR REPLACE VIEW revenue_by_country AS

SELECT

    c.country_name,

    COUNT(*) AS purchases,

    ROUND(SUM(p.amount_usd),2) AS revenue

FROM public.purchases p

JOIN public.players pl

ON p.player_id = pl.player_id

JOIN public.countries c

ON pl.country_id = c.country_id

GROUP BY c.country_name

ORDER BY revenue DESC;

----------------------------------------------------------
-- VIEW 5 : Revenue by Platform
----------------------------------------------------------

CREATE OR REPLACE VIEW revenue_by_platform AS

SELECT

    pl.platform,

    COUNT(*) AS purchases,

    ROUND(SUM(p.amount_usd),2) AS revenue

FROM public.purchases p

JOIN public.players pl

ON p.player_id = pl.player_id

GROUP BY pl.platform

ORDER BY revenue DESC;

----------------------------------------------------------
-- VIEW 6 : Weapon Popularity
----------------------------------------------------------

CREATE OR REPLACE VIEW weapon_popularity AS

SELECT

    w.weapon_name,

    w.weapon_type,

    COUNT(*) AS owners

FROM public.player_weapons pw

JOIN public.weapons w

ON pw.weapon_id = w.weapon_id

GROUP BY

    w.weapon_name,

    w.weapon_type

ORDER BY owners DESC;

----------------------------------------------------------
-- VIEW 7 : Player Segments
----------------------------------------------------------

CREATE OR REPLACE VIEW player_segments AS

SELECT

    player_id,

    highest_level,

    CASE

        WHEN highest_level <= 10 THEN 'Beginner'

        WHEN highest_level <= 20 THEN 'Intermediate'

        WHEN highest_level <= 35 THEN 'Advanced'

        ELSE 'Expert'

    END AS player_segment

FROM(

SELECT

    player_id,

    MAX(level_number) AS highest_level

FROM public.levels

GROUP BY player_id

)x;

----------------------------------------------------------
-- VIEW 8 : Top Players
----------------------------------------------------------

CREATE OR REPLACE VIEW top_players AS

SELECT

    pl.player_id,

    pl.username,

    COUNT(*) AS purchases,

    ROUND(SUM(p.amount_usd),2) AS lifetime_value

FROM public.players pl

JOIN public.purchases p

ON pl.player_id = p.player_id

GROUP BY

    pl.player_id,

    pl.username

ORDER BY lifetime_value DESC

LIMIT 100;

----------------------------------------------------------
-- VIEW 9 : Daily Active Users
----------------------------------------------------------

CREATE OR REPLACE VIEW daily_active_users AS

SELECT

    DATE(login_time) AS activity_date,

    COUNT(DISTINCT player_id) AS active_players

FROM public.sessions

GROUP BY activity_date

ORDER BY activity_date;

----------------------------------------------------------
-- VIEW 10 : Monthly Active Users
----------------------------------------------------------

CREATE OR REPLACE VIEW monthly_active_users AS

SELECT

    DATE_TRUNC('month', login_time) AS month,

    COUNT(DISTINCT player_id) AS active_players

FROM public.sessions

GROUP BY month

ORDER BY month;

----------------------------------------------------------
-- VIEW 11 : Level Progression
----------------------------------------------------------

CREATE OR REPLACE VIEW level_progression AS

SELECT

    level_number,

    COUNT(DISTINCT player_id) AS players_completed

FROM public.levels

GROUP BY level_number

ORDER BY level_number;

----------------------------------------------------------
-- VIEW 12 : Platform Distribution
----------------------------------------------------------

CREATE OR REPLACE VIEW platform_distribution AS

SELECT

    platform,

    COUNT(*) AS players

FROM public.players

GROUP BY platform

ORDER BY players DESC;

----------------------------------------------------------
-- VIEW 13 : Country Distribution
----------------------------------------------------------

CREATE OR REPLACE VIEW country_distribution AS

SELECT

    c.country_name,

    COUNT(*) AS players

FROM public.players p

JOIN public.countries c

ON p.country_id = c.country_id

GROUP BY c.country_name

ORDER BY players DESC;

----------------------------------------------------------
-- VIEW 14 : Dashboard Validation
----------------------------------------------------------

-- View names created:
--
-- dashboard_summary
-- monthly_revenue
-- monthly_signups
-- revenue_by_country
-- revenue_by_platform
-- weapon_popularity
-- player_segments
-- top_players
-- daily_active_users
-- monthly_active_users
-- level_progression
-- platform_distribution
-- country_distribution
--
-- These views are intended for Tableau
-- and Power BI dashboards.
