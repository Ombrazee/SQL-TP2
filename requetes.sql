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

-- Q7 : Quels joueurs ont un score total superieur a la moyenne des joueurs ?
WITH player_scores AS (
    SELECT
        p.nickname,
        SUM(r.score) AS total_score
    FROM runs r
    JOIN players p ON r.player_id = p.player_id
    GROUP BY p.nickname
),
average_score AS (
    SELECT AVG(total_score) AS global_average
    FROM player_scores
)
SELECT
    p.nickname,
    p.total_score,
    ROUND(a.global_average, 2) AS global_average
FROM player_scores p
CROSS JOIN average_score a
WHERE p.total_score > a.global_average
ORDER BY p.total_score DESC;

-- Q8 : Quelles zones ont un meilleur taux de victoire que le taux general ?
WITH zone_stats AS (
    SELECT
        z.zone_name,
        COUNT(*) AS total_runs,
        COUNT(*) FILTER (WHERE r.victory = TRUE) AS wins
    FROM runs r
    JOIN zones z ON r.zone_id = z.zone_id
    GROUP BY z.zone_name
),
overall_win_rate AS (
    SELECT 100.0 * SUM(wins) / SUM(total_runs) AS average_win_rate
    FROM zone_stats
)
SELECT
    z.zone_name,
    z.total_runs,
    z.wins,
    ROUND(100.0 * z.wins / z.total_runs, 2) AS win_rate,
    ROUND(o.average_win_rate, 2) AS average_win_rate
FROM zone_stats z
CROSS JOIN overall_win_rate o
WHERE 100.0 * z.wins / z.total_runs > o.average_win_rate
ORDER BY win_rate DESC, z.zone_name;

-- Q9 : Quelle est l'arborescence complete des zones ?
WITH RECURSIVE zone_tree AS (
    SELECT
        zone_id,
        zone_name,
        parent_zone_id,
        0 AS level,
        zone_name::text AS path
    FROM zones
    WHERE parent_zone_id IS NULL

    UNION ALL

    SELECT
        z.zone_id,
        z.zone_name,
        z.parent_zone_id,
        t.level + 1,
        t.path || ' > ' || z.zone_name
    FROM zones z
    JOIN zone_tree t ON z.parent_zone_id = t.zone_id
    WHERE t.level < 10
)
SELECT zone_name, level, path
FROM zone_tree
ORDER BY path;

-- Q10 : Combien de runs ont ete jouees chaque jour, y compris les jours sans activite ?
SELECT
    d::date AS run_day,
    COUNT(r.run_id) AS total_runs
FROM generate_series(
    DATE '2026-07-01',
    DATE '2026-09-30',
    INTERVAL '1 day'
) AS d
LEFT JOIN runs r ON r.run_date = d::date
GROUP BY d
ORDER BY d;

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
