- view: carriers_lateshipment_data
  sql_table_name: dbo.tbl_RawData_LateShipment
  fields:

  - dimension: id
    primary_key: true
    type: number
    hidden: true
    sql: ${TABLE}.id

  - dimension_group: delivery
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Delivery Date"

  - dimension: dispute_status
    type: string
    sql: ${TABLE}."Dispute Status"

  - dimension_group: estimated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Estimated Date"

  - dimension_group: ship
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Ship Date"

  - dimension: tracking_number
    type: string
    sql: ${TABLE}."Tracking Number"
    
  - measure: average_days_to_delivery
    type: avg
    value_format: '0.0'
    sql: CASE WHEN ${TABLE}."Ship Date" < ${TABLE}."Delivery Date" AND ${TABLE}."Delivery Date" IS NOT NULL THEN DATEDIFF(dd,${TABLE}."Ship Date",${TABLE}."Delivery Date") END
    
  - measure: average_days_between_estimated_and_delivered
    type: avg
    value_format: '0.0'
    sql: CASE WHEN ${TABLE}."Delivery Date" IS NOT NULL THEN DATEDIFF(dd,${TABLE}."Estimated Date",${TABLE}."Delivery Date") END
    
  - measure: count_of_lateshipment_records
    type: count