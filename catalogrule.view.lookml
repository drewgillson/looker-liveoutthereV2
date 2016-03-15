- view: catalogrule
  sql_table_name: magento.catalogrule
  fields:

  - dimension: actions_serialized
    type: string
    sql: ${TABLE}.actions_serialized

  - dimension: conditions_serialized
    type: string
    sql: ${TABLE}.conditions_serialized

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: discount_amount
    type: number
    sql: ${TABLE}.discount_amount

  - dimension_group: from
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.from_date

  - dimension: is_active
    type: number
    sql: ${TABLE}.is_active

  - dimension: name
    type: string
    sql: ${TABLE}.name

  - dimension: rule_id
    type: number
    sql: ${TABLE}.rule_id

  - dimension: simple_action
    type: string
    sql: ${TABLE}.simple_action

  - dimension: sort_order
    type: number
    sql: ${TABLE}.sort_order

  - dimension: stop_rules_processing
    type: number
    sql: ${TABLE}.stop_rules_processing

  - dimension: sub_discount_amount
    type: number
    sql: ${TABLE}.sub_discount_amount

  - dimension: sub_is_enable
    type: number
    sql: ${TABLE}.sub_is_enable

  - dimension: sub_simple_action
    type: string
    sql: ${TABLE}.sub_simple_action

  - dimension_group: to
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.to_date

  - measure: count
    type: count
    drill_fields: [name]

