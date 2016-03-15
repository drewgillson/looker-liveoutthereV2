- view: catalogrule_product
  sql_table_name: magento.catalogrule_product
  fields:

  - dimension: action_amount
    type: number
    sql: ${TABLE}.action_amount

  - dimension: action_operator
    type: string
    sql: ${TABLE}.action_operator

  - dimension: action_stop
    type: number
    sql: ${TABLE}.action_stop

  - dimension: customer_group_id
    type: number
    sql: ${TABLE}.customer_group_id

  - dimension: from_time
    type: number
    sql: ${TABLE}.from_time

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - dimension: rule_id
    type: number
    sql: ${TABLE}.rule_id

  - dimension: rule_product_id
    type: number
    sql: ${TABLE}.rule_product_id

  - dimension: sort_order
    type: number
    sql: ${TABLE}.sort_order

  - dimension: sub_discount_amount
    type: number
    sql: ${TABLE}.sub_discount_amount

  - dimension: sub_simple_action
    type: string
    sql: ${TABLE}.sub_simple_action

  - dimension: to_time
    type: number
    sql: ${TABLE}.to_time

  - dimension: website_id
    type: number
    sql: ${TABLE}.website_id

  - measure: count
    type: count
    drill_fields: []

