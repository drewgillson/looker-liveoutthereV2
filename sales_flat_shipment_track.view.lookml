- view: sales_flat_shipment_track
  sql_table_name: magento.sales_flat_shipment_track
  fields:

  - dimension: batch_id
    type: number
    sql: ${TABLE}.batch_id

  - dimension: carrier_code
    type: string
    sql: ${TABLE}.carrier_code

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: final_price
    type: number
    sql: ${TABLE}.final_price

  - dimension: height
    type: number
    sql: ${TABLE}.height

  - dimension: int_label_image
    type: string
    sql: ${TABLE}.int_label_image

  - dimension: label_format
    type: string
    sql: ${TABLE}.label_format

  - dimension: label_image
    type: string
    sql: ${TABLE}.label_image

  - dimension: label_pic
    type: string
    sql: ${TABLE}.label_pic

  - dimension: label_render_options
    type: string
    sql: ${TABLE}.label_render_options

  - dimension: length
    type: number
    sql: ${TABLE}.length

  - dimension: master_tracking_id
    type: string
    sql: ${TABLE}.master_tracking_id

  - dimension_group: next_check
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.next_check

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id

  - dimension: package_count
    type: number
    sql: ${TABLE}.package_count

  - dimension: package_idx
    type: number
    value_format_name: id
    sql: ${TABLE}.package_idx

  - dimension: parent_id
    type: number
    sql: ${TABLE}.parent_id

  - dimension: pkg_num
    type: number
    sql: ${TABLE}.pkg_num

  - dimension: qty
    type: number
    sql: ${TABLE}.qty

  - dimension: result_extra
    type: string
    sql: ${TABLE}.result_extra

  - dimension: title
    type: string
    sql: ${TABLE}.title

  - dimension: track_number
    type: string
    sql: ${TABLE}.track_number

  - dimension: udropship_status
    type: string
    sql: ${TABLE}.udropship_status

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - dimension: value
    type: number
    sql: ${TABLE}.value

  - dimension: weight
    type: number
    sql: ${TABLE}.weight

  - dimension: width
    type: number
    sql: ${TABLE}.width

  - measure: count
    type: count
    drill_fields: []

