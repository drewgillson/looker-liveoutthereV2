- view: transactions_netbanx_settlement
  derived_table: 
    sql: | 
      SELECT ROW_NUMBER() OVER (ORDER BY [TRANSACTION_DATE]) AS row, * FROM (
        SELECT DISTINCT [TRAN_TYPE]
          ,[CARD_ENDING]
          ,[TXN_NUM]
          ,[CONF_NUM]
          ,[TRAN_STATUS]
          ,[BRAND_CODE]
          ,[AMOUNT]
          ,DATEADD(h,2,[TRANSACTION_DATE]) AS TRANSACTION_DATE
          ,[CURRENCY_CDE]
          ,[FIRST_NAME]
          ,[LAST_NAME]
        FROM tbl_RawData_Netbanx_Transactions
      ) AS a
    indexes: [TXN_NUM, TRANSACTION_DATE]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: card_brand
    type: string
    sql_case:
      'American Express': ${TABLE}.BRAND_CODE = 'AM'
      'Visa': ${TABLE}.BRAND_CODE = 'VI'
      'MasterCard': ${TABLE}.BRAND_CODE = 'MC'
      else: unknown
      
  - dimension: last_4_card_digits
    type: string
    sql: ${TABLE}.CARD_ENDING

  - dimension: currency
    type: string
    sql: ${TABLE}.CURRENCY_CDE

  - dimension: email
    type: string
    sql: ${TABLE}.EMAIL

  - dimension: first_name
    type: string
    sql: ${TABLE}.FIRST_NAME

  - dimension: last_name
    type: string
    sql: ${TABLE}.LAST_NAME

  - dimension: transaction_status
    type: string
    sql: ${TABLE}.TRAN_STATUS

  - dimension: transaction_type
    type: string
    sql: ${TABLE}.TRAN_TYPE

  - dimension_group: transaction
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.TRANSACTION_DATE

  - dimension: transaction_number
    type: string
    sql: ${TABLE}.TXN_NUM
    
  - dimension: is_thevan
    label: "Is TheVan.ca"
    type: yesno
    sql: ${transaction_number} LIKE 'c%'

  - dimension: is_lot
    label: "Is LiveOutThere.com"
    type: yesno
    sql: ${transaction_number} NOT LIKE 'c%'

  - dimension: confirmation_number
    type: string
    sql: ${TABLE}.CONF_NUM

  - measure: amount
    label: "Total Collected $"
    description: "Total amount collected by Netbanx, including taxes"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: |
      CASE WHEN ${transaction_type} = 'Credits' THEN -${TABLE}.AMOUNT ELSE ${TABLE}.AMOUNT END
    drill_fields: [transaction_details]

  - measure: tax
    label: "Tax Collected $"
    description: "Tax amount collected by Netbanx"
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: |
      CASE WHEN ${transaction_type} = 'Credits' THEN -(${TABLE}.AMOUNT - (${TABLE}.AMOUNT / (1 + (${tax.percent} / 100))))
           ELSE ${TABLE}.AMOUNT - (${TABLE}.AMOUNT / (1 + (${tax.percent} / 100)))
      END

  - measure: count
    type: count
    drill_fields: []

    
  sets:
    transaction_details:
      - transaction_reconciliation.storefront
      - transaction_reconciliation.created_time
      - transaction_reconciliation.id
      - transaction_type
      - transaction_number
      - confirmation_number
      - card_brand
      - amount