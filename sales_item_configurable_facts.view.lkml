view: sales_items_configurable_facts {
   derived_table: {
     sql: SELECT
            associations.parent_sku AS configurable_sku,
            CONVERT(VARCHAR(10),MIN(product_facts.first_receipt) ,120) AS first_receipt
          FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
          LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
          LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
          GROUP BY associations.parent_sku ;;
     indexes: ["configurable_sku"]
     persist_for: "24 hours"
   }

   dimension: configurable_sku {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.configurable_sku ;;
   }

   dimension_group: first_receipt {
     type: time
     timeframes: [date]
     sql: ${TABLE}.first_receipt ;;
   }

  dimension: was_new_merchandise {
    type: yesno
    sql: ${first_receipt_date} IS NOT NULL;;
  }

 }
