- view: sales_order_address
  sql_table_name: magento.sales_flat_order_address
  fields:

  - dimension: entity_id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.entity_id

  - dimension: address_type
    type: string
    sql: ${TABLE}.address_type

  - dimension: city
    type: string
    sql: ${TABLE}.city

  - dimension: company
    type: string
    sql: ${TABLE}.company

  - dimension: country
    type: string
    sql: ${TABLE}.country_id

  - dimension: postal_code
    type: string
    sql: ${TABLE}.postcode

  - dimension: prefix
    type: string
    sql: ${TABLE}.prefix

  - dimension: region
    description: "Province or state"
    type: string
    sql: ${TABLE}.region

  - dimension: region_code
    type: number
    sql: ${TABLE}.region_id

  - dimension: street
    type: string
    sql: ${TABLE}.street

  - dimension: suffix
    type: string
    sql: ${TABLE}.suffix

  - dimension: telephone
    type: string
    sql: ${TABLE}.telephone

  - measure: telephone_1st
    label: "Telephone (1st)"
    description: "Returns the first value for Telephone - use this to prevent duplicate rows in your Look"
    type: max
    value_format: '###-###-####'
    sql: ${TABLE}.telephone

  - measure: unique_address_count
    type: count_distinct
    sql: ${TABLE}.email

