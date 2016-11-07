label: "3. Finance"

connection: "mssql"

# include all views in this project
include: "*.view"

# include all dashboards in this project
include: "*.dashboard"

explore: nri {
  description: "Use to figure out exactly what we're paying NRI on a line-item level"
  label: "NRI Invoices"
  from: nri_invoice_details
}

explore: reconciliation {
  description: "Use to assist with transaction & account reconciliation"
  # this root view contains an amalgamation of invoices and credit memos from all sales channels
  from: transactions
  symmetric_aggregates: yes
  persist_for: "12 hours"
  #   used to map Magento invoices and credit memos to Netbanx transactions
  join: magento_map {
    from: transactions_magento_map
    sql_on: reconciliation.entity_id = magento_map.parent_id
      AND reconciliation.type = magento_map.type
      AND (reconciliation.credit_memo_id = magento_map.credit_memo_id OR reconciliation.credit_memo_id IS NULL)
       ;;
    relationship: one_to_one
  }

  join: tax {
    from: transactions_tax
    sql_on: reconciliation.entity_id = tax.order_id
      ;;
    relationship: one_to_many
    required_joins: [magento_map, payment_transaction]
  }

  #   used to map Magento invoices and credit memos to PayPal transactions (the view above would have been unnecessary had Demac built the Optimal Payments extension properly)
  join: payment_transaction {
    from: transactions_magento_payment
    sql_on: reconciliation.entity_id = payment_transaction.order_id AND
      CASE WHEN reconciliation.type = 'sale' THEN 'capture'
           WHEN reconciliation.type = 'credit' THEN 'refund'
      END = payment_transaction.txn_type
       ;;
    relationship: one_to_many
    required_joins: [magento_map]
  }

  #   used to pull Shopify transactions into the explore
  join: shopify_map {
    from: transactions_shopify_map
    sql_on: reconciliation.entity_id = shopify_map.order_number AND reconciliation.authorization_number = shopify_map.authorization_number
      ;;
    relationship: one_to_many
  }

  #   used to pull Netbanx transactions into the explore
  join: netbanx_transactions {
    from: transactions_netbanx_settlement
    type: full_outer
    sql_on: ((magento_map.netbanx_transaction_id = netbanx_transactions.TXN_NUM AND magento_map.netbanx_confirmation_number = netbanx_transactions.CONF_NUM)
        OR shopify_map.authorization_number = netbanx_transactions.CONF_NUM
      )
      AND CASE WHEN reconciliation.type = 'credit' THEN 'Credits'
               WHEN reconciliation.type = 'sale' THEN 'Settles'
          END = netbanx_transactions.tran_type
       ;;
    relationship: one_to_many
    required_joins: [magento_map, shopify_map]
  }

  join: braintree {
    from: transactions_braintree
    type: full_outer
    sql_on: reconciliation.transaction_id = braintree."Transaction ID"
      ;;
    relationship: one_to_many
  }

  #   used to pull PayPal transactions into the explore
  join: paypal_settlement {
    from: transactions_paypal_settlement
    type: full_outer
    sql_on: payment_transaction.txn_id = paypal_settlement.[Transaction ID]
      AND CASE WHEN reconciliation.type = 'credit' THEN 'T1107'
               WHEN reconciliation.type = 'sale' THEN 'T0006'
          END = paypal_settlement.[Transaction Event Code]
       ;;
    relationship: one_to_many
    required_joins: [payment_transaction]
  }
}
