- view: catalog_product_entity_media_gallery
  sql_table_name: magento.catalog_product_entity_media_gallery
  fields:

  - dimension: attribute_id
    type: number
    sql: ${TABLE}.attribute_id

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: value
    type: string
    sql: ${TABLE}.value

  - dimension: value_id
    type: number
    sql: ${TABLE}.value_id

  - measure: count
    type: count
    drill_fields: []

