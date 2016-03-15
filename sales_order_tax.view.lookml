- view: sales_order_tax
  sql_table_name: magento.sales_order_tax
  fields:

  - dimension: amount
    type: number
    sql: ${TABLE}.amount

  - dimension: base_amount
    type: number
    sql: ${TABLE}.base_amount

  - dimension: base_real_amount
    type: number
    sql: ${TABLE}.base_real_amount

  - dimension: code
    type: string
    sql: ${TABLE}.code

  - dimension: hidden
    type: number
    sql: ${TABLE}.hidden

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id

  - dimension: percent
    type: number
    sql: ${TABLE}."percent"

  - dimension: position
    type: number
    sql: ${TABLE}.position

  - dimension: priority
    type: number
    sql: ${TABLE}.priority

  - dimension: process
    type: number
    sql: ${TABLE}.process

  - dimension: tax_id
    type: number
    sql: ${TABLE}.tax_id

  - dimension: title
    type: string
    sql: ${TABLE}.title

  - measure: count
    type: count
    drill_fields: []

