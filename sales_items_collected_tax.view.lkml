view: sales_items_collected_tax {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY order_id) AS row, * FROM (
        -- Magento
        SELECT a.order_id
        , b.code
        , b.title
        , b.[percent]
        , CASE
           -- In provinces that collect more than one type of tax we need to split the collected tax amount proportionately across the different tax types
           WHEN d.region = 'British Columbia' AND b.title = 'GST' AND a.tax_class_id = 2 THEN a.tax_amount * (5/12.00)
           WHEN d.region = 'British Columbia' AND b.title = 'PST - BC' AND a.tax_class_id = 2 THEN a.tax_amount * (7/12.00)
           WHEN d.region = 'Quebec' AND b.title = 'GST' THEN a.tax_amount * (5/14.975)
           WHEN d.region = 'Quebec' AND b.title = 'QST - QC' THEN a.tax_amount * (9.975/14.975)
           ELSE a.tax_amount
        END AS amount
        , a.tax_class_id
        FROM (
          SELECT a.order_id, a.item_id AS order_item_id, a.tax_amount, b.value AS tax_class_id
          FROM magento.sales_flat_order_item AS a
          LEFT JOIN magento.catalog_product_entity_int AS b
            ON a.product_id = b.entity_id AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'tax_class_id' AND entity_type_id = 4)
        ) AS a
        LEFT JOIN magento.sales_order_tax AS b
        ON a.order_id = b.order_id
        INNER JOIN magento.sales_order_tax_item AS c
        ON b.tax_id = c.tax_id AND a.order_item_id = c.item_id
        LEFT JOIN magento.sales_flat_order_address AS d
        ON a.order_id = d.parent_id AND d.address_type = 'shipping'

        UNION ALL

        -- Shopify
        SELECT DISTINCT [order-order_number], [order-tax_lines-title], [order-tax_lines-title], [order-tax_lines-rate] * 100, [order-tax_lines-price], NULL
        FROM shopify.transactions

        UNION ALL
        -- Amazon Marketplace (only legacy orders that don't have lines in sales_order_tax
        SELECT entity_id AS order_id, [code], [code] AS [title], NULL, NULL, 2 FROM (
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
          LEFT JOIN magento.sales_order_tax AS c
            ON a.entity_id = c.order_id
          WHERE marketplace_order_id IS NOT NULL AND c.order_id IS NULL
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
}
