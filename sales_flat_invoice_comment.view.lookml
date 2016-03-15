- view: sales_flat_invoice_comment
  sql_table_name: magento.sales_flat_invoice_comment
  fields:

  - dimension: comment
    type: string
    sql: ${TABLE}.comment

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: is_customer_notified
    type: number
    sql: ${TABLE}.is_customer_notified

  - dimension: is_visible_on_front
    type: number
    sql: ${TABLE}.is_visible_on_front

  - dimension: parent_id
    type: number
    sql: ${TABLE}.parent_id

  - measure: count
    type: count
    drill_fields: []

