- view: purchase_order_product
  sql_table_name: magento.purchase_order_product
  fields:

  - dimension_group: pop_delivery
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.pop_delivery_date

  - dimension: pop_discount
    type: number
    sql: ${TABLE}.pop_discount

  - dimension: pop_eco_tax
    type: number
    sql: ${TABLE}.pop_eco_tax

  - dimension: pop_eco_tax_base
    type: number
    sql: ${TABLE}.pop_eco_tax_base

  - dimension: pop_extended_costs
    type: number
    sql: ${TABLE}.pop_extended_costs

  - dimension: pop_extended_costs_base
    type: number
    sql: ${TABLE}.pop_extended_costs_base

  - dimension: pop_num
    type: number
    sql: ${TABLE}.pop_num

  - dimension: pop_order_num
    type: number
    sql: ${TABLE}.pop_order_num

  - dimension: pop_packaging_id
    type: number
    sql: ${TABLE}.pop_packaging_id

  - dimension: pop_packaging_name
    type: string
    sql: ${TABLE}.pop_packaging_name

  - dimension: pop_packaging_value
    type: number
    sql: ${TABLE}.pop_packaging_value

  - dimension: pop_price_ht
    type: number
    sql: ${TABLE}.pop_price_ht

  - dimension: pop_price_ht_base
    type: number
    sql: ${TABLE}.pop_price_ht_base

  - dimension: pop_product_id
    type: number
    sql: ${TABLE}.pop_product_id

  - dimension: pop_product_name
    type: string
    sql: ${TABLE}.pop_product_name

  - dimension: pop_qty
    type: number
    sql: ${TABLE}.pop_qty

  - dimension: pop_supplied_qty
    type: number
    sql: ${TABLE}.pop_supplied_qty

  - dimension: pop_supplier_ref
    type: string
    sql: ${TABLE}.pop_supplier_ref

  - dimension: pop_tax_rate
    type: number
    sql: ${TABLE}.pop_tax_rate

  - dimension: pop_weight
    type: number
    sql: ${TABLE}.pop_weight

  - measure: count
    type: count
    drill_fields: [pop_product_name, pop_packaging_name]

