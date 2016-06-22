- connection: mssql

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: predictions
  hidden: true
  from: jaccard_product_view_affinity
  
- explore: people
  from: people
  symmetric_aggregates: true
  persist_for: 12 hours
  joins:
    - join: people_facts
      sql_on: people.email = ${people_facts.email}
      relationship: one_to_one
    - join: customers
      sql_on: people.email = customers.email
      relationship: one_to_one
    - join: cart_items
      from: carts_items
      sql_on: people.email = cart_items.email
      relationship: one_to_many
    - join: cart_items_product
      from: carts_items_product
      sql_on: cart_items.product_id = cart_items_product.entity_id
      relationship: one_to_many
      required_joins: [cart_items]
    - join: cart_items_category
      from: catalog_categories
      sql_on: cart_items_product.entity_id = cart_items_category.product_id
      relationship: one_to_many
      required_joins: [cart_items_product]
    - join: mailchimp_list
      sql_on: people.email = mailchimp_list.email_address
      relationship: one_to_one
    - join: mailchimp_activity_1
      from: mailchimp_activity
      sql_on: people.email = mailchimp_activity_1.email
      relationship: one_to_many
    - join: mailchimp_activity_2
      from: mailchimp_activity
      sql_on: people.email = mailchimp_activity_2.email
      relationship: one_to_many
    - join: product_page_views
      from: people_products_page_views
      sql_on: people.email = product_page_views.email
      relationship: one_to_many
    - join: product_page_views_product
      from: people_products_page_views_product
      sql_on: product_page_views.url_key = product_page_views_product.url_key
      relationship: one_to_many
      required_joins: [product_page_views]
    - join: product_page_views_category
      from: catalog_categories
      sql_on: product_page_views_product.entity_id = product_page_views_category.product_id
      relationship: one_to_many
      required_joins: [product_page_views_product]
    - join: personalization_affinity_1
      from: personalization_affinity
      sql_on: people.email = personalization_affinity_1.email
      relationship: one_to_many
    - join: personalization_affinity_2
      from: personalization_affinity
      sql_on: people.email = personalization_affinity_2.email
      relationship: one_to_many
    - join: customer_address
      from: sales_order_address
      sql_on: people.email = customer_address.email
      relationship: one_to_many
    - join: other_page_views_1
      from: people_other_page_views
      sql_on: people.email = other_page_views_1.email
      relationship: one_to_many
    - join: other_page_views_2
      from: people_other_page_views
      sql_on: people.email = other_page_views_2.email
      relationship: one_to_many
    - join: other_page_views_3
      from: people_other_page_views
      sql_on: people.email = other_page_views_3.email
      relationship: one_to_many
    - join: gift_certificates
      sql_on: people.email = gift_certificates.recipient_email
      type: full_outer
      relationship: one_to_many
    - join: credits
      from: sales_credits_items
      sql_on: |
        sales.order_entity_id = credits.order_entity_id
        AND sales.product_id = credits.product_id
      relationship: one_to_many
      required_joins: [sales]
    - join: sales
      from: sales_items
      sql_on: customers.email = sales.email
      relationship: one_to_many
      required_joins: [credits, customers]
    - join: sales_product
      from: carts_items_product
      sql_on: sales.product_id = sales_product.entity_id
      relationship: one_to_many
      required_joins: [sales]
    - join: sales_product_category
      from: catalog_categories
      sql_on: sales.product_id = sales_product_category.product_id
      relationship: one_to_many
      required_joins: [sales_product]
    - join: reviews
      from: catalog_product_reviews
      sql_on: |
        sales_product.parent_id = reviews.entity_id
        AND people.email = reviews.customer_email
      relationship: one_to_many
      required_joins: [sales_product]
    - join: shipping_charges
      from: sales_shipping_charges
      sql_on: sales.order_entity_id = shipping_charges.order_id
      relationship: one_to_many
      required_joins: [sales]
    - join: other_events
      from: people_other_events
      sql_on: people.email = other_events.email
      relationship: one_to_many
    - join: page_views_with_utm_parameters
      from: people_other_utm_visits
      sql_on: people.email = page_views_with_utm_parameters.email
      relationship: one_to_many
    - join: personalization_affinity_over_8_weeks_1
      from: personalization_affinity_8_weeks
      sql_on: people.email = personalization_affinity_over_8_weeks_1.email
      relationship: one_to_many
    - join: personalization_affinity_over_8_weeks_2
      from: personalization_affinity_8_weeks
      sql_on: people.email = personalization_affinity_over_8_weeks_2.email
      relationship: one_to_many

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
  from: catalog_products_links
  joins:
    - join: associations
      from: catalog_product_associations
      sql_on: products.entity_id = associations.product_id
      relationship: one_to_many
    - join: product_facts
      from: catalog_product_facts
      sql_on: products.entity_id = product_facts.product_id
      relationship: one_to_one
    - join: inventory_history
      from: catalog_product_inventory_history
      sql_on: products.entity_id = inventory_history.product_id
      relationship: one_to_many
    - join: weekly_sell_through
      from: catalog_product_facts_weekly_sellthrough
      sql_on: products.entity_id = weekly_sell_through.product_id
      relationship: one_to_one
    - join: categories
      from: catalog_categories
      sql_on: products.entity_id = categories.product_id
      relationship: one_to_many
    - join: product_impressions
      from: catalog_product_impressions
      sql_on: associations.parent_id = product_impressions.product_id
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
    - join: credits
      from: sales_credits_items
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
    - join: product_page_views
      from: catalog_products_page_views
      sql_on: products.url_key = product_page_views.url_key
      relationship: many_to_many
    - join: brand_similarity
      from: jaccard_order_brand_affinity
      sql_on: products.brand = brand_similarity.brand_a
      relationship: many_to_one
    - join: available_colours
      from: catalog_product_available_colours
      sql_on: associations.parent_sku = available_colours.configurable_sku
      relationship: one_to_one
    - join: available_sizes
      from: catalog_product_available_sizes
      sql_on: associations.parent_sku = available_sizes.configurable_sku
      relationship: one_to_one
    - join: return_authorizations
      from: sales_return_authorizations
      sql_on: sales.order_increment_id = return_authorizations.increment_id
      relationship: one_to_many
      required_joins: [sales]
    - join: return_authorization_items
      from: sales_return_authorizations_items
      sql_on: return_authorizations.id = return_authorization_items.rma_entity_id
      relationship: one_to_many
      required_joins: [return_authorizations]
    - join: customer_address
      from: sales_order_address
      sql_on: sales.email = customer_address.email
      relationship: one_to_many
    - join: canada_post_shipments
      from: carriers_canada_post_shipments
      sql_on: sales.order_entity_id = canada_post_shipments.order_entity_id
      relationship: one_to_many
      required_joins: [sales]
      type: full_outer
    
- explore: weekly_business_review
  from: reports_weekly_business_review
  hidden: true
  joins:
    - join: categories
      from: catalog_categories
      sql_on: weekly_business_review.parent_id = categories.product_id
      relationship: one_to_many
      
- explore: new_products
  hidden: true
  from: elasticsearch_products_new_this_week
    
- explore: removed_products
  hidden: true
  from: elasticsearch_products_removed_this_week
