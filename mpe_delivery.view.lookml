- view: mpe_delivery
  sql_table_name: magento.mpe_delivery
  fields:

  - dimension: delivery_id
    type: number
    sql: ${TABLE}.delivery_id

  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: template_id
    type: number
    sql: ${TABLE}.template_id

  - measure: count
    type: count
    drill_fields: []

