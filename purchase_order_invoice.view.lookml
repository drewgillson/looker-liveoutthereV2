- view: purchase_order_invoice
  sql_table_name: magento.purchase_order_invoice
  fields:

  - dimension: poi_duty
    type: string
    sql: ${TABLE}.poi_duty

  - dimension: poi_gst
    type: string
    sql: ${TABLE}.poi_gst

  - dimension: poi_invoice_amount
    type: number
    sql: ${TABLE}.poi_invoice_amount

  - dimension_group: poi_invoice
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.poi_invoice_date

  - dimension_group: poi_invoice_due
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.poi_invoice_due

  - dimension: poi_invoice_ref
    type: string
    sql: ${TABLE}.poi_invoice_ref

  - dimension: poi_invoice_terms
    type: string
    sql: ${TABLE}.poi_invoice_terms

  - dimension: poi_num
    type: number
    sql: ${TABLE}.poi_num

  - dimension: poi_order_num
    type: number
    sql: ${TABLE}.poi_order_num

  - dimension: poi_paid
    type: number
    value_format_name: id
    sql: ${TABLE}.poi_paid

  - dimension: poi_shipping
    type: string
    sql: ${TABLE}.poi_shipping

  - dimension: poi_subtotal
    type: string
    sql: ${TABLE}.poi_subtotal

  - dimension: poi_unit
    type: string
    sql: ${TABLE}.poi_unit

  - measure: count
    type: count
    drill_fields: []

