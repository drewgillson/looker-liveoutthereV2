- view: sales_shopify_transactions
  derived_table:
    sql: |
      SELECT [order-email]
            , [order-transactions-created_at]
            , [order-transactions-gateway]
            , [order-transactions-amount]
            , [order-transactions-currency]
            , [order-transactions-source_name]
            , [order-transactions-authorization] AS authorization_number
            , [order-transactions-fee]
            , [order-transactions-kind]
            , [order-order_number] AS order_number
            , [order-tax_lines-price]
            , [order-tax_lines-rate]
            , [order-tax_lines-title]
            , [order-payment_method]
            , [order-status]
      FROM shopify.transactions
      WHERE [order-status] != 'cancelled' AND [order-transactions-status] = 'success'
    indexes: [authorization_number, order_number]
    sql_trigger_value: |
        SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      
  fields:

  - dimension: orderemail
    type: string
    sql: ${TABLE}."order-email"

  - dimension_group: ordertransactionscreated_at
    type: time
    sql: ${TABLE}."order-transactions-created_at"

  - dimension: ordertransactionsgateway
    type: string
    sql: ${TABLE}."order-transactions-gateway"

  - dimension: ordertransactionsamount
    type: number
    sql: ${TABLE}."order-transactions-amount"

  - dimension: ordertransactionscurrency
    type: string
    sql: ${TABLE}."order-transactions-currency"

  - dimension: ordertransactionssource_name
    type: string
    sql: ${TABLE}."order-transactions-source_name"

  - dimension: authorization_number
    type: string
    sql: ${TABLE}.authorization_number

  - dimension: ordertransactionsfee
    type: number
    sql: ${TABLE}."order-transactions-fee"

  - dimension: ordertransactionskind
    type: string
    sql: ${TABLE}."order-transactions-kind"

  - dimension: order_number
    type: number
    sql: ${TABLE}.order_number

  - dimension: ordertax_linesprice
    type: number
    sql: ${TABLE}."order-tax_lines-price"

  - dimension: ordertax_linesrate
    type: number
    sql: ${TABLE}."order-tax_lines-rate"

  - dimension: ordertax_linestitle
    type: string
    sql: ${TABLE}."order-tax_lines-title"

  - dimension: orderpayment_method
    type: string
    sql: ${TABLE}."order-payment_method"

  - dimension: orderstatus
    type: string
    sql: ${TABLE}."order-status"

  sets:
    detail:
      - orderemail
      - ordertransactionscreated_at_time
      - ordertransactionsgateway
      - ordertransactionsamount
      - ordertransactionscurrency
      - ordertransactionssource_name
      - ordertransactionsauthorization
      - ordertransactionsfee
      - ordertransactionskind
      - ordertransactionsstatus
      - orderorder_number
      - ordertax_linesprice
      - ordertax_linesrate
      - ordertax_linestitle
      - orderpayment_method
      - orderstatus

