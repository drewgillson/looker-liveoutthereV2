- view: eav_attribute_option
  sql_table_name: magento.eav_attribute_option
  fields:

  - dimension: attribute_id
    type: number
    sql: ${TABLE}.attribute_id

  - dimension: option_id
    type: number
    sql: ${TABLE}.option_id

  - dimension: sort_order
    type: number
    sql: ${TABLE}.sort_order

  - measure: count
    type: count
    drill_fields: []

