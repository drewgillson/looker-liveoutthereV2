- view: jaccard_order_product_affinity
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY product_a) AS row, * FROM (
        SELECT product_a
        , product_b
        , joint_frequency
        , top1.frequency as product_a_frequency
        , top2.frequency as product_b_frequency
        FROM (
          SELECT p1.product as product_a
          , p2.product as product_b
          , count(*) as joint_frequency
          FROM ${sales_items.SQL_TABLE_NAME} as op1
          JOIN ${sales_items.SQL_TABLE_NAME} op2
            ON op1.order_entity_id = op2.order_entity_id
          JOIN ${catalog_products.SQL_TABLE_NAME} AS p1
            ON op1.product_id = p1.entity_id
          JOIN ${catalog_products.SQL_TABLE_NAME} AS p2
            ON op2.product_id = p2.entity_id
          GROUP BY p1.product, p2.product
        ) as prop
        JOIN ${jaccard_order_product.SQL_TABLE_NAME} as top1 ON prop.product_a = top1.product
        JOIN ${jaccard_order_product.SQL_TABLE_NAME} as top2 ON prop.product_b = top2.product
      ) AS a
    indexes: [product_a]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  
  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row
  
  - dimension: product
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
    label: "Score %"
    type: sum
    value_format: "0%"
    sql: ${TABLE}.joint_frequency / CAST(${TABLE}.product_a_frequency + ${TABLE}.product_b_frequency - ${TABLE}.joint_frequency AS float)