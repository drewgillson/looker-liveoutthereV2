view: transactions_magento_payment {
  sql_table_name: magento.sales_payment_transaction ;;

  dimension: transaction_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: parent_transaction_id {
    type: string
    sql: ${TABLE}.parent_txn_id ;;
  }

  dimension: magento_transaction_id {
    type: string
    sql: ${TABLE}.txn_id ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.txn_type ;;
  }
}
