- view: catalogrule_product_price
  sql_table_name: magento.catalogrule_product_price
  fields:

  - dimension: customer_group_id
    type: number
    sql: ${TABLE}.customer_group_id

  - dimension_group: earliest_end
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.earliest_end_date

  - dimension_group: latest_start
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.latest_start_date

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - dimension_group: rule
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.rule_date

  - dimension: rule_price
    type: number
    sql: ${TABLE}.rule_price

  - dimension: rule_product_price_id
    type: number
    sql: ${TABLE}.rule_product_price_id

  - dimension: website_id
    type: number
    sql: ${TABLE}.website_id

  - measure: count
    type: count
    drill_fields: []

