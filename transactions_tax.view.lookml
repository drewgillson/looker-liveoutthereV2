- view: transactions_tax
  derived_table:
    sql: |
      SELECT order_id, code, title, [percent] FROM magento.sales_order_tax
      UNION ALL
      SELECT DISTINCT [order-order_number], [order-tax_lines-title], [order-tax_lines-title], [order-tax_lines-rate] * 100 FROM shopify.transactions
    indexes: [order_id]
    sql_trigger_value: |
        SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:

  - dimension: tax_id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.tax_id

  - dimension: code
    type: string
    sql: ${TABLE}.code

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id

  - dimension: percent
    type: number
    value_format: '0\%'
    sql: ${TABLE}."percent"

  - dimension: title
    type: string
    sql: ${TABLE}.title