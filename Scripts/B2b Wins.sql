SELECT
  MIN(team_name) AS team_name,                                    -- fallback name; never NULL if city/nickname exist
  ROUND(AVG(CASE WHEN is_b2b = 1 THEN win END) * 100, 2) AS win_pct_b2b,
  ROUND(AVG(CASE WHEN is_b2b = 0 THEN win END) * 100, 2) AS win_pct_rest,
  SUM(CASE WHEN is_b2b = 1 THEN 1 ELSE 0 END) AS g_b2b,
  SUM(CASE WHEN is_b2b = 0 THEN 1 ELSE 0 END) AS g_rest
FROM (
  -- mark B2B after building clean team-game rows
  SELECT
    tg.team_id,
    tg.team_name,
    tg.gdate,
    tg.win,
    CASE
      WHEN JULIANDAY(tg.gdate)
         - JULIANDAY(LAG(tg.gdate) OVER (PARTITION BY tg.team_id ORDER BY tg.gdate)) = 1
      THEN 1 ELSE 0
    END AS is_b2b
  FROM (
    -- one row per team per game (HOME)
    SELECT
      team_id_home AS team_id,
      -- robust fallback name (handles missing parts without returning NULL)
      COALESCE(team_city_name_home,'') ||
      CASE WHEN team_city_name_home IS NOT NULL AND team_nickname_home IS NOT NULL THEN ' ' ELSE '' END ||
      COALESCE(team_nickname_home,'') AS team_name,
      DATE(SUBSTR(game_date_est, 1, 10)) AS gdate,
      CASE WHEN CAST(pts_home AS REAL) > CAST(pts_away AS REAL) THEN 1 ELSE 0 END AS win
    FROM line_score
    UNION ALL
    -- one row per team per game (AWAY)
    SELECT
      team_id_away AS team_id,
      COALESCE(team_city_name_away,'') ||
      CASE WHEN team_city_name_away IS NOT NULL AND team_nickname_away IS NOT NULL THEN ' ' ELSE '' END ||
      COALESCE(team_nickname_away,'') AS team_name,
      DATE(SUBSTR(game_date_est, 1, 10)) AS gdate,
      CASE WHEN CAST(pts_away AS REAL) > CAST(pts_home AS REAL) THEN 1 ELSE 0 END AS win
    FROM line_score
  ) AS tg
  WHERE tg.gdate IS NOT NULL
) AS flagged
GROUP BY team_id
ORDER BY win_pct_b2b DESC;
