view: sales_credits_items_refunded_tax {
derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY entity_id) AS row, * FROM (

          -- Refunds associated to a credit memo item
          SELECT a.entity_id
          , b.code
          , b.title
          , b.[percent]
          , CASE
               -- In provinces that collect more than one type of tax we need to split the refunded tax amount proportionately across the different tax types
               WHEN d.region = 'British Columbia' AND b.title = 'GST' AND a.tax_class_id = 2 THEN a.refunded_tax_amount * (5/12.00)
               WHEN d.region = 'British Columbia' AND b.title = 'PST - BC' AND a.tax_class_id = 2 THEN a.refunded_tax_amount * (7/12.00)
               WHEN d.region = 'Quebec' AND b.title = 'GST' THEN a.refunded_tax_amount * (5/14.975)
               WHEN d.region = 'Quebec' AND b.title = 'QST - QC' THEN a.refunded_tax_amount * (9.975/14.975)
               ELSE a.refunded_tax_amount
          END AS refunded_tax_amount
          , a.tax_class_id
          , a.order_item_id
          FROM (
            SELECT b.entity_id, c.entity_id AS order_entity_id, a.tax_amount AS refunded_tax_amount, d.value AS tax_class_id, a.order_item_id
            FROM magento.sales_flat_creditmemo_item AS a
            INNER JOIN magento.sales_flat_creditmemo AS b
              ON a.parent_id = b.entity_id
            LEFT JOIN magento.sales_flat_order AS c
              ON b.order_id = c.entity_id
            LEFT JOIN magento.catalog_product_entity_int AS d
              ON a.product_id = d.entity_id AND d.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'tax_class_id' AND entity_type_id = 4)
            WHERE a.row_total > 0
          ) AS a
          LEFT JOIN magento.sales_order_tax AS b
            ON a.order_entity_id = b.order_id
          INNER JOIN magento.sales_order_tax_item AS c
            ON b.tax_id = c.tax_id AND a.order_item_id = c.item_id
          LEFT JOIN magento.sales_flat_order_address AS d
            ON a.order_entity_id = d.parent_id AND d.address_type = 'shipping'

          UNION ALL

          -- Refunds not associated to a credit memo item
          SELECT a.entity_id AS creditmemo_entity_id
          , b.code
          , b.title
          , b.[percent]
          , CASE
               WHEN d.region = 'British Columbia' AND b.title = 'GST' THEN a.refunded_tax_amount * (5/12.00)
               WHEN d.region = 'British Columbia' AND b.title = 'PST - BC' THEN a.refunded_tax_amount * (7/12.00)
               WHEN d.region = 'Quebec' AND b.title = 'GST' THEN a.refunded_tax_amount * (5/14.975)
               WHEN d.region = 'Quebec' AND b.title = 'QST - QC' THEN a.refunded_tax_amount * (9.975/14.975)
               ELSE a.refunded_tax_amount
          END AS refunded_tax_amount
          , a.tax_class_id
          , NULL
          FROM (
            SELECT a.entity_id
              , c.entity_id AS order_entity_id
              , CAST((ISNULL(a.adjustment_positive,0) + ISNULL(a.shipping_amount,0)) - ((ISNULL(a.adjustment_positive,0) + ISNULL(a.shipping_amount,0)) / (1 + (f.[percent] / 100))) AS money) AS refunded_tax_amount
              , 2 AS tax_class_id
            FROM magento.sales_flat_creditmemo AS a
            LEFT JOIN magento.sales_flat_order AS c
              ON a.order_id = c.entity_id
            LEFT JOIN (SELECT order_id, SUM([percent]) AS [percent] FROM magento.sales_order_tax GROUP BY order_id) AS f
              ON a.order_id = f.order_id
            WHERE (a.adjustment_positive > 0 OR a.shipping_amount > 0)
            GROUP BY a.adjustment_positive, a.shipping_amount, c.entity_id, a.entity_id, f.[percent]
          ) AS a
          LEFT JOIN magento.sales_order_tax AS b
            ON a.order_entity_id = b.order_id
          LEFT JOIN magento.sales_flat_order_address AS d
            ON a.order_entity_id = d.parent_id AND d.address_type = 'shipping'
        ) AS a
       ;;
    indexes: ["entity_id"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.row ;;
  }

  dimension: code {
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: entity_id {
    type: number
    hidden: yes
    sql: ${TABLE}.entity_id ;;
  }

  dimension: percent {
    type: number
    value_format: "0.000\%"
    sql: ${TABLE}."percent" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  measure: refunded_tax {
    label: "Refunded Tax $"
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.refunded_tax_amount ;;
  }
}
