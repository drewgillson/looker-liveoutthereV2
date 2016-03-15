- view: catalog_category_product
  sql_table_name: magento.catalog_category_product
  fields:

  - dimension: category_id
    type: number
    sql: ${TABLE}.category_id

  - dimension: position
    type: number
    sql: ${TABLE}.position

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - measure: count
    type: count
    drill_fields: []

