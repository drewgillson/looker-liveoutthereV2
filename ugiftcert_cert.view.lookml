- view: ugiftcert_cert
  sql_table_name: magento.ugiftcert_cert
  fields:

  - dimension: balance
    type: number
    sql: ${TABLE}.balance

  - dimension: cert_id
    type: number
    sql: ${TABLE}.cert_id

  - dimension: cert_number
    type: string
    sql: ${TABLE}.cert_number

  - dimension: conditions_serialized
    type: string
    sql: ${TABLE}.conditions_serialized

  - dimension: currency_code
    type: string
    sql: ${TABLE}.currency_code

  - dimension_group: expire
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.expire_at

  - dimension: pdf_settings
    type: string
    sql: ${TABLE}.pdf_settings

  - dimension: pin
    type: string
    sql: ${TABLE}.pin

  - dimension: pin_hash
    type: string
    sql: ${TABLE}.pin_hash

  - dimension: recipient_address
    type: string
    sql: ${TABLE}.recipient_address

  - dimension: recipient_email
    type: string
    sql: ${TABLE}.recipient_email

  - dimension: recipient_message
    type: string
    sql: ${TABLE}.recipient_message

  - dimension: recipient_name
    type: string
    sql: ${TABLE}.recipient_name

  - dimension: sender_name
    type: string
    sql: ${TABLE}.sender_name

  - dimension: status
    type: string
    sql: ${TABLE}.status

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: toself_printed
    type: number
    sql: ${TABLE}.toself_printed

  - measure: count
    type: count
    drill_fields: [recipient_name, sender_name]

