- view: purchase_supplier
  sql_table_name: magento.purchase_supplier
  fields:

  - dimension: sup_account_login
    type: string
    sql: ${TABLE}.sup_account_login

  - dimension: sup_account_password
    type: string
    sql: ${TABLE}.sup_account_password

  - dimension: sup_address1
    type: string
    sql: ${TABLE}.sup_address1

  - dimension: sup_address2
    type: string
    sql: ${TABLE}.sup_address2

  - dimension: sup_carrier
    type: string
    sql: ${TABLE}.sup_carrier

  - dimension: sup_city
    type: string
    sql: ${TABLE}.sup_city

  - dimension: sup_code
    type: string
    sql: ${TABLE}.sup_code

  - dimension: sup_comments
    type: string
    sql: ${TABLE}.sup_comments

  - dimension: sup_contact
    type: string
    sql: ${TABLE}.sup_contact

  - dimension: sup_country
    type: string
    sql: ${TABLE}.sup_country

  - dimension: sup_currency
    type: string
    sql: ${TABLE}.sup_currency

  - dimension: sup_discount_level
    type: number
    sql: ${TABLE}.sup_discount_level

  - dimension: sup_fax
    type: string
    sql: ${TABLE}.sup_fax

  - dimension: sup_free_carriage_amount
    type: number
    sql: ${TABLE}.sup_free_carriage_amount

  - dimension: sup_free_carriage_weight
    type: number
    sql: ${TABLE}.sup_free_carriage_weight

  - dimension: sup_id
    type: number
    sql: ${TABLE}.sup_id

  - dimension: sup_locale
    type: string
    sql: ${TABLE}.sup_locale

  - dimension: sup_lot_account_number
    type: string
    sql: ${TABLE}.sup_lot_account_number

  - dimension: sup_mail
    type: string
    sql: ${TABLE}.sup_mail

  - dimension: sup_mediabox_id
    type: string
    sql: ${TABLE}.sup_mediabox_id

  - dimension: sup_name
    type: string
    sql: ${TABLE}.sup_name

  - dimension: sup_order_mini
    type: string
    sql: ${TABLE}.sup_order_mini

  - dimension: sup_otac_account_number
    type: string
    sql: ${TABLE}.sup_otac_account_number

  - dimension: sup_payment_delay
    type: number
    sql: ${TABLE}.sup_payment_delay

  - dimension: sup_rma_comments
    type: string
    sql: ${TABLE}.sup_rma_comments

  - dimension: sup_rma_mail
    type: string
    sql: ${TABLE}.sup_rma_mail

  - dimension: sup_rma_tel
    type: string
    sql: ${TABLE}.sup_rma_tel

  - dimension: sup_sale_online
    type: number
    sql: ${TABLE}.sup_sale_online

  - dimension: sup_shipping_delay
    type: number
    sql: ${TABLE}.sup_shipping_delay

  - dimension: sup_supply_delay
    type: string
    sql: ${TABLE}.sup_supply_delay

  - dimension: sup_supply_delay_max
    type: string
    sql: ${TABLE}.sup_supply_delay_max

  - dimension: sup_tax_rate
    type: number
    sql: ${TABLE}.sup_tax_rate

  - dimension: sup_tel
    type: string
    sql: ${TABLE}.sup_tel

  - dimension: sup_website
    type: string
    sql: ${TABLE}.sup_website

  - dimension: sup_zipcode
    type: string
    sql: ${TABLE}.sup_zipcode

  - measure: count
    type: count
    drill_fields: [sup_name]

