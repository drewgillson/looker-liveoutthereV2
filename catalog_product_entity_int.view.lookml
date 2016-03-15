- view: catalog_product_entity_int
  sql_table_name: magento.catalog_product_entity_int
  fields:

  - dimension: attribute_id
    type: number
    sql: ${TABLE}.attribute_id

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: entity_type_id
    type: number
    sql: ${TABLE}.entity_type_id

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: value
    type: number
    sql: ${TABLE}.value

  - dimension: value_id
    type: number
    sql: ${TABLE}.value_id

  - measure: count
    type: count
    drill_fields: []

