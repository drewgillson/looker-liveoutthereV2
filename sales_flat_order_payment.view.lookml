- view: sales_flat_order_payment
  derived_table:
    sql: |
      SELECT magento.extractValueFromSerializedPhpString('merchantRefNum',additional_information) AS netbanx_transaction_id
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
    indexes: [netbanx_transaction_id, parent_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
  
  fields:

  - dimension: entity_id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.entity_id
    
  - dimension: parent_id
    hidden: true
    type: number
    sql: ${TABLE}.parent_id

  - dimension: netbanx_transaction_id
    type: string
    sql: ${TABLE}.netbanx_transaction_id

  - dimension: method
    type: string
    sql: ${TABLE}.method

  - measure: amount_authorized
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.amount_authorized END

  - measure: amount_canceled
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.amount_canceled END

  - measure: amount_ordered
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.amount_ordered END

  - measure: amount_paid
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.amount_paid END

  - measure: amount_refunded
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.amount_refunded END

  - measure: shipping_amount
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.shipping_amount END

  - measure: shipping_captured
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.shipping_captured END

  - measure: shipping_refunded
    type: sum
    value_format: '$#,##0.00;($#,##0.00)'
    sql: CASE WHEN ${transaction_reconciliation.type} = 'sale' THEN ${TABLE}.shipping_refunded END
