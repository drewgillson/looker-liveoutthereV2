- view: sales_order_tax_item
  sql_table_name: magento.sales_order_tax_item
  fields:

  - dimension: item_id
    type: number
    sql: ${TABLE}.item_id

  - dimension: tax_id
    type: number
    sql: ${TABLE}.tax_id

  - dimension: tax_item_id
    type: number
    sql: ${TABLE}.tax_item_id

  - dimension: tax_percent
    type: number
    sql: ${TABLE}.tax_percent

  - measure: count
    type: count
    drill_fields: []

