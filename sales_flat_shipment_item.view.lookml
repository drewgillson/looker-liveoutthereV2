- view: sales_flat_shipment_item
  sql_table_name: magento.sales_flat_shipment_item
  fields:

  - dimension: additional_data
    type: string
    sql: ${TABLE}.additional_data

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: name
    type: string
    sql: ${TABLE}.name

  - dimension: order_item_id
    type: number
    sql: ${TABLE}.order_item_id

  - dimension: parent_id
    type: number
    sql: ${TABLE}.parent_id

  - dimension: price
    type: number
    sql: ${TABLE}.price

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - dimension: qty
    type: number
    sql: ${TABLE}.qty

  - dimension: qty_shipped
    type: number
    sql: ${TABLE}.qty_shipped

  - dimension: row_total
    type: number
    sql: ${TABLE}.row_total

  - dimension: sku
    type: string
    sql: ${TABLE}.sku

  - dimension: weight
    type: number
    sql: ${TABLE}.weight

  - measure: count
    type: count
    drill_fields: [name]

