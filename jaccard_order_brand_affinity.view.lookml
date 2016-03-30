- view: jaccard_order_brand_affinity
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY brand_a) AS row, * FROM (
        SELECT brand_a
        , brand_b
        , joint_frequency
        , top1.frequency as brand_a_frequency
        , top2.frequency as brand_b_frequency
        FROM (
          SELECT p1.brand as brand_a
          , p2.brand as brand_b
          , count(*) as joint_frequency
          FROM ${sales_items.SQL_TABLE_NAME} as op1
          JOIN ${sales_items.SQL_TABLE_NAME} op2
            ON op1.order_entity_id = op2.order_entity_id
          JOIN ${catalog_products.SQL_TABLE_NAME} AS p1
            ON op1.product_id = p1.entity_id
          JOIN ${catalog_products.SQL_TABLE_NAME} AS p2
            ON op2.product_id = p2.entity_id
          GROUP BY p1.brand, p2.brand
        ) as prop
        JOIN ${jaccard_order_brand.SQL_TABLE_NAME} as top1 ON prop.brand_a = top1.brand
        JOIN ${jaccard_order_brand.SQL_TABLE_NAME} as top2 ON prop.brand_b = top2.brand
      ) AS a
    indexes: [brand_a]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  
  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row
    
  - dimension: value
    description: "Lists brands that the brand you have chosen from Products has an affinity for (filter the Brand dimension from Products to a specific value before using this dimension)" 
    type: string
    sql: ${TABLE}.brand_b
    
  - dimension: joint_frequency
    type: number
    hidden: true
    sql: ${TABLE}.joint_frequency

  - dimension: brand_a_frequency
    type: number
    hidden: true
    sql: ${TABLE}.brand_a_frequency

  - dimension: brand_b_frequency
    type: number
    hidden: true
    sql: ${TABLE}.brand_b_frequency
    
  - measure: score
    label: "Score"
    description: "Affinity score using the 'Jaccard index'. How likely is this brand to be purchased along with the brand you have filtered for?"
    type: sum
    value_format: "0.00"
    sql: ${TABLE}.joint_frequency / CAST(${TABLE}.brand_a_frequency + ${TABLE}.brand_b_frequency - ${TABLE}.joint_frequency AS float)