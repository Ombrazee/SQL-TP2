DROP TABLE IF EXISTS runs;
DROP TABLE IF EXISTS weapons;
DROP TABLE IF EXISTS zones;
DROP TABLE IF EXISTS character_classes;
DROP TABLE IF EXISTS players;

CREATE TABLE players (
    player_id SERIAL PRIMARY KEY,
    nickname VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE character_classes (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE zones (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(50) NOT NULL UNIQUE,
    parent_zone_id INT REFERENCES zones(zone_id)
);

CREATE TABLE weapons (
    weapon_id SERIAL PRIMARY KEY,
    weapon_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE runs (
    run_id SERIAL PRIMARY KEY,
    player_id INT NOT NULL REFERENCES players(player_id),
    class_id INT NOT NULL REFERENCES character_classes(class_id),
    zone_id INT NOT NULL REFERENCES zones(zone_id),
    weapon_id INT NOT NULL REFERENCES weapons(weapon_id),
    run_date DATE NOT NULL,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    score INT NOT NULL CHECK (score >= 0),
    enemies_defeated INT NOT NULL CHECK (enemies_defeated >= 0),
    floor_reached INT NOT NULL CHECK (floor_reached BETWEEN 1 AND 10),
    victory BOOLEAN NOT NULL
);
