- view: stock_movement
  sql_table_name: magento.stock_movement
  fields:

  - dimension: sm_coef
    type: number
    sql: ${TABLE}.sm_coef

  - dimension_group: sm
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.sm_date

  - dimension: sm_description
    type: string
    sql: ${TABLE}.sm_description

  - dimension_group: sm_estimated
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.sm_estimated_date

  - dimension: sm_id
    type: number
    sql: ${TABLE}.sm_id

  - dimension: sm_po_num
    type: number
    sql: ${TABLE}.sm_po_num

  - dimension: sm_product_id
    type: number
    sql: ${TABLE}.sm_product_id

  - dimension: sm_qty
    type: number
    sql: ${TABLE}.sm_qty

  - dimension: sm_source_stock
    type: number
    sql: ${TABLE}.sm_source_stock

  - dimension: sm_target_stock
    type: number
    sql: ${TABLE}.sm_target_stock

  - dimension: sm_type
    type: string
    sql: ${TABLE}.sm_type

  - dimension: sm_ui
    type: string
    sql: ${TABLE}.sm_ui

  - measure: count
    type: count
    drill_fields: []

