-- ============================================================================
-- Détection d'anomalies structurelles (CROSS JOIN)
-- ============================================================================
-- Cartographie la santé financière d'un réseau de distribution en confrontant
-- instantanément la performance historique de chaque magasin à une constante
-- de marché calculée dynamiquement, via un produit croisé (CROSS JOIN).
-- ============================================================================

WITH store_performance AS (
  SELECT
    sales.store_name AS store_name,
    sales.retail_group AS retail_group,
    sales.banner_name AS banner_name,
    ROUND(AVG(sales.amount_ht), 2) AS avg_revenue_store
  FROM `analytics_warehouse.fct_sell_out` AS sales
  WHERE COALESCE(sales.is_test_row, FALSE) = FALSE
  GROUP BY 1, 2, 3
),
global_market_average AS (
  SELECT
    AVG(avg_revenue_store) AS global_avg_revenue
  FROM store_performance
)
SELECT
  store.store_name,
  store.retail_group,
  store.banner_name,
  store.avg_revenue_store AS store_average_revenue,
  ROUND(market.global_avg_revenue / 2, 2) AS critical_alert_threshold
FROM store_performance AS store
CROSS JOIN global_market_average AS market
WHERE store.avg_revenue_store < (market.global_avg_revenue / 2)
  AND store.avg_revenue_store > 0
ORDER BY store.avg_revenue_store ASC;
