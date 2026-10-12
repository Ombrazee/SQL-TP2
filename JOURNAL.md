# Journal du projet : Riftbound

## Choix du projet

Nous avons imaginé un RPG roguelite qui conserve les anciennes parties des joueurs. Le sujet est adapté au SQL analytique, car un même joueur effectue plusieurs runs à des dates différentes. On peut donc comparer les parties et les mois.

Nous avons choisi cinq tables simples. La table `runs` contient les événements. Les quatre autres tables décrivent le joueur, la classe, la zone et l'arme. La table `zones` possède une relation vers elle-même pour représenter le monde du jeu.

Les données couvrent trois mois, avec 240 runs et au moins 15 lignes dans chaque table principale. Les victoires sont moins fréquentes que les défaites et donnent des scores plus élevés. Cela permet de comparer la moyenne à la médiane.

## Palier 1 : conception et données

Le modèle sépare les informations permanentes d'un joueur et l'historique de ses runs. Les clés étrangères évitent d'enregistrer une run avec une classe, une arme ou une zone inexistante. Les contraintes empêchent aussi plusieurs données incohérentes.

## Palier 2 : fonctions de fenêtre

**Q1.** Le classement montre les classes qui gagnent le plus souvent chaque mois. `DENSE_RANK` conserve le même rang en cas d'égalité.

**Q2.** Le top 3 permet de trouver les joueurs qui ont obtenu les meilleurs scores cumulés dans chaque zone. La CTE permet de filtrer le rang calculé avec `ROW_NUMBER`.

**Q3.** Le cumul indique comment le score total de l'ensemble des joueurs augmente de mois en mois.

**Q4.** Le pourcentage d'évolution permet de voir si l'activité des joueurs augmente ou diminue par rapport au mois précédent.

**Q5.** La part du score total permet de repérer les classes qui contribuent le plus aux scores du jeu.

**Q6.** La moyenne mobile permet de suivre les performances récentes de chaque joueur, sans mélanger ses runs avec celles des autres joueurs.

## Palier 3 : CTE et récursivité

**Q7.** Deux CTE comparent le score cumulé de chaque joueur à la moyenne des scores cumulés des joueurs. On retrouve les joueurs au-dessus de cette moyenne.

**Q8.** Deux CTE calculent les résultats de chaque zone, puis le taux de victoire général. Le résultat affiche les zones au-dessus de ce taux.

**Q9.** La CTE récursive parcourt toutes les zones, du monde principal jusqu'aux petites zones. Les colonnes `level` et `path` montrent leur position dans l'arbre.

**Q10.** La série de dates affiche aussi les jours avec zéro run, car le `LEFT JOIN` conserve toutes les dates de la période.

## Palier 4 : rapports d'agrégation

**Q11.** Le tableau croisé permet de comparer l'utilisation de chaque classe sur les trois mois, avec une colonne par mois.

**Q12.** `ROLLUP` produit les résultats détaillés, les sous-totaux par classe et le total général dans un même rapport.

**Q13.** Dans nos données, les victoires sont minoritaires mais rapportent beaucoup de points. La moyenne peut donc être augmentée par ces grosses performances. **La médiane représente souvent mieux le score d'une run habituelle**, car elle est moins sensible aux scores très élevés.

**Q14.** Le tableau de bord rassemble l'activité, les victoires, la moyenne des scores, le score cumulé et l'évolution du nombre de runs. Il permet de faire un bilan rapide de chaque mois.

## Difficulté et solution

La principale difficulté est de sélectionner seulement les premiers rangs d'une fonction de fenêtre. On ne peut pas placer directement `ROW_NUMBER()` dans `WHERE`, car `WHERE` est exécuté avant les fonctions de fenêtre. Nous avons donc calculé les rangs dans une CTE, puis filtré dans la requête suivante (Q2).

Une deuxième attention concerne les égalités. Dans Q2, nous avons ajouté `player_id` après le score dans `ORDER BY` pour que `ROW_NUMBER` produise un résultat stable.

## Amélioration possible

Avec plus de temps, nous pourrions enregistrer les objets trouvés à chaque étage et les améliorations permanentes débloquées par le joueur. Pour ce TP, nous avons préféré une base simple et des requêtes compréhensibles à l'oral.
