- view: transactions_paypal_settlement
  derived_table: 
    sql: | 
      SELECT ROW_NUMBER() OVER (ORDER BY [Transaction Initiation Date]) AS row, [Transaction ID] AS transaction_id, * FROM (
        SELECT *
            , DATEADD(hh,2,[Transaction Completion Date]) AS completion_mst
            , DATEADD(hh,2,[Transaction Initiation Date]) AS initiation_mst
        FROM tbl_RawData_PayPal_Settlement
      ) AS a
    indexes: [transaction_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: transaction_id
    type: string
    sql: ${TABLE}.transaction_id

  - dimension: fee_currency
    type: string
    sql: ${TABLE}."Fee Currency"

  - dimension: fee_debit_or_credit
    type: string
    sql: ${TABLE}."Fee Debit or Credit"

  - dimension: gross_transaction_currency
    type: string
    sql: ${TABLE}."Gross Transaction Currency"

  - dimension: pay_pal_reference_id
    type: string
    sql: ${TABLE}."PayPal Reference ID"

  - dimension: pay_pal_reference_id_type
    type: string
    sql: ${TABLE}."PayPal Reference ID Type"

  - dimension: transaction_debit_or_credit
    type: string
    sql: ${TABLE}."Transaction  Debit or Credit"

  - dimension_group: transaction_completion
    type: time
    sql: ${TABLE}.completion_mst

  - dimension: transaction_event_code
    type: string
    sql: ${TABLE}."Transaction Event Code"

  - dimension: transaction_event_description
    type: string
    sql_case:
      'Payment Reversal, initiated by PayPal': ${transaction_event_code} = 'T1106'
      'Payment Refund, initiated by merchant': ${transaction_event_code} = 'T1107'
      'Cancellation of Hold for Dispute Resolution': ${transaction_event_code} = 'T1111'
      'General Funding of PayPal Account': ${transaction_event_code} = 'T0300'
      'General Withdrawal from PayPal Account': ${transaction_event_code} = 'T0400'
      'Payment from Express Checkout API': ${transaction_event_code} = 'T0006'
      'General: sent/received payment': ${transaction_event_code} = 'T0000'
      'Hold for Dispute Investigation': ${transaction_event_code} = 'T1110'
      'Settlement Consolidation': ${transaction_event_code} = 'T2001'
      else: unknown

  - dimension_group: transaction_initiation
    type: time
    sql: ${TABLE}.initiation_mst

  - measure: fee_amount
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: |
      CASE WHEN ${fee_debit_or_credit} = 'CR' THEN ${TABLE}."Fee Amount" WHEN ${fee_debit_or_credit} = 'DR' THEN -${TABLE}."Fee Amount" END

  - measure: gross_transaction_amount
    label: "Total"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: |
      CASE WHEN ${transaction_debit_or_credit} = 'CR' THEN ${TABLE}."Gross Transaction Amount" WHEN ${transaction_debit_or_credit} = 'DR' THEN -${TABLE}."Gross Transaction Amount" END

  - measure: tax_amount
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: |
      CASE WHEN ${transaction_debit_or_credit} = 'CR' THEN -(${TABLE}."Gross Transaction Amount" - (${TABLE}."Gross Transaction Amount" / (1 + (${tax.percent} / 100))))
           WHEN ${transaction_debit_or_credit} = 'DR' THEN ${TABLE}."Gross Transaction Amount" - (${TABLE}."Gross Transaction Amount" / (1 + (${tax.percent} / 100)))
      END
      
  - measure: count
    type: count
    drill_fields: []

