- view: gift_certificates
  sql_table_name: magento.ugiftcert_cert
  fields:

  - dimension: cert_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.cert_id
    
  - measure: balance
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.balance

  - dimension: certificate_number
    type: string
    sql: ${TABLE}.cert_number

  - dimension: recipient_email
    type: string
    sql: ${TABLE}.recipient_email

  - dimension: sender_name
    type: string
    sql: ${TABLE}.sender_name

  - dimension: status
    label: "Is Active"
    type: yesno
    sql: ${TABLE}.status = 'A'