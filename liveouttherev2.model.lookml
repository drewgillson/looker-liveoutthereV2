- connection: mssql

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: people
  from: customers
  symmetric_aggregates: true
  persist_for: 12 hours
  joins:
    - join: carts
      sql_on: people.email = carts.customer_email
      relationship: one_to_many
    - join: cart_items
      from: carts_items
      sql_on: carts.entity_id = cart_items.quote_id
      relationship: one_to_many
      required_joins: [carts]
    - join: products
      from: catalog_products
      sql_on: cart_items.product_id = products.entity_id
      relationship: one_to_one
      required_joins: [cart_items]

- explore: reconciliation
  from: transactions # this root view contains an amalgamation of invoices and credit memos from all sales channels
  description: "Use to assist with transaction & account reconciliation"
  symmetric_aggregates: true
  persist_for: 12 hours
  joins:
#   used to map Magento invoices and credit memos to Netbanx transactions
    - join: magento_map
      from: transactions_magento_map
      sql_on: |
        reconciliation.entity_id = magento_map.parent_id
        AND reconciliation.type = magento_map.type
        AND (reconciliation.credit_memo_id = magento_map.credit_memo_id OR reconciliation.credit_memo_id IS NULL)
      relationship: one_to_one
    - join: tax
      from: transactions_tax
      sql_on: |
        reconciliation.entity_id = tax.order_id
      relationship: many_to_one
      required_joins: [magento_map, payment_transaction]
#   used to map Magento invoices and credit memos to PayPal transactions (the view above would have been unnecessary had Demac built the Optimal Payments extension properly)
    - join: payment_transaction
      from: transactions_magento_payment
      sql_on: |
        reconciliation.entity_id = payment_transaction.order_id AND
        CASE WHEN reconciliation.type = 'sale' THEN 'capture'
             WHEN reconciliation.type = 'credit' THEN 'refund'
        END = payment_transaction.txn_type
      relationship: one_to_many
      required_joins: [magento_map]
#   used to pull Shopify transactions into the explore
    - join: shopify_map
      from: transactions_shopify_map
      sql_on: |
        reconciliation.entity_id = shopify_map.order_number AND reconciliation.authorization_number = shopify_map.authorization_number
      relationship: one_to_many
#   used to pull Netbanx transactions into the explore
    - join: netbanx_transactions
      from: transactions_netbanx_settlement
      type: full_outer
      sql_on: |
        ((magento_map.netbanx_transaction_id = netbanx_transactions.TXN_NUM AND magento_map.netbanx_confirmation_number = netbanx_transactions.CONF_NUM)
          OR shopify_map.authorization_number = netbanx_transactions.CONF_NUM
        )
        AND CASE WHEN reconciliation.type = 'credit' THEN 'Credits'
                 WHEN reconciliation.type = 'sale' THEN 'Settles'
            END = netbanx_transactions.tran_type
      relationship: one_to_many
      required_joins: [magento_map, shopify_map]
#   used to pull PayPal transactions into the explore
    - join: paypal_settlement
      from: transactions_paypal_settlement
      type: full_outer
      sql_on: |
        payment_transaction.txn_id = paypal_settlement.[Transaction ID]
        AND CASE WHEN reconciliation.type = 'credit' THEN 'T1107'
                 WHEN reconciliation.type = 'sale' THEN 'T0006'
            END = paypal_settlement.[Transaction Event Code]
      relationship: one_to_many
      required_joins: [payment_transaction]

- explore: products
  label: "Products & Sales"
  description: "Use to answer supply-side questions (i.e. how many units do we have available to sell and from what categories?)"
  symmetric_aggregates: true
  persist_for: 12 hours
  from: catalog_products
  joins:
    - join: associations
      from: catalog_product_associations
      sql_on: products.entity_id = associations.product_id
      relationship: one_to_many
    - join: product_facts
      from: catalog_product_facts
      sql_on: products.entity_id = product_facts.product_id
      relationship: one_to_one
    - join: weekly_sell_through
      from: catalog_product_facts_weekly_sellthrough
      sql_on: products.entity_id = weekly_sell_through.product_id
      relationship: one_to_one
    - join: categories
      from: catalog_categories
      sql_on: products.entity_id = categories.product_id
      relationship: one_to_many
    - join: impressions
      from: catalog_product_impressions
      sql_on: associations.parent_id = impressions.product_id
      required_joins: [associations]
      relationship: one_to_many
    - join: applied_catalog_price_rules
      from: catalog_price_rules
      sql_on: products.entity_id = applied_catalog_price_rules.product_id
      relationship: one_to_many
    - join: effective_discounts
      from: catalog_effective_discounts
      sql_on: products.entity_id = effective_discounts.entity_id
      relationship: one_to_many
      required_joins: [associations]
    - join: reviews
      from: catalog_product_reviews
      sql_on: associations.parent_id = reviews.entity_id
      relationship: one_to_many
      required_joins: [associations]
    - join: purchase_orders
      from: purchase_order_products
      sql_on: products.entity_id = purchase_orders.pop_product_id
      relationship: one_to_many
    - join: supplier_invoices
      from: purchase_order_invoices
      sql_on: purchase_orders.pop_order_num = supplier_invoices.poi_order_num
      relationship: one_to_many
      required_joins: [purchase_orders]
    - join: stock_movements
      sql_on: products.entity_id = stock_movements.sm_product_id
      relationship: one_to_many
    - join: product_attributes
      from: catalog_akeneo_option_values
      sql_on: associations.parent_id = product_attributes.parent_id
      relationship: one_to_one
      required_joins: [associations]
    - join: credits
      from: sales_credit_items
      sql_on: |
        sales.order_entity_id = credits.order_entity_id
        AND sales.product_id = credits.product_id
      relationship: one_to_many
      required_joins: [sales]
    - join: sales
      from: sales_items
      sql_on: products.entity_id = sales.product_id
      relationship: one_to_many
      required_joins: [credits]
    - join: shipping_charges
      from: sales_shipping_charges
      sql_on: sales.order_entity_id = shipping_charges.order_id
      relationship: one_to_one
      required_joins: [sales]
    - join: shipping_tracking
      from: sales_shipping_tracking
      sql_on: sales.order_entity_id = shipping_tracking.order_id
      relationship: many_to_many
      required_joins: [sales]
      
#  conditionally_filter:
#    facts.is_in_stock: '%'
#    unless:
#      - facts.is_in_stock
