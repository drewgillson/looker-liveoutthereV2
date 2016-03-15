- view: catalog_product_entity_media_gallery_value
  sql_table_name: magento.catalog_product_entity_media_gallery_value
  fields:

  - dimension: disabled
    type: number
    sql: ${TABLE}.disabled

  - dimension: label
    type: string
    sql: ${TABLE}.label

  - dimension: position
    type: number
    sql: ${TABLE}.position

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: value_id
    type: number
    sql: ${TABLE}.value_id

  - measure: count
    type: count
    drill_fields: []

