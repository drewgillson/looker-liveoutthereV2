
- view: warranties
  sql_table_name: magento.lotwarranty_warranty

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: warranty_id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.warranty_id

  - dimension_group: date_added
    type: time
    sql: ${TABLE}.date_added

  - dimension: problem_comment
    type: string
    sql: ${TABLE}.problem_comment

  - dimension: customer_name
    type: string
    sql: ${TABLE}.customer_name

  - dimension: customer_phone
    type: string
    sql: ${TABLE}.customer_phone

  - dimension: customer_email
    type: string
    sql: ${TABLE}.customer_email

  - dimension: style
    type: string
    sql: ${TABLE}.style

  - dimension: season
    type: string
    sql: ${TABLE}.season

  - dimension: product_name
    type: string
    sql: ${TABLE}.product_name

  - dimension: gender
    type: string
    sql: ${TABLE}.gender

  - dimension: size
    type: string
    sql: ${TABLE}.size

  - dimension: color
    type: string
    sql: ${TABLE}.color

  - dimension: warranty_store
    type: string
    sql: ${TABLE}.warranty_store

  - dimension: ra
    type: string
    sql: ${TABLE}.ra

  - dimension: solution
    type: string
    sql: ${TABLE}.solution

  - dimension: status
    type: string
    sql: ${TABLE}.status

  - dimension: supplier_id
    type: number
    sql: ${TABLE}.supplier_id

  - dimension_group: date_updated
    type: time
    sql: ${TABLE}.date_updated

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id

  - dimension: filename
    type: string
    sql: ${TABLE}.filename

  - dimension: creditmemo_number
    type: string
    sql: ${TABLE}.creditmemo_number

  - dimension: invoice_number
    type: string
    sql: ${TABLE}.invoice_number

  - dimension: cost
    type: number
    sql: ${TABLE}.cost

  - dimension: billed_to
    type: string
    sql: ${TABLE}.billed_to

  sets:
    detail:
      - date_added_time
      - problem_comment
      - customer_name
      - customer_phone
      - customer_email
      - style
      - season
      - product_name
      - gender
      - size
      - color
      - warranty_store
      - ra
      - solution
      - status
      - supplier_id
      - date_updated_time
      - order_id
      - filename
      - creditmemo_number
      - invoice_number
      - cost
      - billed_to

