- view: orderforms_budgets
  sql_table_name: orderform.budgets

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: id
    hidden: true
    primary_key: true
    type: number
    sql: ${TABLE}.id

  - dimension: department
    type: string
    sql: ${TABLE}.department

  - dimension: type
    type: string
    sql: ${TABLE}.type

  - dimension: month
    type: date
    sql: ${TABLE}.month
    
  - dimension: season
    type: string
    sql: ${TABLE}.season

  - measure: amount
    type: sum
    sql: ${TABLE}.amount
    value_format: '$#,##0'

  sets:
    detail:
      - department
      - type
      - month
      - amount