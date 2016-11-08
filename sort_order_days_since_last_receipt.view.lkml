view: sort_order_days_since_last_receipt {
  derived_table: {
    sql: SELECT
        associations.parent_sku  AS configurable_sku,
        DATEDIFF(dd,MAX(product_facts.last_receipt),GETDATE()) AS last_receipt
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
      LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
      WHERE
        NOT(products.brand = 'LiveOutThere.com' )
      GROUP BY associations.parent_sku
      HAVING MAX(product_facts.last_receipt) IS NOT NULL;;
    indexes: ["configurable_sku"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date);;
  }

  dimension: configurable_sku {
    type: string
    hidden: yes
    sql: ${TABLE}.configurable_sku ;;
  }

  dimension: score {
    description: "Days since last receipt"
    type: number
    sql: ${TABLE}.last_receipt ;;
    value_format: "0"
  }
}
