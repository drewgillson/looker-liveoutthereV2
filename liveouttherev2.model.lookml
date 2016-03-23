- connection: mssql

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: transaction_reconciliation
  description: "Use to assist with transaction & account reconciliation"
  symmetric_aggregates: true
  persist_for: 1 hour
  from: sales_transactions
  joins:
    - join: payment
      from: sales_flat_order_payment
      sql_on: transaction_reconciliation.entity_id = payment.parent_id
      relationship: one_to_one
    - join: payment_transaction
      from: sales_payment_transaction
      sql_on: payment.parent_id = payment_transaction.order_id
      relationship: one_to_many
    - join: netbanx_transactions
      type: full_outer
      sql_on: |
        payment.netbanx_transaction_id = netbanx_transactions.TXN_NUM
        AND CASE WHEN transaction_reconciliation.type = 'credit' THEN 'Credits'
                 WHEN transaction_reconciliation.type = 'sale' THEN 'Settles'
            END = netbanx_transactions.tran_type
      relationship: one_to_many
      required_joins: [payment]
    - join: paypal_settlement
      type: full_outer
      sql_on: |
        payment_transaction.txn_id = paypal_settlement.[Transaction ID]
        AND CASE WHEN transaction_reconciliation.type = 'credit' THEN 'T1107'
                 WHEN transaction_reconciliation.type = 'sale' THEN 'T0006'
            END = paypal_settlement.[Transaction Event Code]
      relationship: one_to_many
      required_joins: [payment_transaction]

- explore: inventory
  description: "Use to answer supply-side questions (i.e. how many units do we have available to sell and from what categories?)"
  symmetric_aggregates: true
  persist_for: 1 hour
  from: catalog_products
  joins:
    - join: associations
      from: catalog_product_associations
      sql_on: inventory.entity_id = associations.product_id
      relationship: one_to_many
    - join: facts
      from: catalog_product_facts
      sql_on: inventory.entity_id = facts.product_id
      relationship: one_to_one
    - join: categories
      from: catalog_categories
      sql_on: inventory.entity_id = categories.product_id
      relationship: one_to_many
    - join: impressions
      from: catalog_product_impressions
      sql_on: associations.parent_id = impressions.product_id
      required_joins: [associations]
      relationship: one_to_many
    - join: applied_catalog_price_rules
      from: catalog_price_rules
      sql_on: inventory.entity_id = applied_catalog_price_rules.product_id
      relationship: one_to_many
    - join: effective_discounts
      from: catalog_effective_discounts
      sql_on: inventory.entity_id = effective_discounts.entity_id
      relationship: one_to_many
      required_joins: [associations]
    - join: reviews
      from: catalog_product_reviews
      sql_on: associations.parent_id = reviews.entity_id
      relationship: one_to_many
      required_joins: [associations]
    - join: purchase_orders
      from: purchase_order_products
      sql_on: inventory.entity_id = purchase_orders.pop_product_id
      relationship: one_to_many
    - join: supplier_invoices
      from: purchase_order_invoices
      sql_on: purchase_orders.pop_order_num = supplier_invoices.poi_order_num
      relationship: one_to_many
      required_joins: [purchase_orders]
    - join: stock_movements
      sql_on: inventory.entity_id = stock_movements.sm_product_id
      relationship: one_to_many
    - join: enriched_attributes
      from: akeneo_option_values
      sql_on: associations.parent_id = enriched_attributes.parent_id
      relationship: one_to_one
      required_joins: [associations]
#  conditionally_filter:
#    facts.is_in_stock: '%'
#    unless:
#      - facts.is_in_stock
