view: personalization_category_affinity_8_weeks {
  derived_table: {
    sql: SELECT ww.*, ROW_NUMBER() OVER (PARTITION BY email ORDER BY page_views DESC) AS score
      FROM (
        SELECT
          people.email AS email,
          reporting_category_level1 + ISNULL('/' + NULLIF(reporting_category_level2,''),'') AS category,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(product_page_views.page_views,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
        ,0),0) AS page_views
        FROM ${people.SQL_TABLE_NAME} AS people
        LEFT JOIN ${people_products_page_views.SQL_TABLE_NAME} AS product_page_views ON people.email = product_page_views.email
        LEFT JOIN ${people_products_page_views_product.SQL_TABLE_NAME} AS product_page_views_product ON product_page_views.url_key = product_page_views_product.url_key
        LEFT JOIN ${catalog_categories.SQL_TABLE_NAME} AS product_page_views_category ON product_page_views_product.entity_id = product_page_views_category.product_id
        WHERE product_page_views.visit >= DATEADD(day,-56, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )
        GROUP BY people.email, reporting_category_level1 + ISNULL('/' + NULLIF(reporting_category_level2,''),'')
      )  AS ww
       ;;
    indexes: ["email", "score"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }
}
