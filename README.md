🎯 Enjeu : Piloter la force de vente et fiabiliser le calcul des commissions des agents terrain.
🛠️ Solution : Dashboard dynamique intégrant les règles d'incentives.
📊 Usage : +15 filtres interactifs pour une analyse sur-mesure par le Directeur Commercial.


# Metabase Dashboards — 900.care Retail Analytics (exemples anonymisés)

Ce repo présente une sélection de dashboards Metabase construits pour le suivi retail effectués en stage (ventes, commandes, visites terrain, commissions agences, rétention client). Il s'agit de **reconstructions visuelles** des vrais dashboards : mêmes types de graphiques, même structure, mais avec des données entièrement fictives — pensées pour être partagées publiquement sans exposer de chiffres d'affaires, de partenaires ou de collaborateurs réels.

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
