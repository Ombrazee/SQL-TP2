SELECT setseed(0.42);

INSERT INTO players (nickname)
SELECT 'Player ' || g
FROM generate_series(1, 20) AS g;

INSERT INTO character_classes (class_name) VALUES
    ('Warrior'),
    ('Mage'),
    ('Rogue'),
    ('Ranger'),
    ('Paladin'),
    ('Necromancer'),
    ('Monk'),
    ('Berserker'),
    ('Druid'),
    ('Bard'),
    ('Alchemist'),
    ('Summoner'),
    ('Assassin'),
    ('Sentinel'),
    ('Spellblade');

INSERT INTO zones (zone_name, parent_zone_id) VALUES
    ('The Rift', NULL);

INSERT INTO zones (zone_name, parent_zone_id) VALUES
    ('Ember Realm', 1),
    ('Frozen Realm', 1),
    ('Haunted Realm', 1);

INSERT INTO zones (zone_name, parent_zone_id) VALUES
    ('Ash Valley', 2),
    ('Lava Mines', 2),
    ('Burning Temple', 2),
    ('Cinder Fortress', 2),
    ('Snowy Pass', 3),
    ('Ice Caves', 3),
    ('Glacier Ruins', 3),
    ('Frozen Citadel', 3),
    ('Dark Forest', 4),
    ('Ghost Crypt', 4),
    ('Shadow Castle', 4);
