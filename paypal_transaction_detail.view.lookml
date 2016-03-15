- view: tbl_raw_data_pay_pal_transaction_detail
  sql_table_name: tbl_RawData_PayPal_Transaction_Detail
  fields:

  - dimension: 3_pl_reference_id
    type: string
    sql: ${TABLE}."3PL Reference ID"

  - dimension: auction_buyer_id
    type: string
    sql: ${TABLE}."Auction Buyer ID"

  - dimension: auction_closing_date
    type: string
    sql: ${TABLE}."Auction Closing Date"

  - dimension: auction_site
    type: string
    sql: ${TABLE}."Auction Site"

  - dimension: authorization_review_status
    type: string
    sql: ${TABLE}."Authorization Review Status"

  - dimension: billing_address_city
    type: string
    sql: ${TABLE}."Billing Address City"

  - dimension: billing_address_country
    type: string
    sql: ${TABLE}."Billing Address Country"

  - dimension: billing_address_line1
    type: string
    sql: ${TABLE}."Billing Address Line1"

  - dimension: billing_address_line2
    type: string
    sql: ${TABLE}."Billing Address Line2"

  - dimension: billing_address_state
    type: string
    sql: ${TABLE}."Billing Address State"

  - dimension: billing_address_zip
    type: string
    sql: ${TABLE}."Billing Address Zip"

  - dimension: card_type
    type: string
    sql: ${TABLE}."Card Type"

  - dimension: ch
    type: string
    sql: ${TABLE}.CH

  - dimension: checkout_type
    type: string
    sql: ${TABLE}."Checkout Type"

  - dimension: consumer_business_name
    type: string
    sql: ${TABLE}."Consumer Business Name"

  - dimension: consumer_id
    type: string
    sql: ${TABLE}."Consumer ID"

  - dimension: coupons
    type: string
    sql: ${TABLE}.Coupons

  - dimension: custom_field
    type: string
    sql: ${TABLE}."Custom Field"

  - dimension: fee_amount
    type: number
    sql: ${TABLE}."Fee Amount"

  - dimension: fee_currency
    type: string
    sql: ${TABLE}."Fee Currency"

  - dimension: fee_debit_or_credit
    type: string
    sql: ${TABLE}."Fee Debit or Credit"

  - dimension: first_name
    type: string
    sql: ${TABLE}."First Name"

  - dimension: gross_transaction_amount
    type: number
    sql: ${TABLE}."Gross Transaction Amount"

  - dimension: gross_transaction_currency
    type: string
    sql: ${TABLE}."Gross Transaction Currency"

  - dimension: insurance_amount
    type: number
    sql: ${TABLE}."Insurance Amount"

  - dimension: invoice_id
    type: string
    sql: ${TABLE}."Invoice ID"

  - dimension: item_id
    type: string
    sql: ${TABLE}."Item ID"

  - dimension: item_name
    type: string
    sql: ${TABLE}."Item Name"

  - dimension: last_name
    type: string
    sql: ${TABLE}."Last Name"

  - dimension: loyalty_card_number
    type: string
    sql: ${TABLE}."Loyalty Card Number"

  - dimension: option_1_name
    type: string
    sql: ${TABLE}."Option 1 Name"

  - dimension: option_1_value
    type: string
    sql: ${TABLE}."Option 1 Value"

  - dimension: option_2_name
    type: string
    sql: ${TABLE}."Option 2 Name"

  - dimension: option_2_value
    type: string
    sql: ${TABLE}."Option 2 Value"

  - dimension: pay_pal_reference_id
    type: string
    sql: ${TABLE}."PayPal Reference ID"

  - dimension: pay_pal_reference_id_type
    type: string
    sql: ${TABLE}."PayPal Reference ID Type"

  - dimension: payer_address_status
    type: string
    sql: ${TABLE}."Payer Address Status"

  - dimension: payers_account_id
    type: string
    sql: ${TABLE}."Payer's Account ID"

  - dimension: payment_source
    type: string
    sql: ${TABLE}."Payment Source"

  - dimension: payment_tracking_id
    type: string
    sql: ${TABLE}."Payment Tracking ID"

  - dimension: protection_eligibility
    type: string
    sql: ${TABLE}."Protection Eligibility"

  - dimension: sales_tax_amount
    type: number
    sql: ${TABLE}."Sales Tax Amount"

  - dimension: secondary_shipping_address_city
    type: string
    sql: ${TABLE}."Secondary Shipping Address City"

  - dimension: secondary_shipping_address_country
    type: string
    sql: ${TABLE}."Secondary Shipping Address Country"

  - dimension: secondary_shipping_address_line1
    type: string
    sql: ${TABLE}."Secondary Shipping Address Line1"

  - dimension: secondary_shipping_address_line2
    type: string
    sql: ${TABLE}."Secondary Shipping Address Line2"

  - dimension: secondary_shipping_address_state
    type: string
    sql: ${TABLE}."Secondary Shipping Address State"

  - dimension: secondary_shipping_address_zip
    type: string
    sql: ${TABLE}."Secondary Shipping Address Zip"

  - dimension: shipping_address_city
    type: string
    sql: ${TABLE}."Shipping Address City"

  - dimension: shipping_address_country
    type: string
    sql: ${TABLE}."Shipping Address Country"

  - dimension: shipping_address_line1
    type: string
    sql: ${TABLE}."Shipping Address Line1"

  - dimension: shipping_address_line2
    type: string
    sql: ${TABLE}."Shipping Address Line2"

  - dimension: shipping_address_state
    type: string
    sql: ${TABLE}."Shipping Address State"

  - dimension: shipping_address_zip
    type: string
    sql: ${TABLE}."Shipping Address Zip"

  - dimension: shipping_amount
    type: number
    sql: ${TABLE}."Shipping Amount"

  - dimension: shipping_method
    type: string
    sql: ${TABLE}."Shipping Method"

  - dimension: shipping_name
    type: string
    sql: ${TABLE}."Shipping Name"

  - dimension: special_offers
    type: string
    sql: ${TABLE}."Special Offers"

  - dimension: store_id
    type: string
    sql: ${TABLE}."Store ID"

  - dimension: terminal_id
    type: string
    sql: ${TABLE}."Terminal ID"

  - dimension: transaction__debit_or_credit
    type: string
    sql: ${TABLE}."Transaction  Debit or Credit"

  - dimension_group: transaction_completion
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Transaction Completion Date"

  - dimension: transaction_event_code
    type: string
    sql: ${TABLE}."Transaction Event Code"

  - dimension: transaction_id
    type: string
    sql: ${TABLE}."Transaction ID"

  - dimension_group: transaction_initiation
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Transaction Initiation Date"

  - dimension: transaction_note
    type: string
    sql: ${TABLE}."Transaction Note"

  - dimension: transaction_subject
    type: string
    sql: ${TABLE}."Transaction Subject"

  - dimension: transactional_status
    type: string
    sql: ${TABLE}."Transactional Status"

  - measure: count
    type: count
    drill_fields: detail*


  # ----- Sets of fields for drilling ------
  sets:
    detail:
    - item_name
    - option_1_name
    - option_2_name
    - first_name
    - last_name
    - consumer_business_name
    - shipping_name

