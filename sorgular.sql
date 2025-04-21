USE ONSIDE;

INSERT INTO Fav_Teams(fav_ID,person_ID,team_ID,team_name) VALUES
(123,1,1,"Galatasaray"),
(2321,1,4,"Trabzonspor"),
(3334,1,21,"Real Madrid"),
(4643,1,41,"Arsenal"),
(5634346,1,83,"Bayer Leverkusen");  -- adminlerin fav teams ekleyememesi

-- -----------------------

INSERT INTO Fav_Teams (fav_ID, person_ID, team_ID, team_name) VALUES
(419491, 7, 1, "Galatasaray");

-- kişi listesine aynı takımı bir daha ekleyemiyor.

-- ------------------------

INSERT INTO users(person_ID, is_active)
VALUES (1, TRUE); -- admin, user olamaz

INSERT INTO admins (person_ID , is_super_admin)
VALUES (8,TRUE);  -- user, admin olamaz

-- ------------------------------

SELECT
    t.team_name,
    SUM(IF(t.team_ID = m.home_team_ID, m.home_score, 0)) + SUM(IF(t.team_ID = m.away_team_ID, m.away_score, 0)) AS total_goals
FROM Team t
JOIN Matches m ON t.team_ID = m.home_team_ID OR t.team_ID = m.away_team_ID
GROUP BY t.team_name
ORDER BY total_goals DESC    
LIMIT 5;     -- en fazla gol atan ilk 5  takımı listeler

-- -------------------------

SELECT a.*
FROM Matches a
INNER JOIN Matches b ON a.match_date = b.match_date AND a.start_time = b.start_time AND a.match_ID != b.match_ID;  -- aynı tarih ve aynı saatte oynanan maçları listeler (self join)


-- ---------------------

WITH PlayerAges AS (
    SELECT
        player_ID,
        player_name,
        player_last_name,
        birthdate,
        TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age_years,
        TIMESTAMPDIFF(MONTH, birthdate, CURDATE()) - TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) * 12 AS age_months,
        DAYOFMONTH(CURDATE()) - DAYOFMONTH(birthdate) + IF(DAYOFMONTH(CURDATE()) < DAYOFMONTH(birthdate), -1, 0) AS age_days
    FROM
        Player
),
FormattedAges AS (
  SELECT
        player_ID,
        player_name,
        player_last_name,
        CONCAT(age_years, ' yıl ', age_months, ' ay ', age_days, ' gün') AS formatted_age
    FROM PlayerAges
)  

SELECT
    (SELECT formatted_age FROM FormattedAges ORDER BY formatted_age LIMIT 1) as youngest_age,
    (SELECT formatted_age FROM FormattedAges ORDER BY formatted_age DESC LIMIT 1) as oldest_age,
    (SELECT player_name FROM FormattedAges ORDER BY formatted_age LIMIT 1) as youngest_player,
    (SELECT player_name FROM FormattedAges ORDER BY formatted_age DESC LIMIT 1) as oldest_player
FROM FormattedAges
LIMIT 1; -- en genç ve en yaşlı oyuncuları listeler

-- -------------------------

SELECT *
FROM Team
WHERE ranking = 1
ORDER BY matches_won DESC
LIMIT 2;  -- 1. olup en fazla galibiyet almış 2 takımı seçer

-- ----------------------------------

SELECT t.team_name, SUM(IFNULL(red_card_count,0)) as total_red_cards
FROM Team t
LEFT JOIN (
    SELECT
        m.home_team_ID,
        SUM(md.red_card) AS red_card_count
    FROM Matches m
    JOIN Match_Detail md ON m.match_ID = md.match_ID
    GROUP BY
        m.home_team_ID
    UNION ALL
    SELECT
        m.away_team_ID,
        SUM(md.red_card) AS red_card_count
    FROM Matches m
    JOIN Match_Detail md ON m.match_ID = md.match_ID
    GROUP BY
        m.away_team_ID
) AS red_cards ON t.team_ID = red_cards.home_team_ID
GROUP BY t.team_name
ORDER BY total_red_cards DESC
LIMIT 1; -- maçlarında en fazla red card görülmüş takımı listeler

-- ---------------------------

SELECT
    t.team_name,
    SUM(md.away_foul) AS total_away_fouls
FROM Team t
JOIN Matches m ON t.team_ID = m.away_team_ID
JOIN Match_Detail md ON m.match_ID = md.match_ID
GROUP BY
    t.team_name
ORDER BY
    total_away_fouls DESC
LIMIT 1;  -- deplasman takımı olup en fazla faul yapan takım

-- --------------------------------

SELECT
    team_name,
    COUNT(*) AS count
FROM
    Fav_Teams
GROUP BY
    team_name
ORDER BY
    count DESC
LIMIT 3;   --  fav team olarak en çok eklenen ilk 3 takım

-- -------------------------

SELECT
    *
FROM
    Team
WHERE
    matches_lost = (SELECT MAX(matches_lost) FROM Team)
ORDER BY
    point DESC
LIMIT 1;  -- en fazla mağlubiyet sayısına sahip takımlardan en çok puana sahip takımı listeler

-- ----------------------------



WITH PlayerAges AS (
    SELECT
        player_ID,
        player_name,
        player_last_name,
        team_ID,
        TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) AS age_years
    FROM
        Player
    WHERE
        team_ID = 2  -- Takım ID'si 2 olan oyuncuları filtrele
)

SELECT
    age_years,
    GROUP_CONCAT(CONCAT(player_name, ' ', player_last_name) SEPARATOR ', ') AS players
FROM
    PlayerAges
GROUP BY
    age_years
HAVING
    COUNT(*) > 1  -- Aynı yaşa sahip en az iki oyuncu
ORDER BY
    age_years;  -- team id 2 de aynı yaşa sahip olan oyuncuları listeler

-- -----------------------------
SELECT
    t.team_name,
    SUM(CASE
        WHEN m.match_result = 'away win' THEN 3
        WHEN m.match_result = 'draw' THEN 1
        ELSE 0
    END) AS total_away_points
FROM Team t
JOIN Matches m ON t.team_ID = m.away_team_ID
GROUP BY
    t.team_name
ORDER BY
    total_away_points DESC
LIMIT 1;           -- ---------- deplasman performnası,  	YOU ASKED ME TO ADD THIS TOO

-- ---------------------------------



SELECT
    l.league_ID,
    l.season,
    
    SUM(md.home_goal + md.away_goal) AS total_goals
FROM League l
JOIN Matches m ON l.league_ID = m.league_ID
JOIN Match_Detail md ON m.match_ID = md.match_ID
GROUP BY
    l.league_ID, l.season
ORDER BY
    l.league_ID;   -- --------------------- tüm liglerde atılan goller,  YOU ASKED ME TO ADD THIS TOO



-- ---------------------------

SHOW  TABLES;