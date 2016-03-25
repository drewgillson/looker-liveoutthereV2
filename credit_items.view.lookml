- view: credit_items
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY creditmemo_created) AS row, a.*, (refunded_qty * average_cost.value) AS extended_cost FROM (
        SELECT [type], storefront, creditmemo_created, order_entity_id, creditmemo_increment_id, creditmemo_entity_id, request_type, product_id, refunded_qty, refund_for_return - adjustment_tax_amount AS refund_for_return, refund_for_other_reason - adjustment_tax_amount AS refund_for_other_reason, refund_for_shipping - shipping_tax_amount AS refund_for_shipping, adjustment_tax_amount + shipping_tax_amount AS refunded_tax, ISNULL(refund_for_return,0) + ISNULL(refund_for_other_reason,0) + ISNULL(refund_for_shipping,0) AS refunded_total FROM (
          SELECT 'credit' AS [type]
          , 'LiveOutThere.com' AS storefront
          , a.created_at AS creditmemo_created
          , c.entity_id AS order_entity_id
          , a.increment_id AS creditmemo_increment_id
          , a.entity_id AS creditmemo_entity_id
          , COALESCE(CAST(d.comment AS varchar(255)),MAX(CAST(e.comment AS varchar(255)))) AS request_type
          , NULL AS product_id
          , NULL AS refunded_qty
          , CASE WHEN CAST(d.comment AS varchar(255)) IS NOT NULL THEN a.adjustment_positive END AS refund_for_return
          , CASE WHEN MAX(CAST(e.comment AS varchar(255))) IS NOT NULL THEN a.adjustment_positive END AS refund_for_other_reason
          , a.shipping_amount AS refund_for_shipping
          , CAST(a.adjustment_positive - (a.adjustment_positive / (1 + (f.[percent] / 100))) AS money) AS adjustment_tax_amount
          , CAST(a.shipping_amount - (a.shipping_amount / (1 + (f.[percent] / 100))) AS money) AS shipping_tax_amount
          FROM magento.sales_flat_creditmemo AS a
          LEFT JOIN magento.sales_flat_creditmemo_item AS b
            ON a.entity_id = b.parent_id
          LEFT JOIN magento.sales_flat_order AS c
            ON a.order_id = c.entity_id
          LEFT JOIN magento.sales_flat_creditmemo_comment AS d
            ON a.entity_id = d.parent_id AND CAST(d.comment AS varchar(255)) = 'Return'
          LEFT JOIN magento.sales_flat_creditmemo_comment AS e
            ON a.entity_id = e.parent_id AND CAST(e.comment AS varchar(255)) <> 'Return'
          LEFT JOIN magento.sales_order_tax AS f
            ON a.order_id = f.order_id AND f.position = 1
          WHERE (a.adjustment_positive > 0 OR a.shipping_amount > 0) AND a.created_at > '2014-02-01'
          GROUP BY a.created_at, a.increment_id, a.entity_id, a.adjustment_positive, a.shipping_amount, c.entity_id, CAST(d.comment AS varchar(255)), f.[percent]
        ) AS a
        UNION ALL
        SELECT 'credit' AS [type]
        , 'LiveOutThere.com' AS storefront
        , b.created_at AS creditmemo_created
        , c.entity_id AS order_entity_id
        , b.increment_id AS creditmemo_increment_id
        , b.entity_id AS creditmemo_entity_id
        , 'Return' AS request_type
        , a.product_id
        , a.qty AS refunded_qty
        , a.row_total - ISNULL(a.discount_amount,0) AS refund_for_return
        , NULL AS refund_for_other_reason
        , NULL AS refund_for_shipping
        , a.tax_amount
        , (a.row_total - ISNULL(a.discount_amount,0)) + a.tax_amount AS total_refunded
        FROM magento.sales_flat_creditmemo_item AS a
        INNER JOIN magento.sales_flat_creditmemo AS b
          ON a.parent_id = b.entity_id
        LEFT JOIN magento.sales_flat_order AS c
          ON b.order_id = c.entity_id
        WHERE a.row_total > 0
        UNION ALL
        SELECT 'credit' AS [type]
        , 'TheVan.ca' AS storefront
        , CONVERT(VARCHAR(19),b.[order-transactions-created_at],120) + '.0000000 +00:00' AS creditmemo_created
        , b.[order-id] AS [order_entity_id]
        , a.[order-order_number] AS creditmemo_increment_id
        , b.[order-id] AS creditmemo_entity_id
        , 'Return' AS request_type
        , c.entity_id AS product_id
        , [order-line_items-total_refunded_quantity] AS refunded_qty
        , [order-line_items-total_refunded] - ([order-line_items-total_refunded] - ([order-line_items-total_refunded] / (1 + [order-tax_lines-rate]))) AS [refund_for_return]
        , NULL AS refund_for_other_reason
        , NULL AS refund_for_shipping
        , CAST([order-line_items-total_refunded] - ([order-line_items-total_refunded] / (1 + [order-tax_lines-rate])) AS money) AS tax_amount
        , [order-line_items-total_refunded] AS refunded_total
        FROM shopify.order_items AS a
        INNER JOIN shopify.transactions AS b
          ON a.[order-order_number] = b.[order-order_number]
        LEFT JOIN magento.catalog_product_entity AS c
          ON a.[order-line_items-sku] = c.sku
        WHERE a.[order-status] IN ('open', 'closed') AND a.[order-line_items-sku] != ''
        AND b.[order-transactions-kind] = 'refund' AND b.[order-transactions-status] = 'success'
      ) AS a
      LEFT JOIN (
        SELECT pop_product_id
           , ROUND(AVG((pop_price_ht * (1-(CASE WHEN pop_discount > 0 THEN pop_discount ELSE 0 END / 100)))), 2) AS value 
        FROM magento.purchase_order_product
        WHERE pop_price_ht <> 0 
        AND pop_supplied_qty > 0 
        AND pop_discount <> 100 
        GROUP BY pop_product_id
      ) AS average_cost
      ON a.product_id = average_cost.pop_product_id
    indexes: [storefront, order_entity_id, product_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: type
    type: string
    sql: ${TABLE}.type

  - dimension: storefront
    type: string
    sql: ${TABLE}.storefront

  - dimension_group: created
    type: time
    sql: ${TABLE}.creditmemo_created

  - dimension: order_entity_id
    hidden: true
    type: number
    sql: ${TABLE}.order_entity_id

  - dimension: product_id
    type: number
    hidden: true
    sql: ${TABLE}.product_id

  - dimension: credit_memo_id
    type: string
    sql: ${TABLE}.creditmemo_increment_id
    links:
      - label: 'Magento Credit Memo'
        url: "https://admin.liveoutthere.com/index.php/inspire/sales_creditmemo/view/creditmemo_id/{{ credits.creditmemo_entity_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
      - label: 'Shopify Sales Order'
        url: "https://thevan.myshopify.com/admin/orders/{{ sales.order_entity_id._value }}"
        icon_url: 'https://cdn.shopify.com/shopify-marketing_assets/static/shopify-favicon.png'

  - dimension: creditmemo_entity_id
    hidden: true
    type: number
    sql: ${TABLE}.creditmemo_entity_id

  - dimension: request_type
    type: string
    sql: ${TABLE}.request_type

  - measure: refunded_quantity
    type: sum
    sql: ${TABLE}.refunded_qty

  - measure: extended_cost
    label: "Extended Cost $"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.extended_cost

  - measure: refund_for_return
    label: "Refund for Return $"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.refund_for_return

  - measure: refund_for_other_reason
    label: "Refund for Other Reason $"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.refund_for_other_reason

  - measure: refund_for_shipping
    label: "Refund for Shipping $"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.refund_for_shipping

  - measure: refunded_tax
    label: "Refunded Tax $"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.refunded_tax

  - measure: refunded_total
    label: "Refunded Total $"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${TABLE}.refunded_total

  - measure: refunded_subtotal
    label: "Refunded Subtotal $"
    type: number
    value_format: '$#,##0.00;($#,##0.00)'
    sql: ${refunded_total} - ${refunded_tax}
    
  - measure: unique_products_refunded
    type: count_distinct
    sql: ${TABLE}.product_id

  sets:
    detail:
      - type
      - storefront
      - creditmemo_created_time
      - order_entity_id
      - creditmemo_increment_id
      - creditmemo_entity_id
      - request_type
      - product_id
      - refunded_qty
      - refund_for_return
      - refund_for_other_reason
      - refund_for_shipping
      - refunded_tax
      - refunded_total

