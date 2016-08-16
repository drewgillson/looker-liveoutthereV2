
- view: orderforms_error_tracker
  derived_table: 
    sql: |
      SELECT a.*, b.po_author
      FROM orderform.error_tracker AS a
      LEFT JOIN magento.purchase_order AS b
      ON a.po_number = b.po_order_id

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: date
    type: string
    sql: ${TABLE}.date
    
  - dimension: po_author
    type: string
    sql: ${TABLE}.po_author

  - dimension: brand
    type: string
    sql: ${TABLE}.brand

  - dimension: department
    type: string
    sql: ${TABLE}.department

  - dimension: style_name
    type: string
    sql: ${TABLE}.style_name

  - dimension: style_code
    type: string
    sql: ${TABLE}.style_code

  - dimension: color_code
    type: string
    sql: ${TABLE}.color_code

  - dimension: form_link
    type: string
    sql: ${TABLE}.form_link

  - dimension: message
    type: string
    sql: ${TABLE}.message

  - dimension: po_number
    type: string
    sql: ${TABLE}.po_number

  - dimension: id
    type: number
    sql: ${TABLE}.id

  sets:
    detail:
      - date
      - brand
      - department
      - style_name
      - style_code
      - color_code
      - form_link
      - message
      - po_number
      - id

