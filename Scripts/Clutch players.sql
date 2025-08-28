SELECT
  MIN(COALESCE(pl.full_name, pl.first_name || ' ' || pl.last_name, 'Unknown')) AS player_name,
  COUNT(DISTINCT c.game_id) AS clutch_games,
  ROUND(SUM(c.pts) * 1.0 / COUNT(DISTINCT c.game_id), 2) AS clutch_pts_per_game
FROM (
  -- Build clutch scoring events for close games only
  SELECT
    p.game_id,
    p.player1_id AS player_id,    
    CASE
      WHEN p.eventmsgtype = 1 AND (COALESCE(p.homedescription,'') || COALESCE(p.visitordescription,'')) LIKE '%3PT%' THEN 3
      WHEN p.eventmsgtype = 1 THEN 2
      WHEN p.eventmsgtype = 3 AND (COALESCE(p.homedescription,'') || COALESCE(p.visitordescription,'')) NOT LIKE '%MISS%' THEN 1
      ELSE 0
    END AS pts
  FROM (
    -- keep Q4 plays in last 5:00, only for games that finished within 5 points
    SELECT
      pbp.*,
      CASE
        WHEN LENGTH(pbp.pctimestring) = 5
          THEN CAST(SUBSTR(pbp.pctimestring,1,2) AS INT)*60 + CAST(SUBSTR(pbp.pctimestring,4,2) AS INT)
        WHEN LENGTH(pbp.pctimestring) = 4
          THEN CAST(SUBSTR(pbp.pctimestring,1,1) AS INT)*60 + CAST(SUBSTR(pbp.pctimestring,3,2) AS INT)
        ELSE 0
      END AS sec_left
    FROM play_by_play pbp
    JOIN (
      SELECT game_id
      FROM line_score
      WHERE ABS(CAST(pts_home AS REAL) - CAST(pts_away AS REAL)) <= 5
    ) cg USING (game_id)
    WHERE pbp.period = 4
  ) p
  WHERE p.sec_left <= 300
    AND p.player1_id IS NOT NULL     
) c
LEFT JOIN player pl
  ON CAST(pl.id AS TEXT) = CAST(c.player_id AS TEXT)  -- type-safe join (TEXT vs INTEGER)
GROUP BY c.player_id
HAVING COUNT(DISTINCT c.game_id) >= 10
ORDER BY clutch_pts_per_game DESC
LIMIT 25;
