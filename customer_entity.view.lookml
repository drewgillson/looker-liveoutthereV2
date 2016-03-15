- view: customer_entity
  sql_table_name: magento.customer_entity
  fields:

  - dimension: attribute_set_id
    type: number
    sql: ${TABLE}.attribute_set_id

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: disable_auto_group_change
    type: number
    sql: ${TABLE}.disable_auto_group_change

  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: entity_type_id
    type: number
    sql: ${TABLE}.entity_type_id

  - dimension: group_id
    type: number
    sql: ${TABLE}.group_id

  - dimension: increment_id
    type: string
    sql: ${TABLE}.increment_id

  - dimension: is_active
    type: number
    sql: ${TABLE}.is_active

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - dimension: website_id
    type: number
    sql: ${TABLE}.website_id

  - measure: count
    type: count
    drill_fields: []

