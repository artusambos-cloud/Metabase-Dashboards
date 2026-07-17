-- ============================================================================
-- Moteur de normalisation textuelle et classification (REGEXP)
-- ============================================================================
-- Corrige la mauvaise qualité de données d'un catalogue produit (Master Data)
-- en utilisant des expressions régulières pour identifier et reclassifier à
-- la volée le mix produit, en s'affranchissant des erreurs de saisie.
-- ============================================================================

SELECT
  sales.sales_date AS sales_date,
  sales.store_name AS store_name,
  sales.product_sku AS product_sku,
  sales.quantity AS quantity_sold,
  product.category_name AS catalog_category,
  /* Override dynamique de la classification via Regex sur le SKU technique */
  CASE
    WHEN REGEXP_CONTAINS(LOWER(CAST(sales.product_sku AS STRING)), r'(box|pack|kit)')
      THEN 'Bundled Kit'
    ELSE COALESCE(product.type_name, 'Standard Refill')
  END AS computed_product_type
FROM `analytics_warehouse.fct_sell_out` AS sales
LEFT JOIN `production_crm.dim_products` AS product
  ON CAST(sales.product_sku AS STRING) = CAST(product.sku_id AS STRING)
WHERE COALESCE(sales.is_test_row, FALSE) = FALSE;
