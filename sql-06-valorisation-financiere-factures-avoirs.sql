-- ============================================================================
-- Pipeline de valorisation financière nettoyée (balance factures vs avoirs)
-- ============================================================================
-- Modélise une balance comptable analytique en réajustant au centime près le
-- chiffre d'affaires brut face aux flux d'avoirs et de retours marchandises,
-- sécurisée contre la propagation des valeurs nulles via COALESCE.
-- ============================================================================

WITH filtered_order_lines AS (
  SELECT
    line.order_line_id AS line_id,
    line.store_name AS store_name,
    line.order_status AS order_status
  FROM `production_crm.dim_sales_order_lines` AS line
  WHERE line.order_status IN ('done', 'sale')
    AND line.division_code = 'B2B_RETAIL'
)
SELECT
  invoice.invoice_date AS transaction_date,
  order_source.store_name AS store_name,
  invoice.invoice_number AS invoice_id,
  /* Arbitrage financier dynamique selon la nature de la pièce comptable */
  ROUND(SUM(
    CASE
      WHEN invoice.document_type = 'out_invoice' THEN
        COALESCE(invoice_item.line_amount_ht, 0)
      WHEN invoice.document_type = 'out_refund' THEN
        -COALESCE(invoice_item.line_amount_ht, 0)
      ELSE 0
    END
  ), 2) AS net_revenue_ht
FROM filtered_order_lines AS order_source
INNER JOIN `accounting_zone.fct_invoice_items` AS invoice_item
  ON CAST(invoice_item.source_line_id AS STRING) = CAST(order_source.line_id AS STRING)
INNER JOIN `accounting_zone.fct_invoices` AS invoice
  ON invoice.id = invoice_item.invoice_id
  AND invoice.processing_state = 'posted'
  AND invoice.document_type IN ('out_invoice', 'out_refund')
GROUP BY 1, 2, 3
ORDER BY transaction_date DESC, net_revenue_ht DESC;
