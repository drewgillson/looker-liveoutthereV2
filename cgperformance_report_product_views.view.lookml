- view: cgperformance_report_product_views
  sql_table_name: magento.cgperformance_report_product_views
  fields:

  - dimension_group: period
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.period

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - dimension: views
    type: number
    sql: ${TABLE}.views

  - measure: count
    type: count
    drill_fields: []

