- view: sales_flat_quote
  sql_table_name: magento.sales_flat_quote
  fields:

  - dimension_group: anounced
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.anounced_date

  - dimension_group: anounced_date_max
    type: time
    timeframes: [date, week, month]
    convert_tz: false
    sql: ${TABLE}.anounced_date_max

  - dimension: applied_rule_ids
    type: string
    sql: ${TABLE}.applied_rule_ids

  - dimension: auctaneapi_discounts
    type: string
    sql: ${TABLE}.auctaneapi_discounts

  - dimension: base_currency_code
    type: string
    sql: ${TABLE}.base_currency_code

  - dimension: base_customer_credit_total
    type: number
    sql: ${TABLE}.base_customer_credit_total

  - dimension: base_grand_total
    type: number
    sql: ${TABLE}.base_grand_total

  - dimension: base_subtotal
    type: number
    sql: ${TABLE}.base_subtotal

  - dimension: base_subtotal_with_discount
    type: number
    sql: ${TABLE}.base_subtotal_with_discount

  - dimension: base_to_global_rate
    type: number
    sql: ${TABLE}.base_to_global_rate

  - dimension: base_to_quote_rate
    type: number
    sql: ${TABLE}.base_to_quote_rate

  - dimension: checkout_method
    type: string
    sql: ${TABLE}.checkout_method

  - dimension_group: converted
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.converted_at

  - dimension: coupon_code
    type: string
    sql: ${TABLE}.coupon_code

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: customer_credit_total
    type: number
    sql: ${TABLE}.customer_credit_total

  - dimension_group: customer_dob
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.customer_dob

  - dimension: customer_email
    type: string
    sql: ${TABLE}.customer_email

  - dimension: customer_firstname
    type: string
    sql: ${TABLE}.customer_firstname

  - dimension: customer_gender
    type: string
    sql: ${TABLE}.customer_gender

  - dimension: customer_group_id
    type: number
    sql: ${TABLE}.customer_group_id

  - dimension: customer_id
    type: number
    sql: ${TABLE}.customer_id

  - dimension: customer_is_guest
    type: number
    sql: ${TABLE}.customer_is_guest

  - dimension: customer_lastname
    type: string
    sql: ${TABLE}.customer_lastname

  - dimension: customer_middlename
    type: string
    sql: ${TABLE}.customer_middlename

  - dimension: customer_note
    type: string
    sql: ${TABLE}.customer_note

  - dimension: customer_note_notify
    type: number
    sql: ${TABLE}.customer_note_notify

  - dimension: customer_prefix
    type: string
    sql: ${TABLE}.customer_prefix

  - dimension: customer_suffix
    type: string
    sql: ${TABLE}.customer_suffix

  - dimension: customer_tax_class_id
    type: number
    sql: ${TABLE}.customer_tax_class_id

  - dimension: customer_taxvat
    type: string
    sql: ${TABLE}.customer_taxvat

  - dimension: ebizmarts_abandonedcart_counter
    type: number
    sql: ${TABLE}.ebizmarts_abandonedcart_counter

  - dimension: ebizmarts_abandonedcart_flag
    type: number
    sql: ${TABLE}.ebizmarts_abandonedcart_flag

  - dimension: ebizmarts_abandonedcart_token
    type: string
    sql: ${TABLE}.ebizmarts_abandonedcart_token

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: ext_shipping_info
    type: string
    sql: ${TABLE}.ext_shipping_info

  - dimension: gift_message_id
    type: number
    sql: ${TABLE}.gift_message_id

  - dimension: giftcert_code
    type: string
    sql: ${TABLE}.giftcert_code

  - dimension: global_currency_code
    type: string
    sql: ${TABLE}.global_currency_code

  - dimension: grand_total
    type: number
    sql: ${TABLE}.grand_total

  - dimension: is_active
    type: number
    sql: ${TABLE}.is_active

  - dimension: is_changed
    type: number
    sql: ${TABLE}.is_changed

  - dimension: is_multi_shipping
    type: number
    sql: ${TABLE}.is_multi_shipping

  - dimension: is_persistent
    type: number
    sql: ${TABLE}.is_persistent

  - dimension: is_virtual
    type: number
    sql: ${TABLE}.is_virtual

  - dimension: items_count
    type: number
    sql: ${TABLE}.items_count

  - dimension: items_qty
    type: number
    sql: ${TABLE}.items_qty

  - dimension: kount_ris_description
    type: string
    sql: ${TABLE}.kount_ris_description

  - dimension: kount_ris_response
    type: string
    sql: ${TABLE}.kount_ris_response

  - dimension: kount_ris_rule
    type: string
    sql: ${TABLE}.kount_ris_rule

  - dimension: kount_ris_score
    type: string
    sql: ${TABLE}.kount_ris_score

  - dimension: orig_order_id
    type: number
    sql: ${TABLE}.orig_order_id

  - dimension: password_hash
    type: string
    sql: ${TABLE}.password_hash

  - dimension: quote_currency_code
    type: string
    sql: ${TABLE}.quote_currency_code

  - dimension: remote_ip
    type: string
    sql: ${TABLE}.remote_ip

  - dimension: reserved_order_id
    type: string
    sql: ${TABLE}.reserved_order_id

  - dimension: store_currency_code
    type: string
    sql: ${TABLE}.store_currency_code

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: store_to_base_rate
    type: number
    sql: ${TABLE}.store_to_base_rate

  - dimension: store_to_quote_rate
    type: number
    sql: ${TABLE}.store_to_quote_rate

  - dimension: subtotal
    type: number
    sql: ${TABLE}.subtotal

  - dimension: subtotal_with_discount
    type: number
    sql: ${TABLE}.subtotal_with_discount

  - dimension: trigger_recollect
    type: number
    sql: ${TABLE}.trigger_recollect

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - measure: count
    type: count
    drill_fields: [customer_firstname, customer_middlename, customer_lastname]

