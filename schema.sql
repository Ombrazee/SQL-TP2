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
