# 🏀 NBA Performance Analytics (SQL-First, 2000–2025)

A **SQL-first** analysis of NBA team trends, back-to-back (B2B) effects, clutch-time scorers, and **draft value vs. career longevity**. Built to be **reproducible** in DB Browser / DBeaver with a SQLite database or the provided CSVs.

> Focus: clean SQL transformations, window functions, robust joins, and portable queries. Results can be exported to CSV or visualized in your BI tool of choice.

---

## 📦 Repo Structure 
```
.
├─ csv/                          # (Optional) Raw tables as CSVs
├─ Scripts/ or sql/              # The SQL you can run directly
│  ├─ Win %.sql
│  ├─ Avg points.sql
│  ├─ B2b Wins.sql
│  ├─ Clutch players.sql
│  └─ Draft value.sql
├─ NBA Performance Analytics.docx                    
└─ README.md
```

**Key query files**
- `Avg points.sql` — Average **points for** and **against** per team-season (unpivot `line_score`). 
- `B2b Wins.sql` — **Win% on B2B vs. with rest** using `LAG` on per-team game dates.
- `Clutch players.sql` — **Clutch time** (Q4 last 5:00 in close games) scorers by points/game. 
- `Draft value.sql` — Draft **pick tier → average seasons played** (longevity proxy).
- `Win %.sql` — **Win% by team-season** (unpivot + win flag). 

The narrative report with methods, schema notes, and confirmed results is in **`NBA Performance Analytics.docx`**. 

---

## 🧭 What This Project Shows
- **Team Trends** — season **win%**, **avg points for/against**, pace proxy via scoring levels. 
- **Back-to-Back Effect** — measurable **drop in win%** on the second night of B2B vs. rest days (delta varies by team/era).
- **Clutch Scorers** — top players by **clutch PPG** (Q4 last 5:00, games decided by ≤5). Min 10 clutch games.  
- **Draft Value vs Longevity** — average **seasons played** by pick tier (1–10, 11–30, 31–60, undrafted). **Confirmed** example from the latest run:  
  - T1 (1–10): **11.63** seasons  
  - T2 (11–30): **8.90**  
  - T3 (31–60): **5.89**  
  - T4 (Undrafted): **7.72**  
  _Note: undrafted who make a roster tend to be exceptional survivors—selection bias explains their longevity vs. typical 2nd‑rounders._ 

---

## ⚙️ How to Reproduce
**Option A — SQLite (recommended)**
1. Place `nba.sqlite` in `/data/`.  
2. Open in **DB Browser for SQLite** or **DBeaver**.
3. (Optional) Create indexes for speed (see report, Section 3.5). 
4. Run queries in this order:
   - `sql/01_team_trends_win_pct.sql` → or `Win %.sql` 
   - `sql/01_team_trends_points.sql` → or `Avg points.sql` 
   - `sql/01b_b2b_vs_rest.sql` → or `B2b Wins.sql` 
   - `sql/02_clutch_time.sql` → or `Clutch players.sql` 
   - `sql/03_draft_value.sql` → or `Draft value.sql`
5. Export result grids to `/exports/` and add screenshots to `/images/`.

**Option B — CSVs**
- Import the CSVs in `/csv/` into a fresh SQLite DB (keep table names used in the queries: `line_score`, `game`, `play_by_play`, `player`, `draft_history`, etc.).  
- Re-run the same SQL files. Schema notes in the report explain table roles and season normalization. 

---

## 🔍 Data & Schema Highlights
- Core tables: `line_score` (per game, both teams), `play_by_play` (event-level), `game` (meta), `player` (directory), `draft_history` (picks).   
- **Unpivot step**: convert each `line_score` row into **two team-game rows** with `pts_for/pts_against` to compute win flags & averages. fileciteturn1file0turn1file4  
- **B2B**: build per-team dates and compare with `LAG` → `is_b2b`.
- **Clutch window**: Q4, last **300 sec**, only games finishing within **±5** points; parse `pctimestring` (m:ss/mm:ss). 

---


## 👤 Author
**Aditya Kumar** — Data & Analytics  
Open to feedback and PRs on alternative methods, tighter clutch definitions, and additional indexes.

---

## 🙌 Citation
If you use this work, please cite:
> Aditya Kumar, “NBA Performance Analytics (SQL-First, 2000–2025).” Project README & SQL files.  
Core queries: Win%, Avg Points, B2B, Clutch, Draft Value. 
