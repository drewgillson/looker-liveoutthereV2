- view: personalization_brand_affinity
  derived_table:
    sql: |
      SELECT ww.*, ROW_NUMBER() OVER (PARTITION BY email ORDER BY page_views DESC) AS score
      FROM (
        SELECT 
          people.email AS email,
          brand,
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
        LEFT JOIN ${customers.SQL_TABLE_NAME} AS customers ON people.email = customers.email
        LEFT JOIN ${people_products_page_views.SQL_TABLE_NAME} AS product_page_views ON people.email = product_page_views.email
        LEFT JOIN ${people_products_page_views_product.SQL_TABLE_NAME} AS product_page_views_product ON product_page_views.url_key = product_page_views_product.url_key

        -- customers who have not purchased in last 30 days
        WHERE (customers.last_order < (DATEADD(day,-30, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ))) AND (((product_page_views.visit) >= (DATEADD(day,-3, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND (product_page_views.visit) < (DATEADD(day,4, DATEADD(day,-3, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) ))))
        GROUP BY people.email, brand
      )  AS ww
    indexes: [email,score]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:
  
    - dimension: email
      primary_key: true
      hidden: true
      type: string
      sql: ${TABLE}.email
      
    - dimension: brand
      description: "Brands for products viewed in the last 3 days by people who have not made a purchase in the last 30 days."
      type: string
      sql: ${TABLE}.brand
      
    - dimension: affinity_score
      description: "Rank for the brand, based on the number of page views in the last 3 days. A rank of 1 is the highest value and indicates the person spent the most time looking at products from this brand."
      type: number
      sql: ${TABLE}.score
      
    - measure: page_views
      description: "Page views for brand in the last 3 days."
      type: sum
      value_format: '0'
      sql: ${TABLE}.page_views
      