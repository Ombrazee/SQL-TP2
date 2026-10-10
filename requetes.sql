-- Q1 : Quelles classes ont le plus de victoires chaque mois ?
WITH class_month AS (
    SELECT
        date_trunc('month', r.run_date)::date AS month,
        c.class_name,
        COUNT(*) FILTER (WHERE r.victory = TRUE) AS wins
    FROM runs r
    JOIN character_classes c ON r.class_id = c.class_id
    GROUP BY 1, c.class_name
)
SELECT
    month,
    class_name,
    wins,
    DENSE_RANK() OVER (PARTITION BY month ORDER BY wins DESC) AS class_rank
FROM class_month
ORDER BY month, class_rank, class_name;

-- Q2 : Quels sont les trois meilleurs joueurs en score total dans chaque zone ?
WITH player_zone_scores AS (
    SELECT
        z.zone_name,
        p.player_id,
        p.nickname,
        SUM(r.score) AS total_score
    FROM runs r
    JOIN zones z ON r.zone_id = z.zone_id
    JOIN players p ON r.player_id = p.player_id
    GROUP BY z.zone_name, p.player_id, p.nickname
),
ranked_players AS (
    SELECT
        zone_name,
        nickname,
        total_score,
        ROW_NUMBER() OVER (
            PARTITION BY zone_name
            ORDER BY total_score DESC, player_id
        ) AS player_rank
    FROM player_zone_scores
)
SELECT zone_name, nickname, total_score, player_rank
FROM ranked_players
WHERE player_rank <= 3
ORDER BY zone_name, player_rank;

-- Q3 : Comment evolue le score total cumule mois apres mois ?
WITH monthly_scores AS (
    SELECT
        date_trunc('month', run_date)::date AS month,
        SUM(score) AS total_score
    FROM runs
    GROUP BY 1
)
SELECT
    month,
    total_score,
    SUM(total_score) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_score
FROM monthly_scores
ORDER BY month;
