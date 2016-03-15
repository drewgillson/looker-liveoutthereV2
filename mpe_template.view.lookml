- view: mpe_template
  sql_table_name: magento.mpe_template
  fields:

  - dimension_group: date_added
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.date_added

  - dimension_group: date_updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.date_updated

  - dimension: look_url
    type: string
    sql: ${TABLE}.look_url

  - dimension: mandrill_template
    type: string
    sql: ${TABLE}.mandrill_template

  - dimension: name
    type: string
    sql: ${TABLE}.name

  - dimension: tags
    type: string
    sql: ${TABLE}.tags

  - dimension: template_id
    type: number
    sql: ${TABLE}.template_id

  - measure: count
    type: count
    drill_fields: [name]

