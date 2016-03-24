- view: transactions
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY [entity_id]) AS row, * FROM (
        SELECT 'sale' AS type, 'LiveOutThere.com' AS storefront, entity_id, created_at, increment_id, NULL AS credit_memo_id, NULL AS authorization_number
        FROM magento.sales_flat_order
        WHERE marketplace_order_id IS NULL
        UNION ALL
        SELECT 'credit', 'LiveOutThere.com', order_id, created_at, increment_id, entity_id, NULL
        FROM magento.sales_flat_creditmemo
        UNION ALL
        SELECT CASE WHEN [order-transactions-kind] = 'refund' THEN 'credit' ELSE [order-transactions-kind] END, 'TheVan.ca', CAST([order-order_number] AS nvarchar(10)), [order-transactions-created_at], CAST([order-order_number] AS nvarchar(10)), NULL, [order-transactions-authorization]
        FROM shopify.transactions
        WHERE [order-transactions-status] = 'success'
        UNION ALL
        SELECT 'sale', 'Amazon', entity_id, created_at, increment_id, NULL, NULL
        FROM magento.sales_flat_order
        WHERE marketplace_order_id IS NOT NULL
      ) AS a
    indexes: [storefront, entity_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row
    
  - dimension: type
    type: string
    sql: ${TABLE}.type
    
  - dimension: entity_id
    type: string
    hidden: true
    sql: ${TABLE}.entity_id

  - dimension: credit_memo_id
    type: string
    hidden: true
    sql: ${TABLE}.credit_memo_id
    
  - dimension_group: created
    type: time
    sql: ${TABLE}.created_at

  - dimension: id
    type: string
    sql: ${TABLE}.increment_id
    links:
      - label: 'Magento Sales Order'
        url: "https://admin.liveoutthere.com/index.php/inspire/sales_order/view/order_id/{{ reconciliation.entity_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
      - label: 'Magento Credit Memo'
        url: "https://admin.liveoutthere.com/index.php/inspire/sales_creditmemo/view/creditmemo_id/{{ reconciliation.credit_memo_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
  
  - dimension: storefront
    type: string
    sql: ${TABLE}.storefront