- view: purchase_order
  sql_table_name: magento.purchase_order
  fields:

  - dimension_group: po_acknowledged
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_acknowledged_date

  - dimension_group: po_arrival
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_arrival_date

  - dimension: po_author
    type: string
    sql: ${TABLE}.po_author

  - dimension_group: po_cancel
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_cancel_date

  - dimension: po_carrier
    type: string
    sql: ${TABLE}.po_carrier

  - dimension: po_category
    type: string
    sql: ${TABLE}.po_category

  - dimension: po_comments
    type: string
    sql: ${TABLE}.po_comments

  - dimension: po_currency
    type: string
    sql: ${TABLE}.po_currency

  - dimension: po_currency_change_rate
    type: number
    sql: ${TABLE}.po_currency_change_rate

  - dimension: po_data_status
    type: string
    sql: ${TABLE}.po_data_status

  - dimension: po_data_verified
    type: number
    sql: ${TABLE}.po_data_verified

  - dimension_group: po
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_date

  - dimension: po_delivery_percent
    type: number
    sql: ${TABLE}.po_delivery_percent

  - dimension: po_discount
    type: string
    sql: ${TABLE}.po_discount

  - dimension: po_dollar_total
    type: number
    sql: ${TABLE}.po_dollar_total

  - dimension: po_external_extended_cost
    type: number
    sql: ${TABLE}.po_external_extended_cost

  - dimension: po_finished
    type: number
    sql: ${TABLE}.po_finished

  - dimension: po_gender
    type: string
    sql: ${TABLE}.po_gender

  - dimension_group: po_invoice
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_invoice_date

  - dimension: po_invoice_ref
    type: string
    sql: ${TABLE}.po_invoice_ref

  - dimension: po_man_num
    type: number
    sql: ${TABLE}.po_man_num

  - dimension: po_mediabox_num
    type: string
    sql: ${TABLE}.po_mediabox_num

  - dimension: po_missing_price
    type: number
    sql: ${TABLE}.po_missing_price

  - dimension: po_num
    type: number
    sql: ${TABLE}.po_num

  - dimension: po_order_id
    type: string
    sql: ${TABLE}.po_order_id

  - dimension: po_original_season
    type: string
    sql: ${TABLE}.po_original_season

  - dimension: po_paid
    type: number
    value_format_name: id
    sql: ${TABLE}.po_paid

  - dimension_group: po_paid
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_paid_date

  - dimension_group: po_payment
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.po_payment_date

  - dimension: po_payment_type
    type: string
    sql: ${TABLE}.po_payment_type

  - dimension: po_priority
    type: string
    sql: ${TABLE}.po_priority

  - dimension: po_purchase_nature
    type: string
    sql: ${TABLE}.po_purchase_nature

  - dimension: po_sent
    type: number
    sql: ${TABLE}.po_sent

  - dimension_group: po_ship
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_ship_date

  - dimension: po_shipping_cost
    type: number
    sql: ${TABLE}.po_shipping_cost

  - dimension: po_shipping_cost_base
    type: number
    sql: ${TABLE}.po_shipping_cost_base

  - dimension: po_shortshippercentage
    type: number
    sql: ${TABLE}.po_shortshippercentage

  - dimension: po_sku_total
    type: number
    sql: ${TABLE}.po_sku_total

  - dimension: po_status
    type: string
    sql: ${TABLE}.po_status

  - dimension: po_style_total
    type: number
    sql: ${TABLE}.po_style_total

  - dimension: po_sup_num
    type: number
    sql: ${TABLE}.po_sup_num

  - dimension_group: po_supplier_notification
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_supplier_notification_date

  - dimension: po_supplier_order_ref
    type: string
    sql: ${TABLE}.po_supplier_order_ref

  - dimension_group: po_supply
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.po_supply_date

  - dimension: po_target_warehouse
    type: number
    sql: ${TABLE}.po_target_warehouse

  - dimension: po_tax_rate
    type: number
    sql: ${TABLE}.po_tax_rate

  - dimension: po_terms
    type: string
    sql: ${TABLE}.po_terms

  - dimension: po_terms_discount
    type: number
    sql: ${TABLE}.po_terms_discount

  - dimension: po_type
    type: string
    sql: ${TABLE}.po_type

  - dimension: po_unit_total
    type: number
    sql: ${TABLE}.po_unit_total

  - dimension: po_zoll_cost
    type: number
    sql: ${TABLE}.po_zoll_cost

  - dimension: po_zoll_cost_base
    type: number
    sql: ${TABLE}.po_zoll_cost_base

  - measure: count
    type: count
    drill_fields: []

