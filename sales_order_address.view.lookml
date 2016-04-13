- view: sales_order_address
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY entity_id) AS row, * FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY entity_id DESC) AS sequence
        FROM magento.sales_flat_order_address
        WHERE address_type = 'shipping'
        UNION ALL
        SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY entity_id DESC) AS sequence
        FROM magento.sales_flat_order_address
        WHERE address_type = 'billing'
      ) AS a
      WHERE sequence = 1
    indexes: [email, address_type]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      
  fields:

  - dimension: row
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.row

  - dimension: first_name
    type: string
    sql: ${TABLE}.firstname

  - dimension: last_name
    type: string
    sql: ${TABLE}.lastname

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
    alias: telephone_1st
    type: string
    value_format: '###-###-####'
    sql: ${TABLE}.telephone