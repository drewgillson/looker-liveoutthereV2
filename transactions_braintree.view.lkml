view: transactions_braintree {
  sql_table_name: tbl_RawData_Braintree ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: transaction_id {
    type: string
    label: "Braintree Txn ID"
    primary_key: yes
    label: "Transaction ID"
    sql: ${TABLE}."Transaction ID" ;;

    link: {
      label: "Braintree Transaction"
      url: "https://www.braintreegateway.com/merchants/738g38kwhy5m87c6/transactions/{{ braintree.transaction_id._value | encode_uri }}"
    }
  }

  dimension: subscription_id {
    type: string
    label: "Subscription ID"
    sql: ${TABLE}."Subscription ID" ;;
  }

  dimension: transaction_type {
    type: string
    label: "Transaction Type"
    sql: ${TABLE}."Transaction Type" ;;
  }

  dimension: transaction_status {
    type: string
    label: "Transaction Status"
    sql: ${TABLE}."Transaction Status" ;;
  }

  dimension: escrow_status {
    type: string
    label: "Escrow Status"
    sql: ${TABLE}."Escrow Status" ;;
  }

  dimension_group: created_datetime {
    type: time
    label: "Created Datetime"
    sql: ${TABLE}."Created Datetime" ;;
  }

  dimension: created_timezone {
    type: string
    label: "Created Timezone"
    sql: ${TABLE}."Created Timezone" ;;
  }

  dimension_group: settlement_date {
    type: time
    label: "Settlement Date"
    sql: ${TABLE}."Settlement Date" ;;
  }

  dimension_group: disbursement_date {
    type: time
    label: "Disbursement Date"
    sql: ${TABLE}."Disbursement Date" ;;
  }

  dimension: merchant_account {
    type: string
    label: "Merchant Account"
    sql: ${TABLE}."Merchant Account" ;;
  }

  dimension: currency_iso_code {
    type: string
    label: "Currency ISO Code"
    sql: ${TABLE}."Currency ISO Code" ;;
  }

  measure: amount_authorized {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    label: "Amount Authorized"
    sql: ${TABLE}."Amount Authorized" ;;
  }

  measure: amount_submitted_for_settlement {
    label: "Braintree Settled $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}."Amount Submitted For Settlement" ;;
  }

  measure: service_fee {
    label: "Braintree Fee $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}."Service Fee" ;;
  }

  measure: tax_amount {
    type: sum
    label: "Braintree Tax $"
    value_format: "$#,##0.00;($#,##0.00)"
    label: "Tax Amount"
    sql: ${TABLE}."Tax Amount" ;;
  }

  dimension: tax_exempt {
    type: string
    label: "Tax Exempt"
    sql: ${TABLE}."Tax Exempt" ;;
  }

  dimension: purchase_order_number {
    type: string
    label: "Purchase Order Number"
    sql: ${TABLE}."Purchase Order Number" ;;
  }

  dimension: order_id {
    type: string
    label: "Order ID"
    sql: ${TABLE}."Order ID" ;;
  }

  dimension: descriptor_name {
    type: string
    label: "Descriptor Name"
    sql: ${TABLE}."Descriptor Name" ;;
  }

  dimension: descriptor_phone {
    type: string
    label: "Descriptor Phone"
    sql: ${TABLE}."Descriptor Phone" ;;
  }

  dimension: descriptor_url {
    type: string
    label: "Descriptor URL"
    sql: ${TABLE}."Descriptor URL" ;;
  }

  dimension: refunded_transaction_id {
    type: string
    label: "Refunded Transaction ID"
    sql: ${TABLE}."Refunded Transaction ID" ;;

    link: {
      label: "Braintree Transaction"
      url: "https://www.braintreegateway.com/merchants/738g38kwhy5m87c6/transactions/{{ braintree.refunded_transaction_id._value | encode_uri }}"
    }
  }

  dimension: payment_instrument_type {
    type: string
    label: "Payment Instrument Type"
    sql: ${TABLE}."Payment Instrument Type" ;;
  }

  dimension: card_type {
    type: string
    label: "Card Type"
    sql: ${TABLE}."Card Type" ;;
  }

  dimension: cardholder_name {
    type: string
    label: "Cardholder Name"
    sql: ${TABLE}."Cardholder Name" ;;
  }

  dimension: first_six_of_credit_card {
    type: string
    label: "First Six of Credit Card"
    sql: ${TABLE}."First Six of Credit Card" ;;
  }

  dimension: last_four_of_credit_card {
    type: string
    label: "Last Four of Credit Card"
    sql: ${TABLE}."Last Four of Credit Card" ;;
  }

  dimension: credit_card_number {
    type: string
    label: "Credit Card Number"
    sql: ${TABLE}."Credit Card Number" ;;
  }

  dimension_group: expiration_date {
    type: time
    label: "Expiration Date"
    sql: ${TABLE}."Expiration Date" ;;
  }

  dimension: credit_card_customer_location {
    type: string
    label: "Credit Card Customer Location"
    sql: ${TABLE}."Credit Card Customer Location" ;;
  }

  dimension: customer_id {
    type: string
    label: "Customer ID"
    sql: ${TABLE}."Customer ID" ;;
  }

  dimension: payment_method_token {
    type: string
    label: "Payment Method Token"
    sql: ${TABLE}."Payment Method Token" ;;
  }

  dimension: credit_card_unique_identifier {
    type: string
    label: "Credit Card Unique Identifier"
    sql: ${TABLE}."Credit Card Unique Identifier" ;;
  }

  dimension: customer_first_name {
    type: string
    label: "Customer First Name"
    sql: ${TABLE}."Customer First Name" ;;
  }

  dimension: customer_last_name {
    type: string
    label: "Customer Last Name"
    sql: ${TABLE}."Customer Last Name" ;;
  }

  dimension: customer_company {
    type: string
    label: "Customer Company"
    sql: ${TABLE}."Customer Company" ;;
  }

  dimension: customer_email {
    type: string
    label: "Customer Email"
    sql: ${TABLE}."Customer Email" ;;
  }

  dimension: customer_phone {
    type: string
    label: "Customer Phone"
    sql: ${TABLE}."Customer Phone" ;;
  }

  dimension: customer_fax {
    type: string
    label: "Customer Fax"
    sql: ${TABLE}."Customer Fax" ;;
  }

  dimension: customer_website {
    type: string
    label: "Customer Website"
    sql: ${TABLE}."Customer Website" ;;
  }

  dimension: billing_address_id {
    type: string
    label: "Billing Address ID"
    sql: ${TABLE}."Billing Address ID" ;;
  }

  dimension: billing_first_name {
    type: string
    label: "Billing First Name"
    sql: ${TABLE}."Billing First Name" ;;
  }

  dimension: billing_last_name {
    type: string
    label: "Billing Last Name"
    sql: ${TABLE}."Billing Last Name" ;;
  }

  dimension: billing_company {
    type: string
    label: "Billing Company"
    sql: ${TABLE}."Billing Company" ;;
  }

  dimension: billing_street_address {
    type: string
    label: "Billing Street Address"
    sql: ${TABLE}."Billing Street Address" ;;
  }

  dimension: billing_extended_address {
    type: string
    label: "Billing Extended Address"
    sql: ${TABLE}."Billing Extended Address" ;;
  }

  dimension: billing_city_locality {
    type: string
    label: "Billing City (Locality)"
    sql: ${TABLE}."Billing City (Locality)" ;;
  }

  dimension: billing_state_province_region {
    type: string
    label: "Billing State Province (Region)"
    sql: ${TABLE}."Billing State Province (Region)" ;;
  }

  dimension: billing_postal_code {
    type: string
    label: "Billing Postal Code"
    sql: ${TABLE}."Billing Postal Code" ;;
  }

  dimension: billing_country {
    type: string
    label: "Billing Country"
    sql: ${TABLE}."Billing Country" ;;
  }

  dimension: shipping_address_id {
    type: string
    label: "Shipping Address ID"
    sql: ${TABLE}."Shipping Address ID" ;;
  }

  dimension: shipping_first_name {
    type: string
    label: "Shipping First Name"
    sql: ${TABLE}."Shipping First Name" ;;
  }

  dimension: shipping_last_name {
    type: string
    label: "Shipping Last Name"
    sql: ${TABLE}."Shipping Last Name" ;;
  }

  dimension: shipping_company {
    type: string
    label: "Shipping Company"
    sql: ${TABLE}."Shipping Company" ;;
  }

  dimension: shipping_street_address {
    type: string
    label: "Shipping Street Address"
    sql: ${TABLE}."Shipping Street Address" ;;
  }

  dimension: shipping_extended_address {
    type: string
    label: "Shipping Extended Address"
    sql: ${TABLE}."Shipping Extended Address" ;;
  }

  dimension: shipping_city_locality {
    type: string
    label: "Shipping City (Locality)"
    sql: ${TABLE}."Shipping City (Locality)" ;;
  }

  dimension: shipping_state_province_region {
    type: string
    label: "Shipping State Province (Region)"
    sql: ${TABLE}."Shipping State Province (Region)" ;;
  }

  dimension: shipping_postal_code {
    type: string
    label: "Shipping Postal Code"
    sql: ${TABLE}."Shipping Postal Code" ;;
  }

  dimension: shipping_country {
    type: string
    label: "Shipping Country"
    sql: ${TABLE}."Shipping Country" ;;
  }

  dimension: user {
    type: string
    sql: ${TABLE}."User" ;;
  }

  dimension: ip_address {
    type: string
    label: "IP Address"
    sql: ${TABLE}."IP Address" ;;
  }

  dimension: creating_using_token {
    type: string
    label: "Creating Using Token"
    sql: ${TABLE}."Creating Using Token" ;;
  }

  dimension: transaction_source {
    type: string
    label: "Transaction Source"
    sql: ${TABLE}."Transaction Source" ;;
  }

  dimension: authorization_code {
    type: string
    label: "Authorization Code"
    sql: ${TABLE}."Authorization Code" ;;
  }

  dimension: processor_response_code {
    type: string
    label: "Processor Response Code"
    sql: ${TABLE}."Processor Response Code" ;;
  }

  dimension: processor_response_text {
    type: string
    label: "Processor Response Text"
    sql: ${TABLE}."Processor Response Text" ;;
  }

  dimension: gateway_rejection_reason {
    type: string
    label: "Gateway Rejection Reason"
    sql: ${TABLE}."Gateway Rejection Reason" ;;
  }

  dimension: postal_code_response_code {
    type: string
    label: "Postal Code Response Code"
    sql: ${TABLE}."Postal Code Response Code" ;;
  }

  dimension: street_address_response_code {
    type: string
    label: "Street Address Response Code"
    sql: ${TABLE}."Street Address Response Code" ;;
  }

  dimension: avs_response_text {
    type: string
    label: "AVS Response Text"
    sql: ${TABLE}."AVS Response Text" ;;
  }

  dimension: cvv_response_code {
    type: string
    label: "CVV Response Code"
    sql: ${TABLE}."CVV Response Code" ;;
  }

  dimension: cvv_response_text {
    type: string
    label: "CVV Response Text"
    sql: ${TABLE}."CVV Response Text" ;;
  }

  measure: settlement_amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    label: "Settlement Amount"
    sql: ${TABLE}."Settlement Amount" ;;
  }

  dimension: settlement_currency_iso_code {
    type: string
    label: "Settlement Currency ISO Code"
    sql: ${TABLE}."Settlement Currency ISO Code" ;;
  }

  dimension: settlement_currency_exchange_rate {
    type: string
    label: "Settlement Currency Exchange Rate"
    sql: ${TABLE}."Settlement Currency Exchange Rate" ;;
  }

  dimension: fraud_detected {
    type: string
    label: "Fraud Detected"
    sql: ${TABLE}."Fraud Detected" ;;
  }

  dimension: disputed_date {
    type: string
    label: "Disputed Date"
    sql: ${TABLE}."Disputed Date" ;;
  }

  dimension: authorized_transaction_id {
    type: string
    label: "Authorized Transaction ID"
    sql: ${TABLE}."Authorized Transaction ID" ;;
  }

  dimension: customer_group_id {
    type: string
    label: "Customer Group ID"
    sql: ${TABLE}."Customer Group ID" ;;
  }

  dimension: has_gift_card {
    type: string
    label: "Has Gift Card"
    sql: ${TABLE}."Has Gift Card" ;;
  }

  dimension: shipping_method {
    type: string
    label: "Shipping Method"
    sql: ${TABLE}."Shipping Method" ;;
  }

  dimension: country_of_issuance {
    type: string
    label: "Country of Issuance"
    sql: ${TABLE}."Country of Issuance" ;;
  }

  dimension: issuing_bank {
    type: string
    label: "Issuing Bank"
    sql: ${TABLE}."Issuing Bank" ;;
  }

  dimension: durbin_regulated {
    type: string
    label: "Durbin Regulated"
    sql: ${TABLE}."Durbin Regulated" ;;
  }

  dimension: commercial {
    type: string
    sql: ${TABLE}.Commercial ;;
  }

  dimension: prepaid {
    type: string
    sql: ${TABLE}.Prepaid ;;
  }

  dimension: payroll {
    type: string
    sql: ${TABLE}.Payroll ;;
  }

  dimension: healthcare {
    type: string
    sql: ${TABLE}.Healthcare ;;
  }

  dimension: affluent_category {
    type: string
    label: "Affluent Category"
    sql: ${TABLE}."Affluent Category" ;;
  }

  dimension: debit {
    type: string
    sql: ${TABLE}.Debit ;;
  }

  dimension: product_id {
    type: string
    label: "Product ID"
    sql: ${TABLE}."Product ID" ;;
  }

  dimension: pay_pal_payer_email {
    type: string
    label: "PayPal Payer Email"
    sql: ${TABLE}."PayPal Payer Email" ;;
  }

  dimension: pay_pal_payment_id {
    type: string
    label: "PayPal Payment ID"
    sql: ${TABLE}."PayPal Payment ID" ;;
  }

  dimension: pay_pal_authorization_id {
    type: string
    label: "PayPal Authorization ID"
    sql: ${TABLE}."PayPal Authorization ID" ;;
  }

  dimension: pay_pal_debug_id {
    type: string
    label: "PayPal Debug ID"
    sql: ${TABLE}."PayPal Debug ID" ;;
  }

  dimension: pay_pal_capture_id {
    type: string
    label: "PayPal Capture ID"
    sql: ${TABLE}."PayPal Capture ID" ;;
  }

  dimension: pay_pal_refund_id {
    type: string
    label: "PayPal Refund ID"
    sql: ${TABLE}."PayPal Refund ID" ;;
  }

  dimension: pay_pal_custom_field {
    type: string
    label: "PayPal Custom Field"
    sql: ${TABLE}."PayPal Custom Field" ;;
  }

  dimension: pay_pal_payer_id {
    type: string
    label: "PayPal Payer ID"
    sql: ${TABLE}."PayPal Payer ID" ;;
  }

  dimension: pay_pal_payer_first_name {
    type: string
    label: "PayPal Payer First Name"
    sql: ${TABLE}."PayPal Payer First Name" ;;
  }

  dimension: pay_pal_payer_last_name {
    type: string
    label: "PayPal Payer Last Name"
    sql: ${TABLE}."PayPal Payer Last Name" ;;
  }

  dimension: pay_pal_seller_protection_status {
    type: string
    label: "PayPal Seller Protection Status"
    sql: ${TABLE}."PayPal Seller Protection Status" ;;
  }

  measure: pay_pal_transaction_fee_amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    label: "PayPal Transaction Fee Amount"
    sql: ${TABLE}."PayPal Transaction Fee Amount" ;;
  }

  dimension: pay_pal_transaction_fee_currency_iso_code {
    type: string
    label: "PayPal Transaction Fee Currency ISO Code"
    sql: ${TABLE}."PayPal Transaction Fee Currency ISO Code" ;;
  }

  dimension: last_four_of_apple_pay {
    type: string
    label: "Last Four of Apple Pay"
    sql: ${TABLE}."Last Four of Apple Pay" ;;
  }

  dimension: expiration_month {
    type: string
    label: "Expiration Month"
    sql: ${TABLE}."Expiration Month" ;;
  }

  dimension: expiration_year {
    type: string
    label: "Expiration Year"
    sql: ${TABLE}."Expiration Year" ;;
  }

  dimension: cardholder_name_2 {
    type: string
    label: "Cardholder Name 2"
    sql: ${TABLE}."Cardholder Name 2" ;;
  }

  dimension: android_pay_source_card_last_four {
    type: string
    label: "Android Pay Source Card Last Four"
    sql: ${TABLE}."Android Pay Source Card Last Four" ;;
  }

  dimension: android_pay_source_card_type {
    type: string
    label: "Android Pay Source Card Type"
    sql: ${TABLE}."Android Pay Source Card Type" ;;
  }

  dimension: risk_id {
    type: string
    label: "Risk ID"
    sql: ${TABLE}."Risk ID" ;;
  }

  dimension: risk_decision {
    type: string
    label: "Risk Decision"
    sql: ${TABLE}."Risk Decision" ;;
  }

  set: detail {
    fields: [transaction_id, subscription_id, transaction_type, transaction_status, escrow_status, created_datetime_time, created_timezone, settlement_date_time, disbursement_date_time, merchant_account, currency_iso_code, amount_authorized, amount_submitted_for_settlement, service_fee, tax_amount, tax_exempt, purchase_order_number, order_id, descriptor_name, descriptor_phone, descriptor_url, refunded_transaction_id, payment_instrument_type, card_type, cardholder_name, first_six_of_credit_card, last_four_of_credit_card, credit_card_number, expiration_date_time, credit_card_customer_location, customer_id, payment_method_token, credit_card_unique_identifier, customer_first_name, customer_last_name, customer_company, customer_email, customer_phone, customer_fax, customer_website, billing_address_id, billing_first_name, billing_last_name, billing_company, billing_street_address, billing_extended_address, billing_city_locality, billing_state_province_region, billing_postal_code, billing_country, shipping_address_id, shipping_first_name, shipping_last_name, shipping_company, shipping_street_address, shipping_extended_address, shipping_city_locality, shipping_state_province_region, shipping_postal_code, shipping_country, user, ip_address, creating_using_token, transaction_source, authorization_code, processor_response_code, processor_response_text, gateway_rejection_reason, postal_code_response_code, street_address_response_code, avs_response_text, cvv_response_code, cvv_response_text, settlement_amount, settlement_currency_iso_code, settlement_currency_exchange_rate, fraud_detected, disputed_date, authorized_transaction_id, customer_group_id, has_gift_card, shipping_method, country_of_issuance, issuing_bank, durbin_regulated, commercial, prepaid, payroll, healthcare, affluent_category, debit, product_id, pay_pal_payer_email, pay_pal_payment_id, pay_pal_authorization_id, pay_pal_debug_id, pay_pal_capture_id, pay_pal_refund_id, pay_pal_custom_field, pay_pal_payer_id, pay_pal_payer_first_name, pay_pal_payer_last_name, pay_pal_seller_protection_status, pay_pal_transaction_fee_amount, pay_pal_transaction_fee_currency_iso_code, last_four_of_apple_pay, expiration_month, expiration_year, cardholder_name_2, android_pay_source_card_last_four, android_pay_source_card_type, risk_id, risk_decision]
  }
}
