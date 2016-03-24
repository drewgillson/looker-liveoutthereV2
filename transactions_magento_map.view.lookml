- view: transactions_magento_map
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY parent_id) AS row, * FROM (
        SELECT 'sale' AS type
          , magento.extractValueFromSerializedPhpString('merchantRefNum',additional_information) AS netbanx_transaction_id
          , magento.extractValueFromSerializedPhpString('confirmationNumber',additional_information) AS netbanx_confirmation_number
          , parent_id
          , NULL AS credit_memo_id
        FROM magento.sales_flat_order_payment
        WHERE magento.extractValueFromSerializedPhpString('merchantRefNum',additional_information) IS NOT NULL
        UNION ALL
        SELECT 'credit'
          , magento.extractValueFromSerializedPhpString('merchantRefNum',b.additional_information)
          , SUBSTRING(a.comment,45,CHARINDEX('<',SUBSTRING(a.comment,45,100))-1)
          , a.parent_id
          , c.entity_id
        FROM magento.sales_flat_order_status_history AS a
        INNER JOIN magento.sales_flat_order_payment AS b
          ON a.parent_id = b.parent_id
        INNER JOIN magento.sales_flat_creditmemo AS c
          ON a.parent_id = c.order_id AND DATEADD(mi, DATEDIFF(mi, 0, a.created_at), 0) = DATEADD(mi, DATEDIFF(mi, 0, c.created_at), 0)
        WHERE a.comment LIKE 'Trans Type: refund%' AND CAST(a.comment AS varchar(255)) <> 'Trans Type: refund<br/>'
      ) AS a
    indexes: [netbanx_transaction_id, netbanx_confirmation_number, parent_id, credit_memo_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
  
  fields:

  - dimension: row
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.row
    
  - dimension: parent_id
    hidden: true
    type: number
    sql: ${TABLE}.parent_id

  - dimension: netbanx_transaction_id
    type: string
    sql: ${TABLE}.netbanx_transaction_id

  - dimension: netbanx_confirmation_number
    type: string
    sql: ${TABLE}.netbanx_confirmation_number

  - dimension: type
    type: string
    sql: ${TABLE}.type