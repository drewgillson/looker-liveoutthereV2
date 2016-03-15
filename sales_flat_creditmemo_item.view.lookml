- view: sales_flat_creditmemo_item
  sql_table_name: magento.sales_flat_creditmemo_item
  fields:

  - dimension: additional_data
    type: string
    sql: ${TABLE}.additional_data

  - dimension: base_cost
    type: number
    sql: ${TABLE}.base_cost

  - dimension: base_discount_amount
    type: number
    sql: ${TABLE}.base_discount_amount

  - dimension: base_hidden_tax_amount
    type: number
    sql: ${TABLE}.base_hidden_tax_amount

  - dimension: base_price
    type: number
    sql: ${TABLE}.base_price

  - dimension: base_price_incl_tax
    type: number
    sql: ${TABLE}.base_price_incl_tax

  - dimension: base_row_total
    type: number
    sql: ${TABLE}.base_row_total

  - dimension: base_row_total_incl_tax
    type: number
    sql: ${TABLE}.base_row_total_incl_tax

  - dimension: base_tax_amount
    type: number
    sql: ${TABLE}.base_tax_amount

  - dimension: base_weee_tax_applied_amount
    type: number
    sql: ${TABLE}.base_weee_tax_applied_amount

  - dimension: base_weee_tax_applied_row_amnt
    type: number
    sql: ${TABLE}.base_weee_tax_applied_row_amnt

  - dimension: base_weee_tax_disposition
    type: number
    sql: ${TABLE}.base_weee_tax_disposition

  - dimension: base_weee_tax_row_disposition
    type: number
    sql: ${TABLE}.base_weee_tax_row_disposition

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: discount_amount
    type: number
    sql: ${TABLE}.discount_amount

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: hidden_tax_amount
    type: number
    sql: ${TABLE}.hidden_tax_amount

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

  - dimension: price_incl_tax
    type: number
    sql: ${TABLE}.price_incl_tax

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - dimension: qty
    type: number
    sql: ${TABLE}.qty

  - dimension: row_total
    type: number
    sql: ${TABLE}.row_total

  - dimension: row_total_incl_tax
    type: number
    sql: ${TABLE}.row_total_incl_tax

  - dimension: sku
    type: string
    sql: ${TABLE}.sku

  - dimension: tax_amount
    type: number
    sql: ${TABLE}.tax_amount

  - dimension: weee_tax_applied
    type: string
    sql: ${TABLE}.weee_tax_applied

  - dimension: weee_tax_applied_amount
    type: number
    sql: ${TABLE}.weee_tax_applied_amount

  - dimension: weee_tax_applied_row_amount
    type: number
    sql: ${TABLE}.weee_tax_applied_row_amount

  - dimension: weee_tax_disposition
    type: number
    sql: ${TABLE}.weee_tax_disposition

  - dimension: weee_tax_row_disposition
    type: number
    sql: ${TABLE}.weee_tax_row_disposition

  - measure: count
    type: count
    drill_fields: [name]

