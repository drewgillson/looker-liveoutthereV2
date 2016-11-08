view: sort_order_page_views {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY page_views DESC) AS score FROM (SELECT DISTINCT
        associations.parent_sku  AS configurable_sku,
        COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(product_page_views.page_views ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_page_views.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS page_views
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
      LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
      LEFT JOIN ${catalog_categories.SQL_TABLE_NAME} AS categories ON products.entity_id = categories.product_id
      LEFT JOIN ${catalog_product_page_views.SQL_TABLE_NAME} AS product_page_views ON products.url_key = product_page_views.url_key
      WHERE products.brand != 'LiveOutThere.com'
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

  measure: page_views {
    type: sum
    sql: ${TABLE}.page_views ;;
    value_format: "0"
  }
}
