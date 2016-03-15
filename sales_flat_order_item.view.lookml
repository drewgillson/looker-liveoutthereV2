- view: sales_flat_order_item
  sql_table_name: magento.sales_flat_order_item
  fields:

  - dimension: additional_data
    type: string
    sql: ${TABLE}.additional_data

  - dimension: amount_refunded
    type: number
    sql: ${TABLE}.amount_refunded

  - dimension: applied_rule_ids
    type: string
    sql: ${TABLE}.applied_rule_ids

  - dimension: base_amount_refunded
    type: number
    sql: ${TABLE}.base_amount_refunded

  - dimension: base_cost
    type: number
    sql: ${TABLE}.base_cost

  - dimension: base_discount_amount
    type: number
    sql: ${TABLE}.base_discount_amount

  - dimension: base_discount_invoiced
    type: number
    sql: ${TABLE}.base_discount_invoiced

  - dimension: base_discount_refunded
    type: number
    sql: ${TABLE}.base_discount_refunded

  - dimension: base_hidden_tax_amount
    type: number
    sql: ${TABLE}.base_hidden_tax_amount

  - dimension: base_hidden_tax_invoiced
    type: number
    sql: ${TABLE}.base_hidden_tax_invoiced

  - dimension: base_hidden_tax_refunded
    type: number
    sql: ${TABLE}.base_hidden_tax_refunded

  - dimension: base_original_price
    type: number
    sql: ${TABLE}.base_original_price

  - dimension: base_price
    type: number
    sql: ${TABLE}.base_price

  - dimension: base_price_incl_tax
    type: number
    sql: ${TABLE}.base_price_incl_tax

  - dimension: base_row_invoiced
    type: number
    sql: ${TABLE}.base_row_invoiced

  - dimension: base_row_total
    type: number
    sql: ${TABLE}.base_row_total

  - dimension: base_row_total_incl_tax
    type: number
    sql: ${TABLE}.base_row_total_incl_tax

  - dimension: base_tax_amount
    type: number
    sql: ${TABLE}.base_tax_amount

  - dimension: base_tax_before_discount
    type: number
    sql: ${TABLE}.base_tax_before_discount

  - dimension: base_tax_invoiced
    type: number
    sql: ${TABLE}.base_tax_invoiced

  - dimension: base_tax_refunded
    type: number
    sql: ${TABLE}.base_tax_refunded

  - dimension: base_weee_tax_applied_amount
    type: number
    sql: ${TABLE}.base_weee_tax_applied_amount

  - dimension: base_weee_tax_applied_row_amnt
    type: number
    sql: ${TABLE}.base_weee_tax_applied_row_amnt

  - dimension: base_weee_tax_applied_row_amount
    type: number
    sql: ${TABLE}.base_weee_tax_applied_row_amount

  - dimension: base_weee_tax_disposition
    type: number
    sql: ${TABLE}.base_weee_tax_disposition

  - dimension: base_weee_tax_row_disposition
    type: number
    sql: ${TABLE}.base_weee_tax_row_disposition

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: discount_amount
    type: number
    sql: ${TABLE}.discount_amount

  - dimension: discount_invoiced
    type: number
    sql: ${TABLE}.discount_invoiced

  - dimension: discount_percent
    type: number
    sql: ${TABLE}.discount_percent

  - dimension: discount_refunded
    type: number
    sql: ${TABLE}.discount_refunded

  - dimension: ext_order_item_id
    type: string
    sql: ${TABLE}.ext_order_item_id

  - dimension: final_sale
    type: number
    sql: ${TABLE}.final_sale

  - dimension: free_shipping
    type: number
    sql: ${TABLE}.free_shipping

  - dimension: gift_message_available
    type: number
    sql: ${TABLE}.gift_message_available

  - dimension: gift_message_id
    type: number
    sql: ${TABLE}.gift_message_id

  - dimension: hidden_tax_amount
    type: number
    sql: ${TABLE}.hidden_tax_amount

  - dimension: hidden_tax_canceled
    type: number
    sql: ${TABLE}.hidden_tax_canceled

  - dimension: hidden_tax_invoiced
    type: number
    sql: ${TABLE}.hidden_tax_invoiced

  - dimension: hidden_tax_refunded
    type: number
    sql: ${TABLE}.hidden_tax_refunded

  - dimension: is_nominal
    type: number
    sql: ${TABLE}.is_nominal

  - dimension: is_qty_decimal
    type: number
    sql: ${TABLE}.is_qty_decimal

  - dimension: is_virtual
    type: number
    sql: ${TABLE}.is_virtual

  - dimension: item_id
    type: number
    sql: ${TABLE}.item_id

  - dimension: locked_do_invoice
    type: number
    sql: ${TABLE}.locked_do_invoice

  - dimension: locked_do_ship
    type: number
    sql: ${TABLE}.locked_do_ship

  - dimension: marketplace_item_id
    type: string
    sql: ${TABLE}.marketplace_item_id

  - dimension: name
    type: string
    sql: ${TABLE}.name

  - dimension: no_discount
    type: number
    sql: ${TABLE}.no_discount

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id

  - dimension: original_price
    type: number
    sql: ${TABLE}.original_price

  - dimension: parent_item_id
    type: number
    sql: ${TABLE}.parent_item_id

  - dimension: price
    type: number
    sql: ${TABLE}.price

  - dimension: price_incl_tax
    type: number
    sql: ${TABLE}.price_incl_tax

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id

  - dimension: product_options
    type: string
    sql: ${TABLE}.product_options

  - dimension: product_type
    type: string
    sql: ${TABLE}.product_type

  - dimension: qty_backordered
    type: number
    sql: ${TABLE}.qty_backordered

  - dimension: qty_canceled
    type: number
    sql: ${TABLE}.qty_canceled

  - dimension: qty_invoiced
    type: number
    sql: ${TABLE}.qty_invoiced

  - dimension: qty_ordered
    type: number
    sql: ${TABLE}.qty_ordered

  - dimension: qty_refunded
    type: number
    sql: ${TABLE}.qty_refunded

  - dimension: qty_shipped
    type: number
    sql: ${TABLE}.qty_shipped

  - dimension: quote_item_id
    type: number
    sql: ${TABLE}.quote_item_id

  - dimension: row_invoiced
    type: number
    sql: ${TABLE}.row_invoiced

  - dimension: row_total
    type: number
    sql: ${TABLE}.row_total

  - dimension: row_total_incl_tax
    type: number
    sql: ${TABLE}.row_total_incl_tax

  - dimension: row_weight
    type: number
    sql: ${TABLE}.row_weight

  - dimension: sku
    type: string
    sql: ${TABLE}.sku

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: tax_amount
    type: number
    sql: ${TABLE}.tax_amount

  - dimension: tax_before_discount
    type: number
    sql: ${TABLE}.tax_before_discount

  - dimension: tax_canceled
    type: number
    sql: ${TABLE}.tax_canceled

  - dimension: tax_invoiced
    type: number
    sql: ${TABLE}.tax_invoiced

  - dimension: tax_percent
    type: number
    sql: ${TABLE}.tax_percent

  - dimension: tax_refunded
    type: number
    sql: ${TABLE}.tax_refunded

  - dimension: udropship_vendor
    type: number
    sql: ${TABLE}.udropship_vendor

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

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

  - dimension: weight
    type: number
    sql: ${TABLE}.weight

  - measure: count
    type: count
    drill_fields: [name]

