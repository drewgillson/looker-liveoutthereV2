- view: catalog_effective_discounts
  suggestions: false
  # OPENQUERY is used in this view because we always want recent prices from the Magento catalog price index
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY entity_id) AS row, * FROM (
        SELECT entity_id
           , NULLIF(discount,0) AS discount
           , 'Production' AS environment
        FROM OPENQUERY(MAGENTO,'
          SELECT a.entity_id
               , ROUND(1 - (b.final_price / b.price),2) AS discount
          FROM catalog_product_entity AS a
          LEFT JOIN catalog_product_index_price AS b
            ON a.entity_id = b.entity_id AND b.customer_group_id = 0
          WHERE a.type_id = ''simple''
        ') AS x
        UNION ALL
        SELECT entity_id
           , NULLIF(discount,0) AS discount
           , 'Staging' AS environment
        FROM OPENQUERY(STAGING,'
          SELECT a.entity_id
               , ROUND(1 - (b.final_price / b.price),2) AS discount
          FROM catalog_product_entity AS a
          LEFT JOIN catalog_product_index_price AS b
            ON a.entity_id = b.entity_id AND b.customer_group_id = 0
          WHERE a.type_id = ''simple''
        ') AS y
      ) AS z
    indexes: [entity_id]
    persist_for: 8 hours

  fields:

  - dimension: row
    sql: ${TABLE}.row
    primary_key: true
    hidden: true

  - dimension: environment
    description: "Either 'Production' or 'Staging'. This dimension needs to be filtered when you use dimensions or measures from this view, otherwise you will get duplicate results."
    sql: ${TABLE}.environment
    suggestions: ['Production','Staging']

  - dimension: long_product_name_discount_value
    hidden: true
    sql: ${all_inventory.long_product_name} + CAST(${value} AS varchar(10))

  - measure: count_distinct_long_product_name_discount_value
    hidden: true
    type: count_distinct
    sql: ${long_product_name_discount_value}

  - dimension: has_multiple_discount_values
    type: yesno
    sql: ${count_distinct_long_product_name_discount_value} > 1

  - dimension: value
    description: "Discount in Magento catalog for normal customers"
    sql: ${TABLE}.discount
    type: number
    value_format: '#%'
    description: "This is the current discount in the catalog for normal customers"
    
  - measure: minimum_value
    description: "Minimum discount in Magento catalog for normal customers"
    type: min
    sql: ${value}
    value_format: '#%'
    
  - measure: maximum_value
    description: "Maximum discount in Magento catalog for normal customers"
    type: max
    sql: ${value}
    value_format: '#%'

  - measure: average_value
    description: "Average percentage discount from Magento catalog price index"
    type: avg
    sql: ${value}
    value_format: '#%'
