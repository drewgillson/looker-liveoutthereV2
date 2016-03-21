- connection: mssql

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: inventory
  symmetric_aggregates: true
  persist_for: 1 hour
  from: catalog_products
  joins:
    - join: associations
      from: catalog_product_associations
      sql_on: inventory.entity_id = associations.product_id
      relationship: one_to_many
    - join: inventory_facts
      from: catalog_product_facts
      sql_on: inventory.entity_id = inventory_facts.product_id
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
    - join: price_rules
      from: catalog_price_rules
      sql_on: inventory.entity_id = price_rules.product_id
      relationship: one_to_many
    - join: reviews
      from: catalog_product_reviews
      sql_on: associations.parent_id = reviews.entity_id
      relationship: one_to_many
      required_joins: [associations]
    - join: purchase_orders
      from: purchase_order_products
      sql_on: inventory.entity_id = purchase_orders.pop_product_id
      relationship: one_to_many
    - join: purchase_order_invoices
      sql_on: purchase_orders.pop_order_num = purchase_order_invoices.poi_order_num
      relationship: one_to_many
      required_joins: [purchase_orders]
