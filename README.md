# Projet SQL : Riftbound, un RPG roguelite

## 1. Présentation

Riftbound est un RPG *roguelite* imaginaire. À chaque partie, le joueur choisit une classe et une arme, traverse une zone et essaie d'atteindre le dixième étage. Une partie est appelée une *run*.

Le principe du roguelite est de recommencer plusieurs parties. La base garde donc **l'historique de toutes les runs**, y compris celles qui se terminent par une défaite. On peut ensuite étudier les scores, la progression des joueurs, les classes les plus utilisées et le taux de victoire.

**Objectif :** répondre à des questions sur l'activité du jeu avec les fonctions SQL analytiques vues en cours. Le projet utilise PostgreSQL.

## 2. Modèle de données

| Table | Clé primaire | Données | Relations |
|---|---|---|---|
| `players` | `player_id` | Pseudonyme du joueur | Une personne peut avoir plusieurs runs. |
| `character_classes` | `class_id` | Classe RPG : Warrior, Mage, etc. | Une classe peut être choisie dans plusieurs runs. |
| `zones` | `zone_id` | Lieu du jeu | `parent_zone_id` relie une zone à sa zone parente. |
| `weapons` | `weapon_id` | Arme utilisée | Une arme peut être utilisée dans plusieurs runs. |
| `runs` | `run_id` | Date, durée, score, ennemis, étage et victoire | Chaque run possède un joueur, une classe, une zone et une arme. |

### Schéma des relations

```text
players (player_id) ----------+
character_classes (class_id) -+
zones (zone_id) --------------+--> runs (run_id)
weapons (weapon_id) ----------+

zones (parent_zone_id) -------> zones (zone_id)
```

Dans `runs`, les clés `player_id`, `class_id`, `zone_id` et `weapon_id` sont des clés étrangères. `zone_id` désigne la zone où la run se termine. Seules les zones du dernier niveau sont choisies dans les données d'exemple.

La hiérarchie comporte trois niveaux : `The Rift` (monde principal), `Ember Realm` / `Frozen Realm` / `Haunted Realm` (régions), puis onze petites zones. Cette structure sert à la requête récursive Q9.

Les noms de joueurs, de classes, de zones et d'armes sont uniques. Les contraintes `CHECK` empêchent les scores négatifs, les durées non positives et les étages hors de 1 à 10.

## 3. Données

- 20 joueurs ;
- 15 classes ;
- 15 zones hiérarchiques ;
- 15 armes ;
- **240 runs**, datées entre juillet et septembre 2026.

Les données sont fictives et sont générées avec `generate_series`, `random` et `setseed`, comme dans le cours. Une victoire correspond à un étage 10 et donne un score plus élevé. Les autres runs se terminent avant l'étage 10. Dans cet exemple, une run sur cinq est une victoire.

## 4. Installation et exécution

Après avoir installé PostgreSQL, ouvrez un terminal dans le dossier du projet et exécutez :

```bash
createdb rogue_lite_analytics
psql -d rogue_lite_analytics -f schema.sql
psql -d rogue_lite_analytics -f seed.sql
psql -d rogue_lite_analytics -f requetes.sql
```

`schema.sql` crée les tables, `seed.sql` ajoute les données et `requetes.sql` contient toutes les analyses. Pour repartir de zéro, relancez `schema.sql` puis `seed.sql`.

Pour vérifier les quantités et la période :

```sql
SELECT COUNT(*), MIN(run_date), MAX(run_date)
FROM runs;

SELECT COUNT(*) FROM players;
SELECT COUNT(*) FROM character_classes;
SELECT COUNT(*) FROM zones;
SELECT COUNT(*) FROM weapons;
```

Le premier résultat doit indiquer 240 parties sur la période juillet-septembre 2026.

## 5. Requêtes analytiques

Le fichier `requetes.sql` contient 14 requêtes, de Q1 à Q14. Chaque requête commence par un commentaire qui pose la question métier, comme demandé dans la consigne.

- **Q1 à Q6 (palier 2)** : fonctions de fenêtre pour classer, cumuler et comparer les performances.
- **Q7 à Q10 (palier 3)** : CTE, récursivité et jours sans activité.
- **Q11 à Q14 (palier 4)** : tableau croisé, sous-totaux, médiane et tableau de bord.

Le fichier `JOURNAL.md` explique ce que nous apprenons avec chaque requête.

## 6. Préparation de l'oral

**Présentation du modèle (2 minutes) :** expliquer le roguelite, les cinq tables, les clés étrangères et la hiérarchie des zones.

**Démonstration (5 minutes) :** montrer Q2 (top 3 par zone et fenêtre), Q9 (récursivité) et Q14 (tableau de bord mensuel). Expliquer à chaque fois la question, les étapes de la requête et le résultat affiché.

**Retour d'expérience (2 minutes) :** expliquer pourquoi une fonction de fenêtre ne peut pas être filtrée directement dans `WHERE`, puis montrer comment une CTE résout ce problème dans Q2.

**Questions (5 minutes) :** chaque membre du groupe doit savoir expliquer les jointures, les fenêtres, les CTE et les agrégations de toutes les requêtes.

Le thème doit être validé par l'enseignant, conformément à la consigne du TP.
