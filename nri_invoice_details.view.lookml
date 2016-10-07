- view: nri_invoice_details
  sql_table_name: NRI_Invoice_Details

  fields:
  - dimension: id
    type: number
    primary_key: true
    hidden: true
    sql: ${TABLE}.id

  - dimension: order_id
    type: number
    sql: ${TABLE}.OrderId

  - dimension: "client_ref1"
    label: "Client Reference 1"
    type: number
    sql: ${TABLE}.ClientRef1

  - dimension: "client_ref2"
    label: "Client Reference 2"
    type: string
    sql: ${TABLE}.ClientRef2

  - dimension: customer
    type: string
    sql: ${TABLE}.Customer

  - dimension: ponumber
    type: string
    sql: ${TABLE}.PONumber

  - dimension: service
    type: string
    sql: ${TABLE}.Service

  - dimension_group: doc_date
    type: time
    sql: ${TABLE}.DocDate

  - dimension_group: completed
    type: time
    sql: ${TABLE}.Completed

  - measure: units
    type: sum
    value_format: "#"
    sql: ${TABLE}.Units

  - measure: value
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.Value

  - measure: charges
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.Charges

  - measure: taxes
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.Taxes

  - measure: invoice_amount
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.InvoiceAmount

  - measure: orders
    type: count_distinct
    sql: ${TABLE}.ClientRef1

  - measure: cost_per_order
    type: number
    value_format: "$#,##0.00"
    sql: ${charges} / ${orders}

  - measure: count
    type: count
    drill_fields: detail*


  sets:
    detail:
      - order_id
      - client_ref1
      - client_ref2
      - customer
      - ponumber
      - doc_date_time
      - completed_time
      - units
      - value
      - service
      - charges
      - taxes
      - invoice_amount

