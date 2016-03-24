- view: sales_items
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY order_created) AS row, *  FROM (
        SELECT c.created_at AS order_created
          , c.entity_id AS order_entity_id
          , c.increment_id AS order_increment_id
          , CASE WHEN a.name NOT LIKE '%Gift Card%' AND a.name NOT LIKE '%Donation%' THEN a.row_total + ISNULL(a.tax_amount,0) - ISNULL(a.discount_amount,0) END AS row_total_incl_tax
          , CASE WHEN a.name NOT LIKE '%Gift Card%' AND a.name NOT LIKE '%Donation%' THEN a.row_total - ISNULL(a.discount_amount,0) END AS row_total
          , a.tax_amount
          , a.discount_amount
          , qty
          , CASE WHEN a.name LIKE '%Gift Card%' OR a.name LIKE '%Donation%' THEN a.row_total - ISNULL(a.discount_amount,0) END AS deferred_revenue
          , a.product_id
          , 'LiveOutThere.com' AS storefront
        FROM magento.sales_flat_invoice_item AS a
        INNER JOIN magento.sales_flat_invoice AS b
          ON a.parent_id = b.entity_id
        INNER JOIN magento.sales_flat_order AS c
          ON b.order_id = c.entity_id
        WHERE row_total > 0
        UNION ALL
        SELECT b.created_at AS order_created
          , b.entity_id AS order_entity_id
          , b.increment_id AS order_increment_id
          , a.shipping_incl_tax AS row_total_incl_tax
          , a.shipping_amount AS row_total
          , a.shipping_tax_amount AS tax_amount
          , 0 AS discount_amount
          , 1 AS qty
          , NULL AS deferred_revenue
          , NULL AS product_id
          , 'LiveOutThere.com' AS storefront
        FROM magento.sales_flat_invoice AS a
        INNER JOIN magento.sales_flat_order AS b
          ON a.order_id = b.entity_id
        WHERE a.shipping_amount > 0
        UNION ALL
        SELECT CONVERT(VARCHAR(19),[order-created_at],120) + '.0000000 +00:00' AS order_created
            , [order-order_number] AS [order_entity_id]
            , [order-order_number] AS [order_increment_id]
            , [order-line_items-charged_price]  AS [row_total_incl_tax]
            , [order-line_items-charged_price] - ([order-line_items-total_tax] + ([order-line_items-total_shipping] * ([order-line_items-total_tax] / [order-line_items-total_price]))) AS [row_total]
            , [order-line_items-total_tax] + ([order-line_items-total_shipping] * ([order-line_items-total_tax] / [order-line_items-total_price])) AS tax_amount
            , 0 AS [discount_amount]
            , [order-line_items-quantity] AS [qty]
            , NULL AS deferred_revenue
            , b.entity_id AS [product_id]
            , 'TheVan.ca' AS [custom_storefront]
        FROM shopify.order_items AS a
        LEFT JOIN magento.catalog_product_entity AS b
          ON a.[order-line_items-sku] = b.sku
        WHERE [order-status] IN ('open', 'closed') AND [order-line_items-sku] != ''
      ) AS a
    indexes: [order_entity_id, order_increment_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: product_id
    type: number
    hidden: true
    sql: ${TABLE}.product_id
    
  - dimension: order_entity_id
    hidden: true
    type: number
    sql: ${TABLE}.order_entity_id

  - dimension_group: order_created
    type: time
    sql: ${TABLE}.order_created

  - dimension: order_id
    type: string
    sql: ${TABLE}.order_increment_id
    links:
      - label: 'Magento Sales Order'
        url: "https://admin.liveoutthere.com/index.php/inspire/sales_order/view/order_id/{{ sales.order_entity_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'

  - dimension: storefront
    type: string
    sql: ${TABLE}.storefront
    
  - measure: row_total
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.row_total

  - measure: tax_amount
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.tax_amount

  - measure: discount_amount
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.discount_amount

  - measure: quantity
    type: sum
    value_format: '0' 
    sql: ${TABLE}.qty

  - measure: deferred_revenue
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.deferred_revenue
    
  - measure: orders
    type: count_distinct
    sql: ${order_entity_id}


