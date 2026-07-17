-- ============================================================================
-- Modélisation temporelle mobile et seuils glissants (DATE_TRUNC)
-- ============================================================================
-- Suivi des ruptures de tendances en retail : découpe les volumes de vente
-- par mois et chaîne les CTE pour évaluer la dérive des ventes de chaque
-- magasin face à des moyennes glissantes sectorielles.
-- ============================================================================

WITH monthly_aggregated_volumes AS (
  SELECT
    sales.store_name AS store_name,
    sales.banner_name AS banner_name,
    sales.distribution_center AS distribution_center,
    DATE_TRUNC(DATE(sales.sales_date), MONTH) AS fiscal_month,
    SUM(sales.quantity) AS total_quantity_sold
  FROM `analytics_warehouse.fct_sell_out` AS sales
  WHERE COALESCE(sales.is_test_row, FALSE) = FALSE
  GROUP BY 1, 2, 3, 4
),
monthly_market_average AS (
  SELECT
    fiscal_month,
    AVG(total_quantity_sold) AS market_avg_quantity
  FROM monthly_aggregated_volumes
  GROUP BY 1
)
SELECT
  store_volume.fiscal_month,
  store_volume.store_name,
  store_volume.banner_name,
  store_volume.distribution_center AS regional_hub,
  store_volume.total_quantity_sold AS units_sold,
  ROUND(market_volume.market_avg_quantity / 2, 0) AS critical_volume_threshold
FROM monthly_aggregated_volumes AS store_volume
INNER JOIN monthly_market_average AS market_volume
  ON store_volume.fiscal_month = market_volume.fiscal_month
WHERE store_volume.total_quantity_sold < (market_volume.market_avg_quantity / 2)
  AND store_volume.total_quantity_sold > 0
ORDER BY store_volume.fiscal_month DESC, store_volume.total_quantity_sold ASC;
