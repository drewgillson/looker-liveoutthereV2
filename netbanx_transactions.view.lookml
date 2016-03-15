- view: tbl_raw_data_netbanx_transactions
  sql_table_name: tbl_RawData_Netbanx_Transactions
  fields:

  - dimension: amount
    type: string
    sql: ${TABLE}.AMOUNT

  - dimension: arn
    type: string
    sql: ${TABLE}.ARN

  - dimension: auth_code
    type: string
    sql: ${TABLE}.AUTH_CODE

  - dimension: auth_mode
    type: string
    sql: ${TABLE}.AUTH_MODE

  - dimension: bank_name
    type: string
    sql: ${TABLE}.BANK_NAME

  - dimension: brand_code
    type: string
    sql: ${TABLE}.BRAND_CODE

  - dimension: card_ending
    type: string
    sql: ${TABLE}.CARD_ENDING

  - dimension: city
    type: string
    sql: ${TABLE}.CITY

  - dimension: conf_num
    type: string
    sql: ${TABLE}.CONF_NUM

  - dimension: country
    type: string
    sql: ${TABLE}.COUNTRY

  - dimension: currency_cde
    type: string
    sql: ${TABLE}.CURRENCY_CDE

  - dimension: email
    type: string
    sql: ${TABLE}.EMAIL

  - dimension: enroll_status_type
    type: string
    sql: ${TABLE}.ENROLL_STATUS_TYPE

  - dimension: error_code
    type: string
    sql: ${TABLE}.ERROR_CODE

  - dimension: first_name
    type: string
    sql: ${TABLE}.FIRST_NAME

  - dimension: fma
    type: string
    sql: ${TABLE}.FMA

  - dimension: last_name
    type: string
    sql: ${TABLE}.LAST_NAME

  - dimension: phone
    type: string
    sql: ${TABLE}.PHONE

  - dimension: province
    type: string
    sql: ${TABLE}.PROVINCE

  - dimension: street
    type: string
    sql: ${TABLE}.STREET

  - dimension: street2
    type: string
    sql: ${TABLE}.STREET2

  - dimension: tran_status
    type: string
    sql: ${TABLE}.TRAN_STATUS

  - dimension: tran_type
    type: string
    sql: ${TABLE}.TRAN_TYPE

  - dimension_group: transaction
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.TRANSACTION_DATE

  - dimension: txn_num
    type: string
    sql: ${TABLE}.TXN_NUM

  - dimension: zip
    type: string
    sql: ${TABLE}.ZIP

  - measure: count
    type: count
    drill_fields: [first_name, last_name, bank_name]

