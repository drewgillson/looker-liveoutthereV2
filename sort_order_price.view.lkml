view: sort_order_price {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY price DESC) AS score FROM (SELECT
        associations.parent_sku  AS configurable_sku,
        AVG(products.price) AS price
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
      WHERE
        NOT(products.brand = 'LiveOutThere.com' )
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

  measure: price {
    type: sum
    sql: ${TABLE}.price ;;
    value_format: "$#,##0"
  }
}
