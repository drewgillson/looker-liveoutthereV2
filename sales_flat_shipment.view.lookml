- view: sales_flat_shipment
  sql_table_name: magento.sales_flat_shipment
  fields:

  - dimension: base_shipping_amount
    type: number
    sql: ${TABLE}.base_shipping_amount

  - dimension: base_tax_amount
    type: number
    sql: ${TABLE}.base_tax_amount

  - dimension: base_total_value
    type: number
    sql: ${TABLE}.base_total_value

  - dimension: billing_address_id
    type: number
    sql: ${TABLE}.billing_address_id

  - dimension: commission_percent
    type: number
    sql: ${TABLE}.commission_percent

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: customer_id
    type: number
    sql: ${TABLE}.customer_id

  - dimension: email_sent
    type: number
    sql: ${TABLE}.email_sent

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: handling_fee
    type: number
    sql: ${TABLE}.handling_fee

  - dimension: increment_id
    type: string
    sql: ${TABLE}.increment_id

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id

  - dimension: packages
    type: string
    sql: ${TABLE}.packages

  - dimension: shipment_status
    type: number
    sql: ${TABLE}.shipment_status

  - dimension: shipping_address_id
    type: number
    sql: ${TABLE}.shipping_address_id

  - dimension: shipping_amount
    type: number
    sql: ${TABLE}.shipping_amount

  - dimension: shipping_label
    type: string
    sql: ${TABLE}.shipping_label

  - dimension_group: statement
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.statement_date

  - dimension: statement_id
    type: string
    sql: ${TABLE}.statement_id

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: total_cost
    type: number
    sql: ${TABLE}.total_cost

  - dimension: total_qty
    type: number
    sql: ${TABLE}.total_qty

  - dimension: total_value
    type: number
    sql: ${TABLE}.total_value

  - dimension: total_weight
    type: number
    sql: ${TABLE}.total_weight

  - dimension: transaction_fee
    type: number
    sql: ${TABLE}.transaction_fee

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - dimension: username
    type: string
    sql: ${TABLE}.username

  - measure: count
    type: count
    drill_fields: [username]

