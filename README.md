# Pipeline BI & Analyse Commerçante : Optimisation du Sell-Out GMS

## 🎯 Contexte du Projet
Ce projet présente une suite de scripts SQL avancés conçus pour centraliser, nettoyer et analyser les données de **Sell-Out** et d'**Exécution Terrain** au sein du secteur de la Grande Distribution (GMS - Carrefour, Intermarché, etc.). 

L'objectif est de fournir à une force de vente des outils décisionnels automatisés pour identifier les ruptures de stock, corriger les anomalies de catalogue, et cibler les magasins chroniquement sous-performants.

## 🛠️ Stack Technique
* **Moteur SQL :** Google BigQuery
* **Outil de Dataviz :** Metabase (Modélisation de données et filtres de tableau de bord)
* **Architecture :** Conception de modèles de données (Star Schema), CTE chaînées, Fonctions Analytiques (Window Functions).

## 🚀 Focus sur l'Ingénierie SQL (Top Projets)

### 1. Déduplication Temporelle et Extraction d'États Courants
* **Fichier :** `sql_queries/01_temporal_deduplication.sql`
* **Concept clé :** `ROW_NUMBER() OVER (PARTITION BY...)`
* **Impact Business :** Cette requête utilise les fonctions analytiques de fenêtrage pour auditer un flux de rapports terrain et éliminer les doublons historiques. Elle isole de manière ultra-performante le statut courant et unique de chaque point de vente sans recourir à des sous-requêtes lourdes.

### 2. Algorithme de Détection d'Anomalies Structurelles
* **Fichier :** `sql_queries/02_structural_anomaly_detection.sql`
* **Concept clé :** `CROSS JOIN`, CTE complexes
* **Impact Business :** Ce script implémente une logique d'analyse statistique multi-niveaux pour cartographier la santé financière d'un réseau de distribution. Elle recourt à un produit croisé (`CROSS JOIN`) pour confronter instantanément la performance historique d'un magasin à une constante de marché calculée dynamiquement.

### 3. Modélisation Temporelle Mobile et Seuils Glissants
* **Fichier :** `sql_queries/03_monthly_rolling_thresholds.sql`
* **Concept clé :** `DATE_TRUNC`, Agrégations à granularités multiples
* **Impact Business :** Conçue pour le suivi des ruptures de tendances en Retail, cette requête opère un découpage temporel dynamique des volumes de ventes. Elle chaîne les expressions de table (CTE) pour évaluer la dérive des stocks et des ventes mois par mois face à des moyennes glissantes sectorielles.

### 4. Moteur de Normalisation Textuelle et Classification
* **Fichier :** `sql_queries/04_text_normalization_engine.sql`
* **Concept clé :** `REGEXP_CONTAINS`, expressions régulières avancées
* **Impact Business :** Ce script résout les problématiques courantes de mauvaise qualité de données au sein d'un catalogue produit (Master Data). Il utilise l'analyse syntaxique par expressions régulières pour identifier, corriger et classifier à la volée le mix produit en ignorant les erreurs de saisie manuelles.

### 5. Pipeline ETL de Consolidation Omni-Source
* **Fichier :** `sql_queries/05_omnichannel_etl_consolidation.sql`
* **Concept clé :** `LEFT JOIN` multiples, `CAST` défensifs
* **Impact Business :** Véritable pilier d'intégration de données, cette requête unifie un flux hétérogène de Sell-Out avec des référentiels tiers (données logistiques GLN, structures d'enseignes et caractéristiques produits). Elle implémente des conversions de types explicites (`CAST`) défensives pour immuniser le pipeline contre les pertes de lignes lors des jointures.

### 6. Pipeline de Valorisation Financière Nettoyée
* **Fichier :** `sql_queries/06_financial_valuation_pipeline.sql`
* **Concept clé :** Agrégation conditionnelle, arbitrage Factures vs Avoirs
* **Impact Business :** Cette requête modélise une balance comptable analytique en réajustant au centime près le chiffre d'affaires brut face aux flux d'avoirs et de retours marchandises. Elle sécurise l'intégralité du calcul financier contre la propagation des valeurs nulles grâce à l'application systématique de la fonction `COALESCE`.
