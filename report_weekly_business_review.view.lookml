- view: reports_weekly_business_review
  derived_table:
    sql: |
      SELECT products.parent_id AS parent_id
           , products.brand + ' ' + ISNULL(CASE WHEN products.department NOT LIKE '%^%' THEN products.department END,'') + ' ' + ISNULL(products.product,'') AS long_product_name
           , products.colour AS colour
           , page_views_last_7_days.value AS page_views_last_7_days
           , page_views_14_days_ago_for_7_days.value AS page_views_14_days_ago_for_7_days
           , sales_last_7_days.units AS sales_units_last_7_days
           , sales_14_days_ago_for_7_days.units AS sales_units_14_days_ago_for_7_days
           , sales_21_days_ago_for_7_days.units AS sales_units_21_days_ago_for_7_days
           , sales_28_days_ago_for_7_days.units AS sales_units_28_days_ago_for_7_days
           , sales_last_7_days.dollars AS sales_dollars_last_7_days
           , sales_14_days_ago_for_7_days.dollars AS sales_dollars_14_days_ago_for_7_days
           , sales_21_days_ago_for_7_days.dollars AS sales_dollars_21_days_ago_for_7_days
           , sales_28_days_ago_for_7_days.dollars AS sales_dollars_28_days_ago_for_7_days
           , on_hand_90_days.quantity_available_to_sell AS units_on_hand_last_receipt_within_90_days
           , on_hand_90_days.sales_opportunity AS dollars_on_hand_last_receipt_within_90_days
           , on_hand_before_90_days.quantity_available_to_sell AS units_on_hand_last_receipt_before_90_days_ago
           , on_hand_before_90_days.sales_opportunity AS dollars_on_hand_last_receipt_before_90_days_ago
      
      FROM ${catalog_products.SQL_TABLE_NAME} AS products
      
      LEFT JOIN (
        SELECT 
          products.parent_id AS parent_id,
          COALESCE(COALESCE(        (
              SUM(DISTINCT
              (CAST(FLOOR(COALESCE(product_page_views.page_views,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
              CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),1,8) )) AS DECIMAL(38,0))
              )
              -
               SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),1,8) )) AS DECIMAL(38,0)))
            )/(1000000*1.0)
        ,0),0) AS value
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${catalog_products_page_views.SQL_TABLE_NAME} AS product_page_views ON products.url_key = product_page_views.url_key
        WHERE 
          (((product_page_views.visit) >= (DATEADD(day,-14, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND (product_page_views.visit) < (DATEADD(day,7, DATEADD(day,-14, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) ))))
        GROUP BY products.parent_id, products.colour
      ) AS page_views_14_days_ago_for_7_days
      ON products.parent_id = page_views_14_days_ago_for_7_days.parent_id

      LEFT JOIN (
        SELECT 
          products.parent_id AS parent_id,
          COALESCE(COALESCE(        (
              SUM(DISTINCT
              (CAST(FLOOR(COALESCE(product_page_views.page_views,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
              CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),1,8) )) AS DECIMAL(38,0))
              )
              -
               SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, product_page_views.row)),1,8) )) AS DECIMAL(38,0)))
            )/(1000000*1.0)
        ,0),0) AS value
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${catalog_products_page_views.SQL_TABLE_NAME} AS product_page_views ON products.url_key = product_page_views.url_key
        WHERE 
          (((product_page_views.visit) >= (DATEADD(day,-7, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND (product_page_views.visit) < (DATEADD(day,7, DATEADD(day,-7, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) ))))
        GROUP BY products.parent_id, products.colour
      ) AS page_views_last_7_days
      ON products.parent_id = page_views_last_7_days.parent_id

      LEFT JOIN (
        SELECT 
          products.parent_id,
          products.colour,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.qty,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
          ,0),0) AS units,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.row_total,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
          ,0),0) AS dollars
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
        WHERE 
          (((sales.invoice_created) >= (DATEADD(day,-7, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND (sales.invoice_created) < (DATEADD(day,7, DATEADD(day,-7, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) ))))
        GROUP BY products.parent_id, products.colour
      ) AS sales_last_7_days
      ON products.parent_id = sales_last_7_days.parent_id
      AND products.colour = sales_last_7_days.colour

      LEFT JOIN (
        SELECT 
          products.parent_id,
          products.colour,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.qty,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
          ,0),0) AS units,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.row_total,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
          ,0),0) AS dollars
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
        WHERE 
          (((sales.invoice_created) >= (DATEADD(day,-14, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND (sales.invoice_created) < (DATEADD(day,7, DATEADD(day,-14, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) ))))
        GROUP BY products.parent_id, products.colour
      ) AS sales_14_days_ago_for_7_days
      ON products.parent_id = sales_14_days_ago_for_7_days.parent_id
      AND products.colour = sales_14_days_ago_for_7_days.colour

      LEFT JOIN (
        SELECT 
          products.parent_id,
          products.colour,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.qty,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
          ,0),0) AS units,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.row_total,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
          ,0),0) AS dollars
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
        WHERE 
          (((sales.invoice_created) >= (DATEADD(day,-21, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND (sales.invoice_created) < (DATEADD(day,7, DATEADD(day,-14, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) ))))
        GROUP BY products.parent_id, products.colour
      ) AS sales_21_days_ago_for_7_days
      ON products.parent_id = sales_21_days_ago_for_7_days.parent_id
      AND products.colour = sales_21_days_ago_for_7_days.colour

      LEFT JOIN (
        SELECT 
          products.parent_id,
          products.colour,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.qty,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
          ,0),0) AS units,
          COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(sales.row_total,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sales.row)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
        ,0),0) AS dollars
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
        WHERE 
          (((sales.invoice_created) >= (DATEADD(day,-28, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND (sales.invoice_created) < (DATEADD(day,7, DATEADD(day,-14, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) ))))
        GROUP BY products.parent_id, products.colour
      ) AS sales_28_days_ago_for_7_days
      ON products.parent_id = sales_28_days_ago_for_7_days.parent_id
      AND products.colour = sales_28_days_ago_for_7_days.colour
      
      LEFT JOIN (
        SELECT 
          products.parent_id,
          products.colour,
          (COALESCE(SUM(product_facts.quantity_on_hand),0)) - (COALESCE(SUM(product_facts.quantity_reserved),0)) AS quantity_available_to_sell,
          COALESCE(SUM(product_facts.total_sales_opportunity),0) AS sales_opportunity
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
        WHERE product_facts.last_receipt >= (DATEADD(day,-89, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) )) AND product_facts.last_receipt < (DATEADD(day,90, DATEADD(day,-89, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME))))
        GROUP BY products.parent_id, products.colour
      ) AS on_hand_90_days
      ON products.parent_id = on_hand_90_days.parent_id
      AND products.colour = on_hand_90_days.colour

      LEFT JOIN (
        SELECT 
          products.parent_id,
          products.colour,
          (COALESCE(SUM(product_facts.quantity_on_hand),0)) - (COALESCE(SUM(product_facts.quantity_reserved),0)) AS quantity_available_to_sell,
          COALESCE(SUM(product_facts.total_sales_opportunity),0) AS sales_opportunity
        FROM ${catalog_products.SQL_TABLE_NAME} AS products
        LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
        WHERE product_facts.last_receipt < (DATEADD(day,-90, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ))
        GROUP BY products.parent_id, products.colour
      ) AS on_hand_before_90_days
      ON products.parent_id = on_hand_before_90_days.parent_id
      AND products.colour = on_hand_before_90_days.colour
      
      GROUP BY products.parent_id
      , products.brand + ' ' + ISNULL(CASE WHEN products.department NOT LIKE '%^%' THEN products.department END,'') + ' ' + ISNULL(products.product,'')
      , products.colour
      , page_views_last_7_days.value
      , page_views_14_days_ago_for_7_days.value
      , sales_last_7_days.units
      , sales_14_days_ago_for_7_days.units
      , sales_21_days_ago_for_7_days.units
      , sales_28_days_ago_for_7_days.units
      , sales_last_7_days.dollars
      , sales_14_days_ago_for_7_days.dollars
      , sales_21_days_ago_for_7_days.dollars
      , sales_28_days_ago_for_7_days.dollars
      , on_hand_90_days.quantity_available_to_sell
      , on_hand_90_days.sales_opportunity
      , on_hand_before_90_days.quantity_available_to_sell
      , on_hand_before_90_days.sales_opportunity

    indexes: [long_product_name]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:
  
    - dimension: parent_id
      hidden: true
      type: string
      sql: CAST(${TABLE}.parent_id AS varchar(20))
  
    - dimension: long_product_name
      sql: ${TABLE}.long_product_name

    - dimension: colour
      sql: ${TABLE}.colour
      
    - measure: page_views_last_7_days
      type: sum_distinct
      sql_distinct_key: ${TABLE}.parent_id
      sql: ${TABLE}.page_views_last_7_days
      
    - measure: page_views_14_days_ago_for_7_days
      type: sum_distinct
      sql_distinct_key: ${TABLE}.parent_id
      sql: ${TABLE}.page_views_14_days_ago_for_7_days
      
    - measure: sales_units_last_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      sql: ${TABLE}.sales_units_last_7_days
      
    - measure: sales_units_14_days_ago_for_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      sql: ${TABLE}.sales_units_14_days_ago_for_7_days

    - measure: sales_units_21_days_ago_for_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      sql: ${TABLE}.sales_units_21_days_ago_for_7_days

    - measure: sales_units_28_days_ago_for_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      sql: ${TABLE}.sales_units_28_days_ago_for_7_days

    - measure: sales_dollars_last_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '$0'
      sql: ${TABLE}.sales_dollars_last_7_days
      
    - measure: sales_dollars_14_days_ago_for_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '$0'
      sql: ${TABLE}.sales_dollars_14_days_ago_for_7_days

    - measure: sales_dollars_21_days_ago_for_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '$0'
      sql: ${TABLE}.sales_dollars_21_days_ago_for_7_days

    - measure: sales_dollars_28_days_ago_for_7_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '$0'
      sql: ${TABLE}.sales_dollars_28_days_ago_for_7_days

    - measure: units_on_hand_last_receipt_within_90_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '0'
      sql: ${TABLE}.units_on_hand_last_receipt_within_90_days
      
    - measure: dollars_on_hand_last_receipt_within_90_days
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '$0'
      sql: ${TABLE}.dollars_on_hand_last_receipt_within_90_days
      
    - measure: units_on_hand_last_receipt_before_90_days_ago
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '0'
      sql: ${TABLE}.units_on_hand_last_receipt_before_90_days_ago
      
    - measure: dollars_on_hand_last_receipt_before_90_days_ago
      type: sum_distinct
      sql_distinct_key: ${parent_id} + ${TABLE}.colour
      value_format: '$0'
      sql: ${TABLE}.dollars_on_hand_last_receipt_before_90_days_ago

