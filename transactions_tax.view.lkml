view: transactions_tax {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY order_id) AS row, * FROM (
        -- Magento
        SELECT order_id, code, title, [percent], base_real_amount AS amount FROM magento.sales_order_tax
        UNION ALL
        -- Shopify
        SELECT DISTINCT [order-order_number], [order-tax_lines-title], [order-tax_lines-title], [order-tax_lines-rate] * 100, [order-tax_lines-price] FROM shopify.transactions
        UNION ALL
        -- Amazon Marketplace
        SELECT entity_id AS order_id, [code], [code] AS [title], NULL, NULL FROM (
          SELECT a.entity_id,
            CASE WHEN b.region = 'Alberta' THEN 'GST'
            WHEN b.region = 'New Brunswick' THEN 'HST - NB'
            WHEN b.region = 'Newfoundland and Labrador' THEN 'HST - NL'
            WHEN b.region = 'Nova Scotia' THEN 'HST - NS'
            WHEN b.region = 'Ontario' THEN 'HST - ON'
            WHEN b.region = 'British Columbia' THEN 'PST - BC'
            WHEN b.region = 'Prince Edward Island' THEN 'HST - PEI'
            WHEN b.region = 'Quebec' THEN 'QST - QC'
            WHEN b.region = 'Saskatchewan' THEN 'GST'
            WHEN b.region = 'Manitoba' THEN 'GST'
            WHEN b.region = 'Yukon Territory' THEN 'GST'
            WHEN b.region = 'Nunavut' THEN 'GST'
            WHEN b.region = 'Northwest Territories' THEN 'GST' END AS [code]
          FROM magento.sales_flat_order AS a
          LEFT JOIN magento.sales_flat_order_address AS b
          ON a.entity_id = b.parent_id AND b.address_type = 'shipping'
          WHERE marketplace_order_id IS NOT NULL
        ) AS x
      ) AS a
       ;;
    indexes: ["order_id"]
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

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
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

  measure:  amount {
    label: "Collected Tax $"
    type: sum
    value_format: "$#,##0.00"
    sql:  ${TABLE}.amount ;;
  }

  # Oh man I really, really apologize for this, it's such a hack... but it works and it will be fine until we rebuild the model. If the tax rates change obviously the values below will need to be updated
  measure: refunded_tax {
    label: "Refunded Tax $"
    type: number
    value_format: "$#,##0.00"
    sql:  CASE
               WHEN MAX(${customer_address.region}) = 'British Columbia' AND MAX(${title}) = 'GST' THEN ${credits.refunded_tax} * (5/12.00)
               WHEN MAX(${customer_address.region}) = 'British Columbia' AND MAX(${title}) = 'PST - BC' THEN ${credits.refunded_tax} * (7/12.00)
               WHEN MAX(${customer_address.region}) = 'Quebec' AND MAX(${title}) = 'GST' THEN ${credits.refunded_tax} * (5/14.975)
               WHEN MAX(${customer_address.region}) = 'Quebec' AND MAX(${title}) = 'QST - QC' THEN ${credits.refunded_tax} * (9.975/14.975)
          END
          ;;
  }
}
