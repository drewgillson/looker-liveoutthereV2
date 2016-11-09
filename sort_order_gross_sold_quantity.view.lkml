view: sort_order_gross_sold_quantity {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY gross_sold_quantity DESC) AS score FROM (SELECT
        associations.parent_sku  AS configurable_sku,
        COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(sales.qty ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), sales.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS gross_sold_quantity
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
      LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
      WHERE (NOT(products.brand = 'LiveOutThere.com' )) AND (((sales.order_created ) >= ((DATEADD(day,-13, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ))) AND (sales.order_created ) < ((DATEADD(day,14, DATEADD(day,-13, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ) )))))
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

  measure: gross_sold_quantity {
    type: sum
    sql: ${TABLE}.gross_sold_quantity ;;
    value_format: "0"
  }
}
