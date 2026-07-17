-- ============================================================================
-- Déduplication temporelle et extraction d'états courants
-- ============================================================================
-- Audite un flux de rapports terrain et élimine les doublons historiques pour
-- isoler, sans sous-requête lourde, le statut courant et unique de chaque
-- point de vente à l'aide d'une fonction analytique de fenêtrage.
-- ============================================================================

WITH ranked_store_visits AS (
  SELECT
    visit.id AS visit_id,
    visit.store_id AS store_id,
    visit.agent_name AS agent_name,
    visit.compliance_score AS compliance_score,
    visit.report_date AS report_date,
    /* Affectation d'un index chronologique dynamique par magasin */
    ROW_NUMBER() OVER(
      PARTITION BY visit.store_id
      ORDER BY visit.report_date DESC, visit.id DESC
    ) AS row_num
  FROM `production_crm.agent_store_visits` AS visit
  WHERE COALESCE(visit.is_deleted, FALSE) = FALSE
)
SELECT
  visit_id,
  store_id,
  agent_name,
  compliance_score,
  report_date
FROM ranked_store_visits
WHERE row_num = 1
ORDER BY report_date DESC;
