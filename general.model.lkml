label: "1. General"

connection: "mssql"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: people {
  description: "Use to answer questions about visitor & prospect behaviour (pre-sale)"
  from: people
  symmetric_aggregates: yes
  persist_for: "12 hours"

  fields: [ALL_FIELDS*, -sales.braintree_discrepancy, -sales.paypal_discrepancy, -sales.days_since_first_receipt]

  join: people_facts {
    sql_on: people.email = ${people_facts.email} ;;
    relationship: one_to_one
  }

  join: people_favourite_brands {
    sql_on: people.email = ${people_favourite_brands.email} ;;
    relationship: one_to_many
  }

  join: people_favourite_budget_types {
    sql_on: people.email = ${people_favourite_budget_types.email} ;;
    relationship: one_to_many
  }

  join: customers {
    sql_on: people.email = customers.email ;;
    relationship: one_to_one
  }

  join: cart_items {
    from: carts_items
    sql_on: people.email = cart_items.email ;;
    relationship: one_to_many
  }

  join: cart_items_product {
    from: carts_items_product
    sql_on: cart_items.product_id = cart_items_product.entity_id ;;
    relationship: one_to_many
    required_joins: [cart_items]
  }

  join: cart_items_category {
    from: catalog_categories
    sql_on: cart_items_product.entity_id = cart_items_category.product_id ;;
    relationship: one_to_many
    required_joins: [cart_items_product]
  }

  join: mailchimp_list {
    sql_on: people.email = mailchimp_list.email_address ;;
    relationship: one_to_one
  }

  join: mailchimp_activity_1 {
    from: mailchimp_activity
    sql_on: people.email = mailchimp_activity_1.email ;;
    relationship: one_to_many
  }

  join: mailchimp_activity_2 {
    from: mailchimp_activity
    sql_on: people.email = mailchimp_activity_2.email ;;
    relationship: one_to_many
  }

  join: product_page_views {
    from: people_products_page_views
    sql_on: people.email = product_page_views.email ;;
    relationship: one_to_many
  }

  join: product_page_views_product {
    from: people_products_page_views_product
    sql_on: product_page_views.url_key = product_page_views_product.url_key ;;
    relationship: one_to_many
    required_joins: [product_page_views]
  }

  join: product_page_views_category {
    from: catalog_categories
    sql_on: product_page_views_product.entity_id = product_page_views_category.product_id ;;
    relationship: one_to_many
    required_joins: [product_page_views_product]
  }

  join: personalization_affinity_1 {
    from: personalization_affinity
    sql_on: people.email = personalization_affinity_1.email ;;
    relationship: one_to_many
  }

  join: personalization_affinity_2 {
    from: personalization_affinity
    sql_on: people.email = personalization_affinity_2.email ;;
    relationship: one_to_many
  }

  join: customer_address {
    from: sales_order_address
    sql_on: people.email = customer_address.email AND customer_address.sequence = 1 ;;
    relationship: one_to_many
  }

  join: other_page_views_1 {
    from: people_other_page_views
    sql_on: people.email = other_page_views_1.email ;;
    relationship: one_to_many
  }

  join: other_page_views_2 {
    from: people_other_page_views
    sql_on: people.email = other_page_views_2.email ;;
    relationship: one_to_many
  }

  join: other_page_views_3 {
    from: people_other_page_views
    sql_on: people.email = other_page_views_3.email ;;
    relationship: one_to_many
  }

  join: gift_certificates {
    sql_on: people.email = gift_certificates.recipient_email ;;
    type: full_outer
    relationship: one_to_many
  }

  join: credits {
    from: sales_credits_items
    sql_on: sales.order_entity_id = credits.order_entity_id
      AND sales.product_id = credits.product_id
       ;;
    relationship: one_to_many
    required_joins: [sales]
  }

  join: sales {
    from: sales_items
    sql_on: customers.email = sales.email ;;
    relationship: one_to_many
    required_joins: [credits, customers]
  }

  join: sales_product {
    from: carts_items_product
    sql_on: sales.product_id = sales_product.entity_id ;;
    relationship: one_to_many
    required_joins: [sales]
  }

  join: sales_product_category {
    from: catalog_categories
    sql_on: sales.product_id = sales_product_category.product_id ;;
    relationship: one_to_many
    required_joins: [sales_product]
  }

  join: reviews {
    from: catalog_product_reviews
    sql_on: sales_product.parent_id = reviews.entity_id
      AND people.email = reviews.customer_email
       ;;
    relationship: one_to_many
    required_joins: [sales_product]
  }

  join: shipping_charges {
    from: sales_shipping_charges
    sql_on: sales.order_entity_id = shipping_charges.order_id ;;
    relationship: one_to_many
    required_joins: [sales]
  }

  join: other_events {
    from: people_other_events
    sql_on: people.email = other_events.email ;;
    relationship: one_to_many
  }

  join: page_views_with_utm_parameters {
    from: people_other_utm_visits
    sql_on: people.email = page_views_with_utm_parameters.email ;;
    relationship: one_to_many
  }

  join: personalization_affinity_over_8_weeks_1 {
    from: personalization_affinity_8_weeks
    sql_on: people.email = personalization_affinity_over_8_weeks_1.email ;;
    relationship: one_to_many
  }

  join: personalization_affinity_over_8_weeks_2 {
    from: personalization_affinity_8_weeks
    sql_on: people.email = personalization_affinity_over_8_weeks_2.email ;;
    relationship: one_to_many
  }

  join: warranties {
    sql_on: people.email = warranties.customer_email ;;
    type: full_outer
    relationship: one_to_many
  }
}

explore: products {
  label: "Products & Sales"
  description: "Use to answer supply-side questions (i.e. how many units do we have available to sell and from what categories?)"
  symmetric_aggregates: yes
  persist_for: "12 hours"
  from: catalog_product_links
  always_join: [product_facts, categories]

  join: associations {
    from: catalog_product_associations
    sql_on: products.entity_id = associations.product_id ;;
    relationship: one_to_many
  }

  join: product_facts {
    from: catalog_product_facts
    sql_on: products.entity_id = product_facts.product_id ;;
    relationship: one_to_one
  }

  join: bucketed_sellthrough {
    from: catalog_product_bucketed_sellthrough
    sql_on: products.entity_id = bucketed_sellthrough.product_id ;;
    relationship: one_to_one
  }

  join: inventory_history {
    from: catalog_product_inventory_history
    sql_on: products.entity_id = inventory_history.product_id ;;
    relationship: one_to_many
  }

  join: weekly_sell_through {
    from: catalog_product_facts_weekly_sellthrough
    sql_on: products.entity_id = weekly_sell_through.product_id ;;
    relationship: one_to_one
  }

  join: categories {
    from: catalog_categories
    sql_on: products.entity_id = categories.product_id ;;
    relationship: one_to_many
  }

  join: product_impressions {
    from: catalog_product_impressions_filtered
    sql_on: products.url_key = product_impressions.url_key ;;
    relationship: one_to_many
  }

  join: applied_catalog_price_rules {
    from: catalog_price_rules
    sql_on: products.entity_id = applied_catalog_price_rules.product_id ;;
    relationship: one_to_many
  }

  join: effective_discounts {
    from: catalog_effective_discounts
    sql_on: products.entity_id = effective_discounts.entity_id ;;
    relationship: one_to_many
    required_joins: [associations]
  }

  join: reviews {
    from: catalog_product_reviews
    sql_on: associations.parent_id = reviews.entity_id ;;
    relationship: one_to_many
    required_joins: [associations]
  }

  join: purchase_orders {
    from: purchase_order_products
    sql_on: products.entity_id = purchase_orders.pop_product_id ;;
    relationship: one_to_many
  }

  join: supplier_invoices {
    from: purchase_order_invoices
    sql_on: purchase_orders.pop_order_num = supplier_invoices.poi_order_num ;;
    relationship: one_to_many
    required_joins: [purchase_orders]
  }

  join: stock_movements {
    sql_on: products.entity_id = stock_movements.sm_product_id ;;
    relationship: one_to_many
  }

  join: credits {
    from: sales_credits_items
    sql_on: sales.order_entity_id = credits.order_entity_id
      AND sales.product_id = credits.product_id
       ;;
    relationship: one_to_many
    required_joins: [sales]
  }

  join: sales {
    from: sales_items
    sql_on: products.entity_id = sales.product_id ;;
    relationship: one_to_many
    required_joins: [credits]
  }

  join: sales_facts {
    from: sales_items_configurable_facts
    sql_on:  ${associations.configurable_sku} = ${sales_facts.configurable_sku} AND ${sales.order_created_date} < DATEADD(dd,365,${sales_facts.first_receipt_date});;
    relationship: one_to_many
    required_joins: [associations,sales]
  }

  join: organizers {
    from:  organizers
    sql_on:  sales.order_entity_id = organizers.entity_id AND organizers.entity_type = 'order' AND organizers.caption NOT LIKE 'Credit memo created with reason%' ;;
    relationship: one_to_many
    required_joins: [sales]
  }

  join: shipping_charges {
    from: sales_shipping_charges
    sql_on: sales.order_entity_id = shipping_charges.order_id ;;
    relationship: one_to_one
    required_joins: [sales]
  }

  join: shipping_tracking {
    from: sales_shipping_tracking
    sql_on: sales.order_entity_id = shipping_tracking.order_id ;;
    relationship: many_to_many
    required_joins: [sales]
  }

  join: lateshipment_data {
    from: carriers_lateshipment_data
    sql_on: ${shipping_tracking.tracking_number} = lateshipment_data."Tracking Number" ;;
    relationship: one_to_one
    required_joins: [shipping_tracking]
  }

  join: product_page_views {
    from: catalog_product_page_views_filtered
    sql_on: products.url_key = product_page_views.url_key ;;
    relationship: many_to_many
  }

  join: brand_similarity {
    from: jaccard_order_brand_affinity
    sql_on: products.brand = brand_similarity.brand_a ;;
    relationship: many_to_one
  }

  join: alternate_images {
    from: catalog_product_alternate_images
    sql_on: associations.parent_sku = alternate_images.sku ;;
    relationship: one_to_one
    required_joins: [associations]
  }

  join: available_colours {
    from: catalog_product_available_colours
    sql_on: associations.parent_sku = available_colours.configurable_sku ;;
    relationship: one_to_one
  }

  join: available_sizes {
    from: catalog_product_available_sizes
    sql_on: associations.parent_sku = available_sizes.configurable_sku ;;
    relationship: one_to_one
  }

  join: return_authorizations {
    from: sales_return_authorizations
    sql_on: sales.order_increment_id = return_authorizations.increment_id ;;
    relationship: one_to_many
    required_joins: [sales]
  }

  join: return_authorization_items {
    from: sales_return_authorizations_items
    sql_on: return_authorizations.id = return_authorization_items.rma_entity_id ;;
    relationship: one_to_many
    required_joins: [return_authorizations]
  }

  join: customer_address {
    from: sales_order_address
    sql_on: sales.order_entity_id = customer_address.parent_id ;;
    relationship: one_to_many
  }

  join: canada_post_shipments {
    from: carriers_canada_post_shipments
    sql_on: sales.order_entity_id = canada_post_shipments.order_entity_id ;;
    relationship: one_to_many
    required_joins: [sales]
    type: full_outer
  }

  join: elasticsearch {
    from: elasticsearch_products_latest
    sql_on: products.parent_id = ${elasticsearch.entity_id} ;;
    relationship: one_to_one
  }

  join: order_sequence {
    from: sales_order_sequence
    sql_on: sales.order_entity_id = order_sequence.order_entity_id ;;
    relationship: one_to_one
  }

  join: loadfiles {
    from: orderforms_loadfiles
    sql_on: products.sku = loadfiles.sku ;;
    relationship: one_to_one
    required_joins: [categories]
  }

  join: collections {
    from: catalog_product_collections
    sql_on: products.sku = collections.sku ;;
    relationship: one_to_many
  }

  join: collections_flattened {
    from: catalog_product_collections_flattened
    sql_on: products.sku = collections_flattened.sku ;;
    relationship: one_to_many
  }

  join: transactions {
    sql_on: (${sales.order_entity_id} = ${transactions.entity_id} AND ${transactions.type} = 'sale')
            OR (${credits.creditmemo_entity_id} = ${transactions.credit_memo_id} AND ${transactions.type} = 'credit')
      ;;
    relationship: many_to_one
  }

  join: tax {
    from: transactions_tax
    sql_on: transactions.entity_id = tax.order_id
      ;;
    relationship: one_to_many
  }

  join: braintree {
    from: transactions_braintree
    type: full_outer
    sql_on: transactions.transaction_id = braintree."Transaction ID"
      ;;
    relationship: one_to_many
    required_joins: [transactions]
  }

  #   used to pull PayPal transactions into the explore
  join: paypal_settlement {
    from: transactions_paypal_settlement
    type: full_outer
    sql_on: paypal_settlement.transaction_id = transactions.transaction_id ;;
    relationship: one_to_many
  }
}

explore: snowplow {
  symmetric_aggregates: yes
  description: "Use this explore to investigate how people behave on our website: where do they come from? what do they do?"
  persist_for: "24 hours"

  join: domain_userid_facts {
    from: snowplow_domain_userid_facts
    sql_on: snowplow.domain_userid = domain_userid_facts.domain_userid ;;
    relationship: many_to_one
  }

  join: event_sequence {
    from: snowplow_event_sequences
    sql_on: snowplow.event_id = event_sequence.event_id ;;
    relationship: one_to_one
  }

  join: reverse_utm_sequences {
    from: snowplow_utm_sequences_for_orders
    sql_on: snowplow.event_id = reverse_utm_sequences.event_id ;;
    relationship: one_to_many
  }

  conditionally_filter: {
    filters: {
      field: snowplow.app_id
      value: "lot-production"
    }

    filters: {
      field: snowplow.event_type
      value: "page_view"
    }

    filters: {
      field: snowplow.live_out_there_user_id
      value: "-NULL"
    }

    filters: {
      field: snowplow.snowplow_user_id
      value: "-NULL"
    }

    unless: [snowplow.snowplow_user_id, snowplow.live_out_there_user_id, snowplow.app_id, snowplow.event_type]
  }
}

explore: sort_order {
  from: sort_order_opportunity
  hidden: yes

  join: orders {
    from: sort_order_orders
    sql_on:  ${sort_order.configurable_sku} = ${orders.configurable_sku} ;;
    relationship: one_to_one
  }

  join: conversion_rate {
    from: sort_order_conversion_rate
    sql_on:  ${sort_order.configurable_sku} = ${conversion_rate.configurable_sku} ;;
    relationship: one_to_one
  }

  join: quantity {
    from: sort_order_quantity
    sql_on:  ${sort_order.configurable_sku} = ${quantity.configurable_sku} ;;
    relationship: one_to_one
  }

  join: page_views {
    from: sort_order_page_views
    sql_on:  ${sort_order.configurable_sku} = ${page_views.configurable_sku} ;;
    relationship: one_to_one
  }

  join: price {
    from: sort_order_price
    sql_on:  ${sort_order.configurable_sku} = ${price.configurable_sku} ;;
    relationship: one_to_one
  }

  join: reviews {
    from: sort_order_reviews
    sql_on:  ${sort_order.configurable_sku} = ${reviews.configurable_sku} ;;
    relationship: one_to_one
  }

  join: days_since_last_receipt {
    from: sort_order_days_since_last_receipt
    sql_on:  ${sort_order.configurable_sku} = ${days_since_last_receipt.configurable_sku} ;;
    relationship: one_to_one
  }

  join: gross_sold_quantity {
    from: sort_order_gross_sold_quantity
    sql_on:  ${sort_order.configurable_sku} = ${gross_sold_quantity.configurable_sku} ;;
    relationship: one_to_one
  }

  join: discounts {
    from: sort_order_discounts
    sql_on:  ${sort_order.configurable_sku} = ${discounts.configurable_sku} ;;
    relationship: one_to_one
  }

  always_filter: {
    filters: {
      field: sort_order.configurable_sku
      value: "-NULL"
    }
  }
}
