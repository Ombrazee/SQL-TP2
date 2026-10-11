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

-- Q11 : Combien de runs de chaque classe ont ete jouees en juillet, aout et septembre ?
SELECT
    c.class_name,
    COUNT(r.run_id) FILTER (
        WHERE date_trunc('month', r.run_date) = DATE '2026-07-01'
    ) AS july,
    COUNT(r.run_id) FILTER (
        WHERE date_trunc('month', r.run_date) = DATE '2026-08-01'
    ) AS august,
    COUNT(r.run_id) FILTER (
        WHERE date_trunc('month', r.run_date) = DATE '2026-09-01'
    ) AS september,
    COUNT(r.run_id) AS total_runs
FROM character_classes c
LEFT JOIN runs r ON r.class_id = c.class_id
GROUP BY c.class_name
ORDER BY c.class_name;

-- Q12 : Quels sont les totaux de runs et de scores par classe, par mois et au global ?
WITH run_data AS (
    SELECT
        c.class_name,
        date_trunc('month', r.run_date)::date AS month,
        r.score
    FROM runs r
    JOIN character_classes c ON r.class_id = c.class_id
)
SELECT
    CASE
        WHEN GROUPING(class_name) = 1 THEN 'All classes'
        ELSE class_name
    END AS class_name,
    CASE
        WHEN GROUPING(month) = 1 THEN 'All months'
        ELSE month::text
    END AS month,
    COUNT(*) AS total_runs,
    SUM(score) AS total_score
FROM run_data
GROUP BY ROLLUP (class_name, month)
ORDER BY class_name, month;

-- Q13 : Comment se comparent la moyenne et la mediane des scores par classe ?
SELECT
    c.class_name,
    COUNT(*) AS total_runs,
    ROUND(AVG(r.score), 2) AS average_score,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY r.score) AS median_score
FROM runs r
JOIN character_classes c ON r.class_id = c.class_id
GROUP BY c.class_name
ORDER BY c.class_name;

-- Q14 : Quel est le bilan mensuel des runs, victoires, scores et evolutions ?
WITH monthly_stats AS (
    SELECT
        date_trunc('month', run_date)::date AS month,
        COUNT(*) AS total_runs,
        COUNT(*) FILTER (WHERE victory = TRUE) AS wins,
        ROUND(AVG(score), 2) AS average_score,
        SUM(score) AS total_score
    FROM runs
    GROUP BY 1
),
dashboard AS (
    SELECT
        month,
        total_runs,
        wins,
        ROUND(100.0 * wins / total_runs, 1) AS win_percent,
        average_score,
        total_score,
        SUM(total_score) OVER (ORDER BY month) AS cumulative_score,
        LAG(total_runs) OVER (ORDER BY month) AS previous_runs
    FROM monthly_stats
)
SELECT
    month,
    total_runs,
    wins,
    win_percent,
    average_score,
    total_score,
    cumulative_score,
    CASE
        WHEN previous_runs IS NULL THEN NULL
        ELSE ROUND(100.0 * (total_runs - previous_runs) / previous_runs, 1)
    END AS run_change_percent
FROM dashboard
ORDER BY month;
