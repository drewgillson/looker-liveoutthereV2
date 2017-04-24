view: sales_credits_items_refunded_tax {
derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY entity_id) AS row, * FROM (
          SELECT b.entity_id
            , code
            , title
            , [percent]
            , SUM(CASE
                 WHEN c.region = 'British Columbia' AND title = 'GST' THEN b.refunded_tax_amount * (5/12.00)
                 WHEN c.region = 'British Columbia' AND title = 'PST - BC' THEN b.refunded_tax_amount * (7/12.00)
                 WHEN c.region = 'Quebec' AND title = 'GST' THEN b.refunded_tax_amount * (5/14.975)
                 WHEN c.region = 'Quebec' AND title = 'QST - QC' THEN b.refunded_tax_amount * (9.975/14.975)
                 ELSE b.refunded_tax_amount
            END) AS refunded_tax_amount
          FROM magento.sales_order_tax AS a
          LEFT JOIN (
            SELECT a.entity_id
              , c.entity_id AS order_entity_id
              , CAST((ISNULL(a.adjustment_positive,0) + ISNULL(a.shipping_amount,0)) - ((ISNULL(a.adjustment_positive,0) + ISNULL(a.shipping_amount,0)) / (1 + (f.[percent] / 100))) AS money) AS refunded_tax_amount
            FROM magento.sales_flat_creditmemo AS a
            LEFT JOIN magento.sales_flat_order AS c
              ON a.order_id = c.entity_id
            LEFT JOIN (SELECT order_id, SUM([percent]) AS [percent] FROM magento.sales_order_tax GROUP BY order_id) AS f
              ON a.order_id = f.order_id
            WHERE (a.adjustment_positive > 0 OR a.shipping_amount > 0)
            GROUP BY a.adjustment_positive, a.shipping_amount, c.entity_id, a.entity_id, f.[percent]
            UNION ALL
            SELECT b.entity_id, c.entity_id, a.tax_amount
            FROM magento.sales_flat_creditmemo_item AS a
            INNER JOIN magento.sales_flat_creditmemo AS b
              ON a.parent_id = b.entity_id
            LEFT JOIN magento.sales_flat_order AS c
              ON b.order_id = c.entity_id
            WHERE a.row_total > 0
          ) AS b
            ON a.order_id = b.order_entity_id
          LEFT JOIN magento.sales_flat_order_address AS c
            ON a.order_id = c.parent_id AND c.address_type = 'shipping'
          GROUP BY b.entity_id, code, title, [percent], base_real_amount
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
