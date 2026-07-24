/*
==========================================================
BlastAm Analytics Portfolio Project
File: 06_data_quality.sql
Purpose: Data Quality Validation
Author: Magnus Achor
==========================================================

Description:
This script validates the integrity of the BlastAm dataset.

Checks include:
• Duplicate primary keys
• NULL values
• Orphan records
• Invalid values
• Date validation
• Business rule validation

Run this script before creating dashboards or reports.

==========================================================
*/

----------------------------------------------------------
-- SECTION 1 : ROW COUNTS
----------------------------------------------------------

SELECT 'players' AS table_name, COUNT(*) AS rows FROM public.players
UNION ALL
SELECT 'sessions', COUNT(*) FROM public.sessions
UNION ALL
SELECT 'levels', COUNT(*) FROM public.levels
UNION ALL
SELECT 'player_weapons', COUNT(*) FROM public.player_weapons
UNION ALL
SELECT 'purchases', COUNT(*) FROM public.purchases
UNION ALL
SELECT 'countries', COUNT(*) FROM public.countries
UNION ALL
SELECT 'weapons', COUNT(*) FROM public.weapons;

----------------------------------------------------------
-- SECTION 2 : DUPLICATE PRIMARY KEYS
----------------------------------------------------------

-- Players
SELECT
    player_id,
    COUNT(*)
FROM public.players
GROUP BY player_id
HAVING COUNT(*) > 1;

-- Sessions
SELECT
    session_id,
    COUNT(*)
FROM public.sessions
GROUP BY session_id
HAVING COUNT(*) > 1;

-- Purchases
SELECT
    purchase_id,
    COUNT(*)
FROM public.purchases
GROUP BY purchase_id
HAVING COUNT(*) > 1;

----------------------------------------------------------
-- SECTION 3 : NULL VALUE CHECKS
----------------------------------------------------------

-- Players
SELECT *
FROM public.players
WHERE
    player_id IS NULL
    OR username IS NULL
    OR signup_date IS NULL;

-- Sessions
SELECT *
FROM public.sessions
WHERE
    session_id IS NULL
    OR player_id IS NULL
    OR login_time IS NULL
    OR logout_time IS NULL;

-- Purchases
SELECT *
FROM public.purchases
WHERE
    purchase_id IS NULL
    OR player_id IS NULL
    OR purchase_date IS NULL
    OR amount_usd IS NULL;

----------------------------------------------------------
-- SECTION 4 : ORPHAN RECORDS
----------------------------------------------------------

-- Sessions without players
SELECT COUNT(*) AS orphan_sessions
FROM public.sessions s
LEFT JOIN public.players p
ON s.player_id = p.player_id
WHERE p.player_id IS NULL;

-- Purchases without players
SELECT COUNT(*) AS orphan_purchases
FROM public.purchases pu
LEFT JOIN public.players p
ON pu.player_id = p.player_id
WHERE p.player_id IS NULL;

-- Levels without players
SELECT COUNT(*) AS orphan_levels
FROM public.levels l
LEFT JOIN public.players p
ON l.player_id = p.player_id
WHERE p.player_id IS NULL;

-- Player weapons without players
SELECT COUNT(*) AS orphan_weapon_records
FROM public.player_weapons pw
LEFT JOIN public.players p
ON pw.player_id = p.player_id
WHERE p.player_id IS NULL;

----------------------------------------------------------
-- SECTION 5 : INVALID VALUES
----------------------------------------------------------

-- Negative Session Duration
SELECT *
FROM public.sessions
WHERE duration_minutes < 0;

-- Zero Session Duration
SELECT *
FROM public.sessions
WHERE duration_minutes = 0;

-- Negative Purchases
SELECT *
FROM public.purchases
WHERE amount_usd <= 0;

-- Invalid Levels
SELECT *
FROM public.levels
WHERE level_number < 1
   OR level_number > 50;

----------------------------------------------------------
-- SECTION 6 : DATE VALIDATION
----------------------------------------------------------

-- Logout before Login
SELECT *
FROM public.sessions
WHERE logout_time < login_time;

-- Purchase before Signup
SELECT
    pu.player_id,
    pl.signup_date,
    pu.purchase_date
FROM public.purchases pu
JOIN public.players pl
ON pu.player_id = pl.player_id
WHERE pu.purchase_date < pl.signup_date;

-- Level before Signup
SELECT
    l.player_id,
    pl.signup_date,
    l.completed_at
FROM public.levels l
JOIN public.players pl
ON l.player_id = pl.player_id
WHERE l.completed_at < pl.signup_date;

----------------------------------------------------------
-- SECTION 7 : BUSINESS RULES
----------------------------------------------------------

-- Players without Sessions
SELECT COUNT(*) AS players_without_sessions
FROM public.players
WHERE player_id NOT IN
(
    SELECT DISTINCT player_id
    FROM public.sessions
);

-- Players without Levels
SELECT COUNT(*) AS players_without_levels
FROM public.players
WHERE player_id NOT IN
(
    SELECT DISTINCT player_id
    FROM public.levels
);

-- Players without Weapons
SELECT COUNT(*) AS players_without_weapons
FROM public.players
WHERE player_id NOT IN
(
    SELECT DISTINCT player_id
    FROM public.player_weapons
);

-- Players without Purchases
SELECT COUNT(*) AS non_paying_players
FROM public.players
WHERE player_id NOT IN
(
    SELECT DISTINCT player_id
    FROM public.purchases
);

----------------------------------------------------------
-- SECTION 8 : REVENUE VALIDATION
----------------------------------------------------------

SELECT
    COUNT(*) AS purchases,
    ROUND(SUM(amount_usd),2) AS revenue,
    ROUND(AVG(amount_usd),2) AS average_purchase,
    ROUND(MAX(amount_usd),2) AS highest_purchase,
    ROUND(MIN(amount_usd),2) AS lowest_purchase
FROM public.purchases;

----------------------------------------------------------
-- SECTION 9 : SESSION VALIDATION
----------------------------------------------------------

SELECT
    COUNT(*) AS sessions,
    ROUND(AVG(duration_minutes),2) AS average_duration,
    MAX(duration_minutes) AS longest_session,
    MIN(duration_minutes) AS shortest_session
FROM public.sessions;

----------------------------------------------------------
-- SECTION 10 : LEVEL VALIDATION
----------------------------------------------------------

SELECT
    MIN(level_number) AS minimum_level,
    MAX(level_number) AS maximum_level,
    ROUND(AVG(level_number),2) AS average_level
FROM public.levels;

----------------------------------------------------------
-- SECTION 11 : DATA QUALITY SUMMARY
----------------------------------------------------------

/*
Expected Results

✔ No duplicate primary keys

✔ No orphan records

✔ No NULL values in required fields

✔ No negative revenue

✔ No negative session duration

✔ No logout before login

✔ No purchases before signup

✔ Level numbers between 1 and 50

✔ Foreign keys remain valid

If every validation passes, the dataset is ready
for analytics and dashboard development.

==========================================================
END OF FILE
==========================================================
*/
