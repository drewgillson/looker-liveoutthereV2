- connection: mssql

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: all_inventory
  description: "Use this explore to create supply-side looks (i.e. how many units do we have available to sell and from what categories?)"
  symmetric_aggregates: true
  persist_for: 1 hour
  from: catalog_products
  joins:
    - join: associations
      from: catalog_product_associations
      sql_on: all_inventory.entity_id = associations.product_id
      relationship: one_to_many
    - join: facts
      from: catalog_product_facts
      sql_on: all_inventory.entity_id = facts.product_id
      relationship: one_to_one
    - join: categories
      from: catalog_categories
      sql_on: all_inventory.entity_id = categories.product_id
      relationship: one_to_many
    - join: impressions
      from: catalog_product_impressions
      sql_on: associations.parent_id = impressions.product_id
      required_joins: [associations]
      relationship: one_to_many
    - join: applied_catalog_price_rules
      from: catalog_price_rules
      sql_on: all_inventory.entity_id = applied_catalog_price_rules.product_id
      relationship: one_to_many
    - join: effective_discounts
      from: catalog_effective_discounts
      sql_on: all_inventory.entity_id = effective_discounts.entity_id
      relationship: one_to_many
      required_joins: [associations]
    - join: reviews
      from: catalog_product_reviews
      sql_on: associations.parent_id = reviews.entity_id
      relationship: one_to_many
      required_joins: [associations]
    - join: purchase_orders
      from: purchase_order_products
      sql_on: all_inventory.entity_id = purchase_orders.pop_product_id
      relationship: one_to_many
    - join: supplier_invoices
      from: purchase_order_invoices
      sql_on: purchase_orders.pop_order_num = supplier_invoices.poi_order_num
      relationship: one_to_many
      required_joins: [purchase_orders]
    - join: stock_movements
      sql_on: all_inventory.entity_id = stock_movements.sm_product_id
      relationship: one_to_many

