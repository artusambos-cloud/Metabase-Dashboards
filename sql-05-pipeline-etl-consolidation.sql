-- ============================================================================
-- Pipeline ETL de consolidation omni-source (jointures multiples & casts)
-- ============================================================================
-- Unifie un flux hétérogène de sell-out avec des référentiels tiers (données
-- logistiques GLN, structures d'enseignes, catalogue produit), avec des
-- conversions de type explicites (CAST) défensives contre les pertes de
-- lignes lors des jointures.
-- ============================================================================

SELECT
  sell_out.sales_date AS sales_date,
  sell_out.store_name AS store_name,
  sell_out.product_sku AS product_sku,
  sell_out.quantity AS total_quantity,
  sell_out.amount_ht AS total_revenue_ht,
  /* Données enrichies issues des référentiels */
  geo.gln_code AS gln_code,
  retail.banner_name AS banner_name,
  retail.distribution_center AS regional_hub,
  catalog.category_name AS product_category
FROM `staging_zone.raw_sell_out_data` AS sell_out
/* Jointure 1 : Référentiel international logistique (GLN) */
LEFT JOIN `production_crm.dim_store_gln` AS geo
  ON CAST(sell_out.contact_id AS STRING) = CAST(geo.contact_id AS STRING)
/* Jointure 2 : Arborescence de la grande distribution (GMS) */
LEFT JOIN `production_crm.dim_retail_hierarchy` AS retail
  ON CAST(sell_out.contact_id AS STRING) = CAST(retail.contact_id AS STRING)
/* Jointure 3 : Master data product catalogue */
LEFT JOIN `production_crm.dim_products` AS catalog
  ON CAST(sell_out.product_sku AS STRING) = CAST(catalog.sku_id AS STRING)
WHERE COALESCE(sell_out.x_to_delete, FALSE) = FALSE;
