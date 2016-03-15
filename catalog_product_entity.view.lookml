- view: catalog_product_entity
  sql_table_name: magento.catalog_product_entity
  fields:

  - dimension: attribute_set_id
    type: number
    sql: ${TABLE}.attribute_set_id

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: entity_type_id
    type: number
    sql: ${TABLE}.entity_type_id

  - dimension: exclude_from_supply_needs
    type: number
    sql: ${TABLE}.exclude_from_supply_needs

  - dimension: has_options
    type: number
    sql: ${TABLE}.has_options

  - dimension: required_options
    type: number
    sql: ${TABLE}.required_options

  - dimension: sku
    type: string
    sql: ${TABLE}.sku

  - dimension: type_id
    type: string
    sql: ${TABLE}.type_id

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - measure: count
    type: count
    drill_fields: []

