- view: jaccard_product_view_affinity
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY product_a) AS row, * FROM (
        SELECT product_a
          , product_b
          , joint_frequency
          , top1.frequency AS product_a_frequency
          , top2.frequency AS product_b_frequency
        FROM (
          SELECT p1.url_key AS product_a
            , p2.url_key AS product_b
            , COUNT(*) AS joint_frequency
          FROM ${people_products_page_views.SQL_TABLE_NAME} AS op1
          JOIN ${people_products_page_views.SQL_TABLE_NAME} AS op2
            ON op1.email = op2.email
          JOIN (SELECT DISTINCT parent_id, url_key
            FROM ${catalog_products.SQL_TABLE_NAME}
          ) AS p1
            ON op1.url_key = p1.url_key
          JOIN (SELECT DISTINCT parent_id, url_key
            FROM ${catalog_products.SQL_TABLE_NAME}
          ) AS p2
            ON op2.url_key = p2.url_key
          GROUP BY p1.url_key, p2.url_key
        ) AS prop
        JOIN ${jaccard_product_view.SQL_TABLE_NAME} as top1
          ON prop.product_a = top1.url_key
        JOIN ${jaccard_product_view.SQL_TABLE_NAME} as top2
          ON prop.product_b = top2.url_key
      ) AS a
    indexes: [product_a]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  
  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row
    
  - dimension: product_a
    type: string
    sql: ${TABLE}.product_a

  - dimension: product_b
    type: string
    sql: ${TABLE}.product_b
    
  - dimension: joint_frequency
    type: number
    hidden: true
    sql: ${TABLE}.joint_frequency

  - dimension: product_a_frequency
    type: number
    hidden: true
    sql: ${TABLE}.product_a_frequency

  - dimension: product_b_frequency
    type: number
    hidden: true
    sql: ${TABLE}.product_b_frequency
    
  - measure: score
    type: sum
    value_format: "0.00"
    sql: ${TABLE}.joint_frequency / NULLIF(CAST(${TABLE}.product_a_frequency + ${TABLE}.product_b_frequency - ${TABLE}.joint_frequency AS float),0)