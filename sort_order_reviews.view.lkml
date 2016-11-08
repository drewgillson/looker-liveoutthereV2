view: sort_order_reviews {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY reviews DESC) AS score FROM (SELECT
      associations.parent_sku  AS configurable_sku,
      COUNT(DISTINCT reviews.review_id ) AS reviews
    FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
    LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
    LEFT JOIN ${catalog_product_reviews.SQL_TABLE_NAME} AS reviews ON associations.parent_id = reviews.entity_id
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

  measure: reviews {
    type: sum
    sql: ${TABLE}.reviews ;;
    value_format: "0"
  }
}
