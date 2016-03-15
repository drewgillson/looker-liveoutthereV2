- view: core_url_rewrite
  sql_table_name: magento.core_url_rewrite
  fields:

  - dimension: category_id
    type: number
    sql: ${TABLE}.category_id

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: id_path
    type: string
    sql: ${TABLE}.id_path

  - dimension: is_system
    type: number
    sql: ${TABLE}.is_system

  - dimension: options
    type: string
    sql: ${TABLE}.options

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - dimension: request_path
    type: string
    sql: ${TABLE}.request_path

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: target_path
    type: string
    sql: ${TABLE}.target_path

  - dimension: url_rewrite_id
    type: number
    sql: ${TABLE}.url_rewrite_id

  - measure: count
    type: count
    drill_fields: []

