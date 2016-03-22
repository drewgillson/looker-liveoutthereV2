
- view: sales_transactions
  derived_table:
    sql: |
      SELECT a.merchantRefNum
        , a.entity_id
        , a.parent_id
        , a.shipping_captured
        , a.amount_refunded
        , a.amount_canceled
        , a.shipping_amount
        , a.amount_paid
        , a.amount_authorized
        , a.shipping_refunded
        , a.amount_ordered
        , a.method
        , a.cc_last4
        , a.last_trans_id
        , a.cc_owner
        , a.cc_type
        , a.additional_information
        , b.tran_type
        , b.auth_code
        , b.card_ending
        , b.TXN_NUM
        , b.CONF_NUM
        , b.TRAN_STATUS
        , b.BRAND_CODE
        , b.AMOUNT
        , b.TRANSACTION_DATE
        , b.EMAIL
        , c.txn_type
        , c.additional_information AS txn_additional_information
        , c.created_at AS txn_created_at
        , d.[CH]
          , d.[Transaction ID]
          , d.[Invoice ID]
          , d.[PayPal Reference ID]
          , d.[PayPal Reference ID Type]
          , d.[Transaction Event Code]
          , d.[Transaction Initiation Date]
          , d.[Transaction Completion Date]
          , d.[Transaction  Debit or Credit]
          , d.[Gross Transaction Amount]
          , d.[Gross Transaction Currency]
          , d.[Fee Debit or Credit]
          , d.[Fee Amount]
          , d.[Fee Currency]
          , d.[Custom Field]
          , d.[Consumer ID]
          , d.[Payment Tracking ID]
          , d.[Store ID]
      FROM (
        SELECT magento.extractValueFromSerializedPhpString('merchantRefNum',additional_information) AS merchantRefNum
          , entity_id
          , parent_id
          , shipping_captured
          , amount_refunded
          , amount_canceled
          , shipping_amount
          , amount_paid
          , amount_authorized
          , shipping_refunded
          , amount_ordered
          , method
          , cc_last4
          , last_trans_id
          , cc_owner
          , cc_type
          , additional_information
        FROM magento.sales_flat_order_payment
      ) AS a
      FULL OUTER JOIN tbl_RawData_Netbanx_Transactions AS b
        ON b.TXN_NUM = a.merchantRefNum
      LEFT JOIN magento.sales_payment_transaction AS c
        ON a.parent_id = c.order_id
      FULL OUTER JOIN tbl_RawData_PayPal_Settlement AS d
        ON c.txn_id = d.[Transaction ID]

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: merchant_ref_num
    type: string
    sql: ${TABLE}.merchantRefNum

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: parent_id
    type: number
    sql: ${TABLE}.parent_id

  - dimension: shipping_captured
    type: number
    sql: ${TABLE}.shipping_captured

  - dimension: amount_refunded
    type: number
    sql: ${TABLE}.amount_refunded

  - dimension: amount_canceled
    type: number
    sql: ${TABLE}.amount_canceled

  - dimension: shipping_amount
    type: number
    sql: ${TABLE}.shipping_amount

  - dimension: amount_paid
    type: number
    sql: ${TABLE}.amount_paid

  - dimension: amount_authorized
    type: number
    sql: ${TABLE}.amount_authorized

  - dimension: shipping_refunded
    type: number
    sql: ${TABLE}.shipping_refunded

  - dimension: amount_ordered
    type: number
    sql: ${TABLE}.amount_ordered

  - dimension: method
    type: string
    sql: ${TABLE}.method

  - dimension: "cc_last4"
    type: string
    sql: ${TABLE}.cc_last4

  - dimension: last_trans_id
    type: string
    sql: ${TABLE}.last_trans_id

  - dimension: cc_owner
    type: string
    sql: ${TABLE}.cc_owner

  - dimension: cc_type
    type: string
    sql: ${TABLE}.cc_type

  - dimension: additional_information
    type: string
    sql: ${TABLE}.additional_information

  - dimension: tran_type
    type: string
    sql: ${TABLE}.tran_type

  - dimension: auth_code
    type: string
    sql: ${TABLE}.auth_code

  - dimension: card_ending
    type: string
    sql: ${TABLE}.card_ending

  - dimension: txn_num
    type: string
    sql: ${TABLE}.TXN_NUM

  - dimension: conf_num
    type: string
    sql: ${TABLE}.CONF_NUM

  - dimension: tran_status
    type: string
    sql: ${TABLE}.TRAN_STATUS

  - dimension: brand_code
    type: string
    sql: ${TABLE}.BRAND_CODE

  - dimension: amount
    type: string
    sql: ${TABLE}.AMOUNT

  - dimension_group: transaction_date
    type: time
    sql: ${TABLE}.TRANSACTION_DATE

  - dimension: email
    type: string
    sql: ${TABLE}.EMAIL

  - dimension: txn_type
    type: string
    sql: ${TABLE}.txn_type

  - dimension: txn_additional_information
    type: string
    sql: ${TABLE}.txn_additional_information

  - dimension_group: txn_created_at
    type: time
    sql: ${TABLE}.txn_created_at

  - dimension: ch
    type: string
    sql: ${TABLE}.CH

  - dimension: transaction_id
    type: string
    label: "Transaction ID"
    sql: ${TABLE}."Transaction ID"

  - dimension: invoice_id
    type: string
    label: "Invoice ID"
    sql: ${TABLE}."Invoice ID"

  - dimension: pay_pal_reference_id
    type: string
    label: "PayPal Reference ID"
    sql: ${TABLE}."PayPal Reference ID"

  - dimension: pay_pal_reference_id_type
    type: string
    label: "PayPal Reference ID Type"
    sql: ${TABLE}."PayPal Reference ID Type"

  - dimension: transaction_event_code
    type: string
    label: "Transaction Event Code"
    sql: ${TABLE}."Transaction Event Code"

  - dimension_group: transaction_initiation_date
    type: time
    label: "Transaction Initiation Date"
    sql: ${TABLE}."Transaction Initiation Date"

  - dimension_group: transaction_completion_date
    type: time
    label: "Transaction Completion Date"
    sql: ${TABLE}."Transaction Completion Date"

  - dimension: transaction__debit_or_credit
    type: string
    label: "Transaction  Debit or Credit"
    sql: ${TABLE}."Transaction  Debit or Credit"

  - dimension: gross_transaction_amount
    type: string
    label: "Gross Transaction Amount"
    sql: ${TABLE}."Gross Transaction Amount"

  - dimension: gross_transaction_currency
    type: string
    label: "Gross Transaction Currency"
    sql: ${TABLE}."Gross Transaction Currency"

  - dimension: fee_debit_or_credit
    type: string
    label: "Fee Debit or Credit"
    sql: ${TABLE}."Fee Debit or Credit"

  - dimension: fee_amount
    type: string
    label: "Fee Amount"
    sql: ${TABLE}."Fee Amount"

  - dimension: fee_currency
    type: string
    label: "Fee Currency"
    sql: ${TABLE}."Fee Currency"

  - dimension: custom_field
    type: string
    label: "Custom Field"
    sql: ${TABLE}."Custom Field"

  - dimension: consumer_id
    type: string
    label: "Consumer ID"
    sql: ${TABLE}."Consumer ID"

  - dimension: payment_tracking_id
    type: string
    label: "Payment Tracking ID"
    sql: ${TABLE}."Payment Tracking ID"

  - dimension: store_id
    type: string
    label: "Store ID"
    sql: ${TABLE}."Store ID"


