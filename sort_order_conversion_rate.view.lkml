view: sort_order_conversion_rate {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY conversion_rate DESC) AS score FROM (SELECT
        associations.parent_sku  AS configurable_sku,
        100.00 * ((COUNT(DISTINCT sales.order_increment_id )) / NULLIF((COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(product_page_views.page_views ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)),0))  AS conversion_rate
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
      LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
      LEFT JOIN ${catalog_product_page_views.SQL_TABLE_NAME} AS product_page_views ON products.url_key = product_page_views.url_key
      WHERE (NOT(products.brand = 'LiveOutThere.com' )) AND (((sales.order_created ) >= ((DATEADD(day,-55, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ))) AND (sales.order_created ) < ((DATEADD(day,56, DATEADD(day,-55, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ) )))))
      GROUP BY associations.parent_sku ) AS x;;
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

  measure: conversion_rate {
    type: average
    sql: ${TABLE}.conversion_rate ;;
    value_format: "0\%"
  }
}
