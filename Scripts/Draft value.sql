SELECT
  t.pick_tier,
  COUNT(*) AS players,                                            -- how many players in this pick tier
  ROUND(AVG(l.seasons_played), 2) AS avg_seasons_played           -- average distinct seasons they appeared
FROM (
  -- map draft pick → tier
  SELECT
    dh.PERSON_ID AS player_id,
    CASE
      WHEN dh.OVERALL_PICK BETWEEN 1 AND 10 THEN 'T1_1_10'
      WHEN dh.OVERALL_PICK BETWEEN 11 AND 30 THEN 'T2_11_30'
      WHEN dh.OVERALL_PICK BETWEEN 31 AND 60 THEN 'T3_31_60'
      ELSE 'T4_undrafted'
    END AS pick_tier
  FROM draft_history dh
  WHERE dh.OVERALL_PICK IS NOT NULL
) AS t
LEFT JOIN (
  -- seasons played = count of DISTINCT seasons where player appears in PBP
  SELECT
    s.player_id,
    COUNT(DISTINCT s.season) AS seasons_played
  FROM (
    -- derive season from the game date in line_score (robust across dumps)
    SELECT
      p.PLAYER1_ID AS player_id,                                 
      CAST(STRFTIME('%Y', ls.game_date_est) AS INTEGER) AS season
    FROM play_by_play p
    JOIN line_score ls ON ls.game_id = p.game_id
    WHERE p.PLAYER1_ID IS NOT NULL
  ) AS s
  GROUP BY s.player_id
) AS l
  ON l.player_id = t.player_id
GROUP BY t.pick_tier
ORDER BY players DESC;
