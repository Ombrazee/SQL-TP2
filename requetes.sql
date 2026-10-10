-- Q4 : De combien le nombre de runs evolue-t-il chaque mois, en pourcentage ?
WITH monthly_runs AS (
    SELECT
        date_trunc('month', run_date)::date AS month,
        COUNT(*) AS total_runs
    FROM runs
    GROUP BY 1
)
SELECT
    month,
    total_runs,
    LAG(total_runs) OVER (ORDER BY month) AS previous_runs,
    ROUND(
        100.0 * (total_runs - LAG(total_runs) OVER (ORDER BY month))
        / LAG(total_runs) OVER (ORDER BY month),
        1
    ) AS change_percent
FROM monthly_runs
ORDER BY month;

-- Q5 : Quelle part du score global vient de chaque classe ?
WITH class_scores AS (
    SELECT
        c.class_name,
        SUM(r.score) AS total_score
    FROM runs r
    JOIN character_classes c ON r.class_id = c.class_id
    GROUP BY c.class_name
)
SELECT
    class_name,
    total_score,
    ROUND(100.0 * total_score / SUM(total_score) OVER (), 2) AS score_share_percent
FROM class_scores
ORDER BY total_score DESC;

-- Q6 : Quelle est la moyenne des trois dernieres runs de chaque joueur ?
SELECT
    p.nickname,
    r.run_id,
    r.run_date,
    r.score,
    ROUND(
        AVG(r.score) OVER (
            PARTITION BY r.player_id
            ORDER BY r.run_date, r.run_id
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS last_three_average
FROM runs r
JOIN players p ON r.player_id = p.player_id
ORDER BY p.nickname, r.run_date, r.run_id;
