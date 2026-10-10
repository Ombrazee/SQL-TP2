SELECT setseed(0.42);

INSERT INTO weapons (weapon_name) VALUES
    ('Iron Sword'),
    ('Oak Staff'),
    ('Twin Daggers'),
    ('Longbow'),
    ('Holy Hammer'),
    ('Bone Wand'),
    ('Steel Fists'),
    ('Battle Axe'),
    ('Nature Spear'),
    ('Silver Flute'),
    ('Poison Flask'),
    ('Crystal Orb'),
    ('Shadow Blade'),
    ('Tower Shield'),
    ('Runic Sword');

INSERT INTO runs (
    player_id,
    class_id,
    zone_id,
    weapon_id,
    run_date,
    duration_minutes,
    score,
    enemies_defeated,
    floor_reached,
    victory
)
SELECT
    1 + floor(random() * 20)::int,
    1 + floor(random() * 15)::int,
    5 + floor(random() * 11)::int,
    1 + floor(random() * 15)::int,
    DATE '2026-07-01' + floor(random() * 92)::int,
    CASE
        WHEN g % 5 = 0 THEN 45 + floor(random() * 35)::int
        ELSE 8 + floor(random() * 45)::int
    END,
    CASE
        WHEN g % 5 = 0 THEN 8000 + floor(random() * 7000)::int
        ELSE 200 + floor(random() * 5000)::int
    END,
    CASE
        WHEN g % 5 = 0 THEN 35 + floor(random() * 40)::int
        ELSE 5 + floor(random() * 30)::int
    END,
    CASE
        WHEN g % 5 = 0 THEN 10
        ELSE 1 + floor(random() * 9)::int
    END,
    g % 5 = 0
FROM generate_series(1, 240) AS g;
