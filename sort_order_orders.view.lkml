view: sort_order_orders {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY orders DESC) AS score FROM (SELECT
      associations.parent_sku  AS configurable_sku,
      COUNT(DISTINCT sales.order_increment_id ) AS orders
    FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
    LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
    LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
    WHERE (NOT(products.brand = 'LiveOutThere.com' )) AND (((sales.order_created ) >= ((DATEADD(day,-55, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ))) AND (sales.order_created ) < ((DATEADD(day,56, DATEADD(day,-55, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ) )))))
    GROUP BY associations.parent_sku) AS x;;
    indexes: ["configurable_sku"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date);;
  }

  dimension: configurable_sku {
    type: string
    hidden: yes
    sql: ${TABLE}.configurable_sku ;;
  }

  dimension:  score {
    type: number
    sql: ${TABLE}.score ;;
    value_format: "0"
  }

  measure: orders {
    type: sum
    sql: ${TABLE}.orders ;;
    value_format: "0"
  }
}
