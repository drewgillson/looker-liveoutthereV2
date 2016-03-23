- view: paypal_settlement
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

  - dimension_group: transaction_initiation
    type: time
    sql: ${TABLE}.initiation_mst

  - measure: fee_amount
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: |
      CASE WHEN ${fee_debit_or_credit} = 'CR' THEN ${TABLE}."Fee Amount" WHEN ${fee_debit_or_credit} = 'DR' THEN -${TABLE}."Fee Amount" END

  - measure: gross_transaction_amount
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: |
      CASE WHEN ${transaction_debit_or_credit} = 'CR' THEN ${TABLE}."Gross Transaction Amount" WHEN ${transaction_debit_or_credit} = 'DR' THEN -${TABLE}."Gross Transaction Amount" END

  - measure: count
    type: count
    drill_fields: []

