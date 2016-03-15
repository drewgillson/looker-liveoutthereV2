- view: tbl_raw_data_pay_pal_settlement
  sql_table_name: tbl_RawData_PayPal_Settlement
  fields:

  - dimension: ch
    type: string
    sql: ${TABLE}.CH

  - dimension: consumer_id
    type: string
    sql: ${TABLE}."Consumer ID"

  - dimension: custom_field
    type: string
    sql: ${TABLE}."Custom Field"

  - dimension: fee_amount
    type: string
    sql: ${TABLE}."Fee Amount"

  - dimension: fee_currency
    type: string
    sql: ${TABLE}."Fee Currency"

  - dimension: fee_debit_or_credit
    type: string
    sql: ${TABLE}."Fee Debit or Credit"

  - dimension: gross_transaction_amount
    type: string
    sql: ${TABLE}."Gross Transaction Amount"

  - dimension: gross_transaction_currency
    type: string
    sql: ${TABLE}."Gross Transaction Currency"

  - dimension: invoice_id
    type: string
    sql: ${TABLE}."Invoice ID"

  - dimension: pay_pal_reference_id
    type: string
    sql: ${TABLE}."PayPal Reference ID"

  - dimension: pay_pal_reference_id_type
    type: string
    sql: ${TABLE}."PayPal Reference ID Type"

  - dimension: payment_tracking_id
    type: string
    sql: ${TABLE}."Payment Tracking ID"

  - dimension: store_id
    type: string
    sql: ${TABLE}."Store ID"

  - dimension: transaction__debit_or_credit
    type: string
    sql: ${TABLE}."Transaction  Debit or Credit"

  - dimension_group: transaction_completion
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Transaction Completion Date"

  - dimension: transaction_event_code
    type: string
    sql: ${TABLE}."Transaction Event Code"

  - dimension: transaction_id
    type: string
    sql: ${TABLE}."Transaction ID"

  - dimension_group: transaction_initiation
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Transaction Initiation Date"

  - measure: count
    type: count
    drill_fields: []

