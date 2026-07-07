
# Metabase-Dashboards

## 👉 [Voir le portfolio complet en ligne →](https://artusambos-cloud.github.io/Metabase-Dashboards/)

Page d'accueil avec tous les dashboards, le modèle de données et les requêtes SQL, cliquables directement (via GitHub Pages).

---

🎯 Enjeu : Piloter la force de vente et fiabiliser le calcul des commissions des agents terrain. 

🛠️ Solution : Dashboard dynamique intégrant les règles d'incentives et les différents angles business en retail. 

📊 Usage : +15 filtres interactifs pour une analyse sur-mesure par le Directeur Commercial.

Ce repo présente une sélection de dashboards Metabase construits pour le suivi retail de **900.care** (ventes, commandes, visites terrain, commissions agences, rétention client). Il s'agit de **reconstructions visuelles** des vrais dashboards : mêmes types de graphiques, même structure, mais avec des données entièrement fictives — pensées pour être partagées publiquement sans exposer de chiffres d'affaires, de partenaires ou de collaborateurs réels.

## Comment consulter les dashboards

Chaque fichier `.html` est aussi autonome : tu peux le télécharger et l'ouvrir directement dans un navigateur sans passer par le lien ci-dessus.

## Dashboards

| Fichier | Contenu |
|---|---|
| [`dashboard-ca-volume.html`](./dashboard-ca-volume.html) | CA et volumes facturés, kit vs recharge, par catégorie produit, par centrale régionale, par groupe (enseignes), par agent et par agence |
| [`dashboard-commandes.html`](./dashboard-commandes.html) | Nombre de commandes, panier moyen, nombre de SKU par commande, fréquence et rétention des magasins sur 120 jours |
| [`dashboard-visites-terrain.html`](./dashboard-visites-terrain.html) | Suivi terrain : visites, taux de couverture, mises en avant, réglettes et double facing |
| [`dashboard-commande-via-agence.html`](./dashboard-commande-via-agence.html) | Commandes passées via agences commerciales : listes de magasins, incentives et commissions calculées |
| [`dashboard-croissance-magasins.html`](./dashboard-croissance-magasins.html) | Évolution du nombre de magasins actifs par groupe et par format, ARR par format de magasin indépendant |
| [`dashboard-magasins-inactifs.html`](./dashboard-magasins-inactifs.html) | Magasins sans recommande depuis plus de 60 jours, par agent |
| [`dashboard-retention-cohortes.html`](./dashboard-retention-cohortes.html) | Taux de réassort à 90/120 jours, rétention client et rétention du revenu par cohorte mensuelle |
| [`modele-donnees-visites-agences.html`](./modele-donnees-visites-agences.html) | Aperçu du modèle de données brut (jointure visites × magasins × agences × commandes) utilisé en amont des dashboards ci-dessus, avec la requête SQL intégrée |
| [`modele-donnees-visites-agences.sql`](./modele-donnees-visites-agences.sql) | La requête SQL du modèle ci-dessus en fichier autonome (BigQuery Standard SQL) |

## Requêtes SQL

6 requêtes représentatives du travail de modélisation de données derrière ces dashboards (dialecte BigQuery Standard SQL). Noms de tables et de colonnes génériques, aucune donnée réelle.

**[`sql-01-deduplication-row-number.sql`](./sql-01-deduplication-row-number.sql) — Déduplication temporelle et extraction d'états courants**
Isole le dernier état connu de chaque magasin à partir d'un flux de rapports terrain contenant des doublons historiques.
1. CTE avec `ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY report_date DESC)` pour numéroter chaque visite du plus récent au plus ancien, par magasin.
2. Exclusion des lignes supprimées (`is_deleted`) en amont.
3. Filtre `row_num = 1` pour ne garder que la visite la plus récente de chaque magasin.
4. Tri final par date décroissante.

**[`sql-02-detection-anomalies-cross-join.sql`](./sql-02-detection-anomalies-cross-join.sql) — Détection d'anomalies structurelles (CROSS JOIN)**
Repère les magasins dont le CA moyen décroche significativement de la moyenne du marché.
1. CTE 1 : CA moyen par magasin (`AVG` groupé par magasin/groupe/enseigne).
2. CTE 2 : moyenne globale de marché, calculée à partir de la CTE 1.
3. `CROSS JOIN` pour comparer chaque magasin à cette moyenne globale en une seule passe.
4. Filtre sur les magasins sous 50 % de la moyenne (seuil d'alerte), CA positif.

**[`sql-03-seuils-glissants-date-trunc.sql`](./sql-03-seuils-glissants-date-trunc.sql) — Modélisation temporelle mobile et seuils glissants (DATE_TRUNC)**
Suit les ruptures de tendance des ventes mois par mois face à une moyenne sectorielle glissante.
1. CTE 1 : agrégation mensuelle des volumes vendus par magasin (`DATE_TRUNC(..., MONTH)`).
2. CTE 2 : moyenne de marché calculée pour chaque mois.
3. Jointure des deux CTE sur le mois fiscal.
4. Filtre sur les magasins sous 50 % du volume moyen mensuel du marché.

**[`sql-04-normalisation-textuelle-regexp.sql`](./sql-04-normalisation-textuelle-regexp.sql) — Moteur de normalisation textuelle et classification (REGEXP)**
Corrige et reclassifie à la volée un mix produit mal renseigné dans le catalogue.
1. Jointure entre les ventes et le catalogue produit.
2. `REGEXP_CONTAINS` sur le SKU pour détecter les références box/pack/kit malgré les erreurs de saisie.
3. `CASE WHEN` pour forcer la classification en "Bundled Kit" quand le pattern matche.
4. Repli (`COALESCE`) vers "Standard Refill" quand aucun type n'est renseigné côté catalogue.

**[`sql-05-pipeline-etl-consolidation.sql`](./sql-05-pipeline-etl-consolidation.sql) — Pipeline ETL de consolidation omni-source (jointures multiples & casts)**
Unifie les ventes brutes avec trois référentiels tiers pour construire une table enrichie et fiable.
1. Table source brute en zone de staging.
2. Trois `LEFT JOIN` successifs : référentiel logistique (GLN), hiérarchie enseignes/groupes, catalogue produit.
3. `CAST` explicite des clés de jointure en `STRING` pour sécuriser les correspondances entre systèmes source hétérogènes.
4. Exclusion des lignes marquées à supprimer.

**[`sql-06-valorisation-financiere-factures-avoirs.sql`](./sql-06-valorisation-financiere-factures-avoirs.sql) — Pipeline de valorisation financière nettoyée (balance factures vs avoirs)**
Calcule un CA net fiable en réconciliant factures et avoirs à la ligne.
1. CTE de filtrage des lignes de commande validées (statut + périmètre B2B retail).
2. Double jointure vers les lignes de facture puis les factures elles-mêmes (statut "posted" uniquement).
3. `CASE` arithmétique : addition si facture, soustraction si avoir, neutre sinon — sécurisé par `COALESCE` contre les valeurs nulles.
4. Agrégation (`SUM`/`ROUND`) du CA net par date, magasin et facture.

## À propos des données

Tous les chiffres (CA, volumes, taux, montants, dates précises) sont générés artificiellement. Les noms d'agents commerciaux, d'agences partenaires et de magasins individuels sont fictifs. 

## Stack

Dashboards originaux construits sous [Metabase](https://www.metabase.com/). Les reconstructions de ce repo utilisent [Chart.js](https://www.chartjs.org/) et reprennent la palette de couleurs par défaut de Metabase.

