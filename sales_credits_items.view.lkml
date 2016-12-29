view: sales_credits_items {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY creditmemo_created) AS row,
          a.*, (refunded_qty * average_cost.value) AS extended_cost, (refunded_qty * msrp.price) AS refunded_msrp FROM (
        SELECT [type], storefront, creditmemo_created, order_entity_id, creditmemo_increment_id, creditmemo_entity_id, request_type, product_id, refunded_qty, refund_for_return - adjustment_tax_amount AS refund_for_return, refund_for_other_reason - adjustment_tax_amount AS refund_for_other_reason, refund_for_shipping - shipping_tax_amount AS refund_for_shipping, adjustment_tax_amount + shipping_tax_amount AS refunded_tax, ISNULL(refund_for_return,0) + ISNULL(refund_for_other_reason,0) + ISNULL(refund_for_shipping,0) AS refunded_total, mailed, mailed_description, refunded_to_giftcredit FROM (
          SELECT 'credit' AS [type]
          , 'LiveOutThere.com' AS storefront
          , a.created_at AS creditmemo_created
          , c.entity_id AS order_entity_id
          , a.increment_id AS creditmemo_increment_id
          , a.entity_id AS creditmemo_entity_id
          , COALESCE(CAST(d.comment AS varchar(255)),MAX(CAST(e.comment AS varchar(255)))) AS request_type
          , ISNULL(MAX(g.product_id), -1) AS product_id
          , CASE WHEN MAX(g.product_id) IS NOT NULL THEN 1 END AS refunded_qty
          , CASE WHEN CAST(d.comment AS varchar(255)) IS NOT NULL THEN a.adjustment_positive END AS refund_for_return
          , CASE WHEN MAX(CAST(e.comment AS varchar(255))) IS NOT NULL THEN a.adjustment_positive END AS refund_for_other_reason
          , a.shipping_amount AS refund_for_shipping
          , CAST(a.adjustment_positive - (a.adjustment_positive / (1 + (f.[percent] / 100))) AS money) AS adjustment_tax_amount
          , CAST(a.shipping_amount - (a.shipping_amount / (1 + (f.[percent] / 100))) AS money) AS shipping_tax_amount
          , h.ot_created_at AS mailed
          , h.ot_description AS mailed_description
          , 0.00 AS refunded_to_giftcredit
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
          LEFT JOIN magento.sales_flat_order_item AS g
            ON a.order_id = g.order_id AND a.adjustment_positive = (g.row_total - ISNULL(g.discount_amount,0) + g.tax_amount)
          LEFT JOIN (SELECT DISTINCT ot_entity_id, ot_created_at, CAST(ot_description AS nvarchar(1024)) AS ot_description FROM magento.organizer_task WHERE ot_caption = 'Return item accepted at Post Office') AS h
            ON a.order_id = h.ot_entity_id
          WHERE (a.adjustment_positive > 0 OR a.shipping_amount > 0) AND a.created_at > '2014-02-01'
          GROUP BY a.created_at, a.increment_id, a.entity_id, a.adjustment_positive, a.shipping_amount, c.entity_id, CAST(d.comment AS varchar(255)), f.[percent], h.ot_created_at, h.ot_description
        ) AS a
        UNION ALL
        SELECT 'credit' AS [type]
        , 'LiveOutThere.com' AS storefront
        , b.created_at AS creditmemo_created
        , c.entity_id AS order_entity_id
        , b.increment_id AS creditmemo_increment_id
        , b.entity_id AS creditmemo_entity_id
        , CAST(e.comment AS varchar(255)) AS request_type
        , COALESCE(a.product_id,-1)
        , a.qty AS refunded_qty
        , a.row_total - ISNULL(a.discount_amount,0) - b.giftcard_refund_amount / (COUNT(*) OVER (PARTITION BY b.entity_id)) AS refund_for_return
        , NULL AS refund_for_other_reason
        , NULL AS refund_for_shipping
        , a.tax_amount
        , (a.row_total - ISNULL(a.discount_amount,0)) + a.tax_amount - b.giftcard_refund_amount / (COUNT(*) OVER (PARTITION BY b.entity_id)) AS total_refunded
        , d.ot_created_at AS mailed
        , d.ot_description AS mailed_description
        , b.giftcard_refund_amount / (COUNT(*) OVER (PARTITION BY b.entity_id)) AS refunded_to_giftcredit
        FROM magento.sales_flat_creditmemo_item AS a
        INNER JOIN magento.sales_flat_creditmemo AS b
          ON a.parent_id = b.entity_id
        LEFT JOIN magento.sales_flat_order AS c
          ON b.order_id = c.entity_id
        LEFT JOIN (SELECT DISTINCT ot_entity_id, ot_created_at, CAST(ot_description AS nvarchar(1024)) AS ot_description FROM magento.organizer_task WHERE ot_caption = 'Return item accepted at Post Office') AS d
          ON b.order_id = d.ot_entity_id
        LEFT JOIN magento.sales_flat_creditmemo_comment AS e
          ON b.entity_id = e.parent_id
        WHERE a.row_total > 0
        UNION ALL
        SELECT 'credit' AS [type]
        , 'TheVan.ca' AS storefront
        , CONVERT(VARCHAR(19),b.[order-transactions-created_at],120) + '.0000000 +00:00' AS creditmemo_created
        , b.[order-id] AS [order_entity_id]
        , a.[order-order_number] AS creditmemo_increment_id
        , b.[order-id] AS creditmemo_entity_id
        , 'Return' AS request_type
        , COALESCE(c.entity_id,-1) AS product_id
        , [order-line_items-total_refunded_quantity] AS refunded_qty
        , [order-line_items-total_refunded] - ([order-line_items-total_refunded] - ([order-line_items-total_refunded] / (1 + [order-tax_lines-rate]))) AS [refund_for_return]
        , NULL AS refund_for_other_reason
        , NULL AS refund_for_shipping
        , CAST([order-line_items-total_refunded] - ([order-line_items-total_refunded] / (1 + [order-tax_lines-rate])) AS money) AS tax_amount
        , [order-line_items-total_refunded] AS refunded_total
        , NULL
        , NULL
        , NULL
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
      LEFT JOIN ${catalog_product.SQL_TABLE_NAME} AS msrp
      ON a.product_id = msrp.entity_id
       ;;
    indexes: ["storefront", "order_entity_id", "product_id"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  dimension: type {
    description: "Always 'credit' for credit memos"
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: storefront {
    type: string
    sql: ${TABLE}.storefront ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}.creditmemo_created ;;
  }

  dimension_group: mailed {
    type: time
    sql: ${TABLE}.mailed ;;
  }

  dimension: mailed_description {
    type: string
    sql: ${TABLE}.mailed_description ;;
  }

  dimension: order_entity_id {
    hidden: yes
    type: number
    sql: ${TABLE}.order_entity_id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: credit_memo_id {
    type: string
    sql: ${TABLE}.creditmemo_increment_id ;;

    link: {
      label: "Magento Credit Memo"
      url: "https://admin.liveoutthere.com/index.php/inspire/sales_creditmemo/view/creditmemo_id/{{ credits.creditmemo_entity_id._value | encode_uri }}"
      icon_url: "https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico"
    }

    link: {
      label: "Shopify Sales Order"
      url: "https://thevan.myshopify.com/admin/orders/{{ sales.order_entity_id._value | encode_uri }}"
      icon_url: "https://cdn.shopify.com/shopify-marketing_assets/static/shopify-favicon.png"
    }
  }

  dimension: creditmemo_entity_id {
    hidden: yes
    type: number
    sql: ${TABLE}.creditmemo_entity_id ;;
  }

  dimension: request_type {
    description: "Reason for the refund"
    type: string
    sql: ${TABLE}.request_type ;;
  }

  measure: refunded_quantity {
    description: "Quantity of units refunded (will not include independent refunds not associated to a product)"
    type: sum
    sql: ${TABLE}.refunded_qty ;;
  }

  measure: refunded_msrp {
    label: "Refunded MSRP $"
    description: "MSRP $ of units refunded"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.refunded_msrp ;;
  }

  measure: extended_cost {
    label: "Extended Cost $"
    description: "Cost of returned goods, calculating by multiplying the refunded quantity by the average landed cost"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.extended_cost ;;
  }

  measure: refund_for_return {
    label: "Refund for Return $"
    description: "Amount refunded in exchange for items that were returned"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.refund_for_return ;;
  }

  measure: refund_for_other_reason {
    label: "Refund for Other Reason $"
    description: "Amount refunded for price matches, out of stock refunds, forgotten coupon codes, etc."
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.refund_for_other_reason ;;
  }

  measure: refund_for_shipping {
    label: "Refund for Shipping $"
    description: "Amount refunded for shipping"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.refund_for_shipping ;;
  }

  measure: refunded_tax {
    label: "Refunded Tax $"
    description: "Amount of tax refunded"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.refunded_tax ;;
  }

  measure: refunded_total {
    label: "Refunded Total $"
    description: "Total amount refunded to customers (includes tax)"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.refunded_total ;;
    drill_fields: [credits_detail*]
  }

  measure: refunded_to_giftcredit {
    label: "Refunded to Gift Card $"
    description: "Total amount refunded to gift cards"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.refunded_to_giftcredit ;;
    drill_fields: [credits_detail*]
  }

  measure: refunded_subtotal {
    label: "Refunded $"
    description: "Amount refunded to customers (does not include tax). This is equal to Refund for Return + Refund for Other Reason + Refund for Shipping"
    type: number
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${refunded_total} - ${refunded_tax} ;;
    drill_fields: [credits_detail*]
  }

  measure: unique_products_refunded {
    description: "Unique number of SKUs refunded"
    type: count_distinct
    sql: ${TABLE}.product_id ;;
  }

  set: credits_detail {
    fields: [credit_memo_id, mailed_date, organizers.caption, organizers.author, organizers.sequence, refunded_subtotal, refund_for_shipping, refund_for_other_reason, refund_for_return]
  }
}
