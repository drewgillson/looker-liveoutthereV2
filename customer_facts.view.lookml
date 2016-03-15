- view: customer_facts
  sql_table_name: magento.customer_facts
  fields:

  - dimension: city
    type: string
    sql: ${TABLE}.city

  - dimension: country_id
    type: string
    sql: ${TABLE}.country_id

  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: first_name
    type: string
    sql: ${TABLE}.first_name

  - dimension_group: first_order
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.first_order

  - dimension: has_multiple_shipping_addresses
    type: string
    sql: ${TABLE}.has_multiple_shipping_addresses

  - dimension: is_advocate
    type: string
    sql: ${TABLE}.is_advocate

  - dimension: is_friend
    type: string
    sql: ${TABLE}.is_friend

  - dimension: postcode
    type: string
    sql: ${TABLE}.postcode

  - dimension: recency
    type: number
    sql: ${TABLE}.recency

  - dimension: region
    type: string
    sql: ${TABLE}.region

  - dimension: shipping_city
    type: string
    sql: ${TABLE}.shipping_city

  - dimension: shipping_country_id
    type: string
    sql: ${TABLE}.shipping_country_id

  - dimension: shipping_postcode
    type: string
    sql: ${TABLE}.shipping_postcode

  - dimension: shipping_region
    type: string
    sql: ${TABLE}.shipping_region

  - measure: count
    type: count
    drill_fields: [first_name]

