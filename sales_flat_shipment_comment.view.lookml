- view: sales_flat_shipment_comment
  sql_table_name: magento.sales_flat_shipment_comment
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

  - dimension: is_vendor_notified
    type: number
    sql: ${TABLE}.is_vendor_notified

  - dimension: is_visible_on_front
    type: number
    sql: ${TABLE}.is_visible_on_front

  - dimension: is_visible_to_vendor
    type: number
    sql: ${TABLE}.is_visible_to_vendor

  - dimension: parent_id
    type: number
    sql: ${TABLE}.parent_id

  - dimension: udropship_status
    type: string
    sql: ${TABLE}.udropship_status

  - dimension: username
    type: string
    sql: ${TABLE}.username

  - measure: count
    type: count
    drill_fields: [username]

