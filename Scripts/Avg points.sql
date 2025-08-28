SELECT
  MIN(team_name) AS team_name,
  season,
  ROUND(AVG(pts_for), 1)     AS avg_pts_for,
  ROUND(AVG(pts_against), 1) AS avg_pts_against,
  COUNT(*) AS games
FROM (
  SELECT
    CAST(STRFTIME('%Y', game_date_est) AS INTEGER) AS season,
    team_id_home AS team_id,
    team_city_name_home || ' ' || team_nickname_home AS team_name,
    CAST(pts_home AS REAL) AS pts_for,
    CAST(pts_away AS REAL) AS pts_against
  FROM line_score
  UNION ALL
  SELECT
    CAST(STRFTIME('%Y', game_date_est) AS INTEGER) AS season,
    team_id_away AS team_id,
    team_city_name_away || ' ' || team_nickname_away AS team_name,
    CAST(pts_away AS REAL) AS pts_for,
    CAST(pts_home AS REAL) AS pts_against
  FROM line_score
) AS tg
WHERE pts_for IS NOT NULL AND pts_against IS NOT NULL
GROUP BY team_id, season
ORDER BY season, avg_pts_for DESC;