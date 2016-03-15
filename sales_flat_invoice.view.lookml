- view: sales_flat_invoice
  sql_table_name: magento.sales_flat_invoice
  fields:

  - dimension: base_currency_code
    type: string
    sql: ${TABLE}.base_currency_code

  - dimension: base_customer_credit_amount
    type: number
    sql: ${TABLE}.base_customer_credit_amount

  - dimension: base_discount_amount
    type: number
    sql: ${TABLE}.base_discount_amount

  - dimension: base_giftcert_amount
    type: number
    sql: ${TABLE}.base_giftcert_amount

  - dimension: base_grand_total
    type: number
    sql: ${TABLE}.base_grand_total

  - dimension: base_hidden_tax_amount
    type: number
    sql: ${TABLE}.base_hidden_tax_amount

  - dimension: base_shipping_amount
    type: number
    sql: ${TABLE}.base_shipping_amount

  - dimension: base_shipping_hidden_tax_amnt
    type: number
    sql: ${TABLE}.base_shipping_hidden_tax_amnt

  - dimension: base_shipping_incl_tax
    type: number
    sql: ${TABLE}.base_shipping_incl_tax

  - dimension: base_shipping_tax_amount
    type: number
    sql: ${TABLE}.base_shipping_tax_amount

  - dimension: base_subtotal
    type: number
    sql: ${TABLE}.base_subtotal

  - dimension: base_subtotal_incl_tax
    type: number
    sql: ${TABLE}.base_subtotal_incl_tax

  - dimension: base_tax_amount
    type: number
    sql: ${TABLE}.base_tax_amount

  - dimension: base_to_global_rate
    type: number
    sql: ${TABLE}.base_to_global_rate

  - dimension: base_to_order_rate
    type: number
    sql: ${TABLE}.base_to_order_rate

  - dimension: base_total_refunded
    type: number
    sql: ${TABLE}.base_total_refunded

  - dimension: billing_address_id
    type: number
    sql: ${TABLE}.billing_address_id

  - dimension: can_void_flag
    type: number
    sql: ${TABLE}.can_void_flag

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: customer_credit_amount
    type: number
    sql: ${TABLE}.customer_credit_amount

  - dimension: discount_amount
    type: number
    sql: ${TABLE}.discount_amount

  - dimension: email_sent
    type: number
    sql: ${TABLE}.email_sent

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: giftcert_amount
    type: number
    sql: ${TABLE}.giftcert_amount

  - dimension: global_currency_code
    type: string
    sql: ${TABLE}.global_currency_code

  - dimension: grand_total
    type: number
    sql: ${TABLE}.grand_total

  - dimension: hidden_tax_amount
    type: number
    sql: ${TABLE}.hidden_tax_amount

  - dimension: increment_id
    type: string
    sql: ${TABLE}.increment_id

  - dimension: is_used_for_refund
    type: number
    sql: ${TABLE}.is_used_for_refund

  - dimension: order_currency_code
    type: string
    sql: ${TABLE}.order_currency_code

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id

  - dimension: shipping_address_id
    type: number
    sql: ${TABLE}.shipping_address_id

  - dimension: shipping_amount
    type: number
    sql: ${TABLE}.shipping_amount

  - dimension: shipping_hidden_tax_amount
    type: number
    sql: ${TABLE}.shipping_hidden_tax_amount

  - dimension: shipping_incl_tax
    type: number
    sql: ${TABLE}.shipping_incl_tax

  - dimension: shipping_tax_amount
    type: number
    sql: ${TABLE}.shipping_tax_amount

  - dimension: state
    type: number
    sql: ${TABLE}.state

  - dimension: store_currency_code
    type: string
    sql: ${TABLE}.store_currency_code

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: store_to_base_rate
    type: number
    sql: ${TABLE}.store_to_base_rate

  - dimension: store_to_order_rate
    type: number
    sql: ${TABLE}.store_to_order_rate

  - dimension: subtotal
    type: number
    sql: ${TABLE}.subtotal

  - dimension: subtotal_incl_tax
    type: number
    sql: ${TABLE}.subtotal_incl_tax

  - dimension: tax_amount
    type: number
    sql: ${TABLE}.tax_amount

  - dimension: total_qty
    type: number
    sql: ${TABLE}.total_qty

  - dimension: transaction_id
    type: string
    sql: ${TABLE}.transaction_id

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - measure: count
    type: count
    drill_fields: []

