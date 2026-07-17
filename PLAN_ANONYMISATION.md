# Plan d'anonymisation des dashboards Metabase (pour publication GitHub)

Ce document explique, catégorie par catégorie, ce qui a été jugé sensible dans les 4 exports PDF de dashboards Metabase, la décision prise pour chacune, et pourquoi. Les fichiers livrés à côté de ce plan (`mockup-1-revenue-volume.html`, `mockup-2-commandes.html`, `mockup-3-visites-terrain.html`, `mockup-4-commissions.html`) sont des **reconstructions visuelles** des dashboards originaux, avec des données 100% inventées — aucun chiffre, nom d'agent, nom d'agence ou nom de magasin réel n'y figure. Les graphiques reprennent la palette de couleurs par défaut de Metabase (bleu de marque, vert, violet, jaune, orange, cyan, indigo, rouge/saumon) pour un rendu fidèle à l'outil d'origine.

## Pourquoi reconstruire plutôt qu'éditer les PDF

Les PDF Metabase sont un mélange de texte vectoriel et de graphiques. Masquer ou remplacer du texte directement dans ce type de fichier est peu fiable : un flou visuel peut laisser le texte réel sélectionnable/copiable en dessous, et la mise en page peut se décaler si un libellé remplacé est plus long ou plus court que l'original. Pour une publication publique sur GitHub, on a donc choisi de repartir de zéro : mêmes types de graphiques, même style de carte façon Metabase, mais alimentés par des données fictives dès la conception. Ça élimine tout risque de résidu de vraie donnée caché dans le fichier.

## Décisions par catégorie de donnée

**Chiffres d'affaires et volumes réels.** C'est la donnée la plus sensible commercialement : elle permet de déduire la taille du business, sa croissance mois par mois, et la répartition du CA par client. → Remplacés par des montants entièrement synthétiques, du même ordre de grandeur visuel que l'original (pour que les graphiques restent réalistes), mais sans aucun rapport avec les vrais chiffres.

**Noms d'enseignes et de groupes (E.Leclerc, Carrefour, Intermarché, Coopérative U, Casino, Auchan).** Décision : conservés tels quels. Ce sont des enseignes publiques ; seule la répartition précise du CA par enseigne était sensible, et celle-ci a été refaite avec des chiffres fictifs. Les noms des centrales régionales (ex. "E.Leclerc - Scaouest", "Coopérative U - Est") sont également conservés dans le même esprit : ce sont des structures internes au niveau de l'enseigne, pas des identifiants individuels d'un magasin ou d'une personne.

**Noms de magasins individuels, souvent accolés à la raison sociale du franchisé/distributeur.** Ce sont des données d'entreprises tierces (les franchisés), et leur combinaison avec des données de commission/CA les rend identifiables. → Remplacés par des noms de magasins fictifs, construits sur le même modèle (enseigne réelle + ville/raison sociale fictive), sans jamais réutiliser une vraie raison sociale de distributeur.

**Noms et prénoms des agents commerciaux.** Ce sont des personnes physiques identifiables, associées à des données de performance/commission — donc à traiter avec la même prudence qu'une donnée personnelle. → Remplacés par des noms fictifs réalistes (prénom + nom), choisis pour ne correspondre à aucune personne réelle du fichier d'origine.

**Noms des agences commerciales partenaires.** Ce sont des sociétés tierces. → Remplacées par des noms d'agences fictifs.

**Adresses postales complètes et coordonnées GPS des magasins.** Présentes dans le modèle de données brut utilisé pour la sectorisation des tournées commerciales. C'est le niveau de donnée le plus sensible du repo : une adresse + des coordonnées précises identifient un lieu physique réel de façon quasi certaine, indépendamment du nom du magasin. → Adresses et coordonnées entièrement fictives (aucune géolocalisation réelle, même approximative).

**Identifiants internes (ID client, codes magasin, codes département, ID de visite).** Des identifiants techniques qui, recoupés avec les autres colonnes, peuvent aussi resservir à ré-identifier un magasin réel dans le vrai système. → Remplacés par des identifiants fictifs sans continuité avec les vraies séquences.

**Références de commande séquentielles.** Les numéros de commande réels trahissent en creux le volume total de commandes traité historiquement par l'entreprise. → Remplacées par une numérotation fictive recommençant à une base arbitraire, sans continuité avec la vraie séquence.

**Nom de la société elle-même.** Décision finale (revue) : retiré de tous les livrables. Contrairement aux agents, agences ou magasins (des tiers), il n'y avait pas d'enjeu de confidentialité de données personnelles ou d'entreprises tierces à le montrer — mais par choix personnel, le nom de l'entreprise n'apparaît plus nulle part dans le repo ; les titres et textes utilisent une formulation générique ("suivi retail", "l'entreprise du secteur", etc.).

> Note volontaire : ce plan ne liste pas les vraies valeurs d'origine pour les catégories restées anonymisées (vrais noms d'agents, d'agences, de magasins) pour rester sûr à publier lui-même sur GitHub aux côtés des mockups. Si tu veux un jour un document de correspondance "vrai nom → nom fictif" pour retrouver qui est qui en interne, il faudra le garder dans un fichier séparé, non publié (ex. hors du repo Git, ou dans un `.gitignore`).

**Dates.** Conservées au format réaliste (mois/année) pour que les graphiques restent cohérents visuellement, mais décalées et associées à des données fictives : elles ne permettent donc pas de retrouver la vraie chronologie business.

## Récapitulatif rapide

| Catégorie                         | Décision                                  |
|-----------------------------------|--------------------------------------------|
| CA / volumes réels                 | Remplacés par données 100% fictives         |
| Enseignes (Leclerc, Carrefour...)  | Conservées telles quelles                   |
| Centrales régionales (Scaouest...) | Conservées telles quelles                   |
| Noms de magasins / franchisés      | Fictifs                                     |
| Noms d'agents commerciaux          | Fictifs (réalistes)                         |
| Noms d'agences commerciales        | Fictifs (réalistes)                         |
| Références de commande             | Fictives                                    |
| Nom de la société                  | Retiré (formulation générique)              |
| Catégories produit (Kit, Recharge…)| Conservées (génériques, non sensibles)      |
| Palette de couleurs des graphiques | Palette officielle Metabase                 |
| Adresses postales / coordonnées GPS | Entièrement fictives                       |
| Identifiants internes (ID client, codes magasin/dépt.) | Entièrement fictifs      |

## Fichiers livrés

- `dashboard-ca-volume.html` — équivalent du dashboard "Retail - vF" (CA/volume global, kit vs recharge, par catégorie, par centrale régionale, par groupe, par agent, par agence, par type de commande)
- `dashboard-commandes.html` — équivalent du dashboard "Retail - vF 2/3" (nombre de commandes, panier moyen, fréquence, rétention magasins)
- `dashboard-visites-terrain.html` — équivalent du dashboard "Retail - vF" terrain (visites, taux de couverture, mises en avant, réglettes, double facing)
- `dashboard-commande-via-agence.html` — équivalent du dashboard "Retail - Commande via Agence" (listes de magasins, incentives, classement agences/agents, commissions)
- `dashboard-croissance-magasins.html` — évolution du nombre de magasins actifs par groupe et par format, ARR par format de magasin
- `dashboard-magasins-inactifs.html` — liste des magasins sans recommande depuis plus de 60 jours, par agent
- `dashboard-retention-cohortes.html` — taux de réassort à 90/120 jours, rétention client et rétention du revenu par cohorte mensuelle
- `modele-donnees-visites-agences.html` — aperçu du modèle de données brut (jointure visites × magasins × agences × commissions) utilisé en amont des dashboards ci-dessus, avec la requête SQL correspondante intégrée
- `modele-donnees-visites-agences.sql` — la même requête SQL en fichier autonome (dialecte BigQuery)

**Anonymisation du SQL** : la requête ne contenait aucune donnée réelle ligne par ligne (c'est de la logique de requête, pas des enregistrements). Seuls les noms de dataset/table ont été génériqués (`landing_odoo.odoo_*` → `landing_erp.*`) car ils révélaient l'ERP utilisé en interne (Odoo) et la convention de nommage du data warehouse. Le reste — noms de colonnes, jointures, et la logique de classement Hyper/Super/Proxi par enseigne — a été conservé à l'identique : il ne référence que des enseignes déjà publiques.

Chaque fichier est autonome (HTML + CSS + JS inclus, graphiques via Chart.js chargé en CDN) et peut être ouvert directement dans un navigateur ou déposé tel quel dans un repo GitHub (ex. converti en capture d'écran pour un README, ou hébergé via GitHub Pages).
