view: transactions_shopify_map {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY [order-transactions-created_at]) AS row, * FROM (
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
        WHERE [order-transactions-status] = 'success'
      ) AS a
       ;;
    indexes: ["authorization_number", "order_number"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."order-email" ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}."order-transactions-created_at" ;;
  }

  dimension: gateway {
    type: string
    sql: ${TABLE}."order-transactions-gateway" ;;
  }

  measure: amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}."order-transactions-amount" ;;
  }

  dimension: currency {
    type: string
    sql: ${TABLE}."order-transactions-currency" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."order-transactions-source_name" ;;
  }

  dimension: authorization_number {
    type: string
    sql: ${TABLE}.authorization_number ;;
  }

  dimension: fee {
    type: number
    sql: ${TABLE}."order-transactions-fee" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."order-transactions-kind" ;;
  }

  dimension: order_number {
    type: number
    sql: ${TABLE}.order_number ;;
  }

  measure: tax_amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}."order-tax_lines-price" ;;
  }

  dimension: tax_rate {
    type: number
    value_format: "0%"
    sql: ${TABLE}."order-tax_lines-rate" ;;
  }

  dimension: tax_title {
    type: string
    sql: ${TABLE}."order-tax_lines-title" ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}."order-payment_method" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."order-status" ;;
  }
}
