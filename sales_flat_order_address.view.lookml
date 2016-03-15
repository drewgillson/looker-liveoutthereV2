- view: sales_flat_order_address
  sql_table_name: magento.sales_flat_order_address
  fields:

  - dimension: address_type
    type: string
    sql: ${TABLE}.address_type

  - dimension: city
    type: string
    sql: ${TABLE}.city

  - dimension: company
    type: string
    sql: ${TABLE}.company

  - dimension: country_id
    type: string
    sql: ${TABLE}.country_id

  - dimension: customer_address_id
    type: number
    sql: ${TABLE}.customer_address_id

  - dimension: customer_id
    type: number
    sql: ${TABLE}.customer_id

  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: fax
    type: string
    sql: ${TABLE}.fax

  - dimension: firstname
    type: string
    sql: ${TABLE}.firstname

  - dimension: lastname
    type: string
    sql: ${TABLE}.lastname

  - dimension: middlename
    type: string
    sql: ${TABLE}.middlename

  - dimension: parent_id
    type: number
    sql: ${TABLE}.parent_id

  - dimension: postcode
    type: string
    sql: ${TABLE}.postcode

  - dimension: prefix
    type: string
    sql: ${TABLE}.prefix

  - dimension: quote_address_id
    type: number
    sql: ${TABLE}.quote_address_id

  - dimension: region
    type: string
    sql: ${TABLE}.region

  - dimension: region_id
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

  - dimension: vat_id
    type: string
    sql: ${TABLE}.vat_id

  - dimension: vat_is_valid
    type: number
    value_format_name: id
    sql: ${TABLE}.vat_is_valid

  - dimension: vat_request_date
    type: string
    sql: ${TABLE}.vat_request_date

  - dimension: vat_request_id
    type: string
    sql: ${TABLE}.vat_request_id

  - dimension: vat_request_success
    type: number
    sql: ${TABLE}.vat_request_success

  - measure: count
    type: count
    drill_fields: [lastname, firstname, middlename]

