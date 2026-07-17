-- ============================================================================
-- Modèle de données - Visites & Commissions Agences (exemple anonymisé)
-- ============================================================================
-- Reconstruction anonymisée d'une requête Metabase (dialecte BigQuery Standard SQL).
-- Seuls les noms de dataset / table ont été génériqués (ils révélaient l'ERP source
-- et la convention de nommage interne du data warehouse : "landing_odoo.odoo_*").
-- Aucune autre donnée sensible ne figure dans cette requête : les noms de colonnes
-- sont génériques, et la logique de classement par enseigne ne référence que des
-- enseignes publiques (Carrefour, E.Leclerc, Intermarché, U, Auchan, Casino,
-- Franprix) déjà conservées telles quelles dans le reste du repo (voir
-- PLAN_ANONYMISATION.md).
-- ============================================================================

WITH order_aggregation AS (
  /* On somme TOUT le CA par client et par jour, peu importe le nombre de commandes */
  SELECT
    sol.`Customer` AS customer_id,
    DATE(sol.`Creation Date`) AS order_date,
    SUM(sol.`Total HT`) AS total_ca_du_jour
  FROM `landing_erp.sales_order_lines_retail` AS sol
  GROUP BY 1, 2
)
SELECT
  /* --- 1. TEMPS ET IDs --- */
  v.`date` AS `creation_date_visite`,
  v.`id` AS `Visit_ID`,
  cr.`ID Contact` AS `ID_Customer`,
  /* --- 2. INFOS MAGASIN --- */
  cr.`Name` AS `Store`,
  cr.`Sales Teams` AS `Sales_Team`,
  cr.`Groupe` AS `Groupe`,
  cr.`Enseigne` AS `Enseigne`,
  cr.`Centrale Regionale` AS `Centrale`,
  cr.`Retail Customer Type` AS `Retail Customer Type`,
  cr.`Agent Commercial ID` AS `Agent Commercial ID`,
  cr.`Adresse` AS `Adresse`,
  /* --- 7. GEO & LOCALISATION ROBUSTE --- */
  REGEXP_EXTRACT(cr.`Adresse`, r'\b(\d{5})\b') AS Zip_Code,
  REGEXP_EXTRACT(cr.`Adresse`, r'\b(\d{2})\d{3}\b') AS Department_Code,
  cr.`Name` AS `Name`,
  cr.`Customer Account Code` AS `Customer Account Code`,

  CASE
    WHEN LOWER(cr.`Enseigne`) IN ('carrefour hm', 'e. leclerc', 'intermarché hm', 'u hyper', 'carrefour plateforme') THEN 'Hyper'
    WHEN LOWER(cr.`Enseigne`) IN ('carrefour market sm', 'u super', 'intermarché sm', 'auchan sm') THEN 'Super'
    WHEN LOWER(cr.`Enseigne`) IN ('intermarché express', 'intermarché autre', 'carrefour city', 'carrefour contact', 'u express', 'carrefour express', 'casino proximité', 'franprix') THEN 'Proxi'
    ELSE 'Autre'
  END AS `Store_Format`,

  /* --- 6. SCORES --- */
  ROUND(
    (
      (CASE WHEN vc.products_implanted THEN 1 ELSE 0 END) +
      (CASE WHEN vc.products_at_eye_level THEN 1 ELSE 0 END) +
      (CASE WHEN vc.shelf_talkers_installed THEN 1 ELSE 0 END) +
      (CASE WHEN vc.box_installed THEN 1 ELSE 0 END) +
      (CASE WHEN vc.doubled_facings THEN 1 ELSE 0 END) +
      (CASE WHEN vc.discussion_with_store_people THEN 1 ELSE 0 END)
    ) / 6, 2
  ) AS `Compliance_Score_Percent`,
  /* --- 3. INFOS AGENT --- */
  TRIM(SPLIT(v.`agentco_name`, ',')[SAFE_OFFSET(0)]) AS `Agence_Visite`,
  TRIM(SPLIT(v.`agentco_name`, ',')[SAFE_OFFSET(1)]) AS `Agent_Visite`,
  /* --- 4. MÉTRIQUE CA --- */
  COALESCE(oa.total_ca_du_jour, 0) AS `CA_Total_Commande`,

  /* --- 5. CHECKLISTS (Pour tes autres graphs) --- */
  /* --- Transformation des NULL en FALSE --- */
  COALESCE(vc.products_implanted, FALSE) AS products_implanted,
  COALESCE(vc.products_at_eye_level, FALSE) AS products_at_eye_level,
  COALESCE(vc.shelf_talkers_installed, FALSE) AS shelf_talkers_installed,
  COALESCE(vc.box_installed, FALSE) AS box_installed,
  COALESCE(vc.doubled_facings, FALSE) AS doubled_facings,
  COALESCE(vc.discussion_with_store_people, FALSE) AS discussion_with_store_people,
  /* --- 6. GEO --- */
  ROUND(CAST(cr.Latitude AS FLOAT64), 7) AS Latitude,
  ROUND(CAST(cr.Longitude AS FLOAT64), 7) AS Longitude
FROM `landing_erp.visits` AS v
LEFT JOIN `landing_erp.contact_retail` AS cr
  ON CAST(v.`store_contact_id` AS STRING) = CAST(cr.`ID Contact` AS STRING)
LEFT JOIN `landing_erp.visit_checklists` AS vc
  ON CAST(v.`id` AS STRING) = CAST(vc.`visit_id` AS STRING)
LEFT JOIN order_aggregation AS oa
  ON CAST(v.`store_contact_id` AS STRING) = CAST(oa.customer_id AS STRING)
  AND DATE(v.`date`) = oa.order_date
