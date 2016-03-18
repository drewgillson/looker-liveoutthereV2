- connection: mssql

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: inventory
  symmetric_aggregates: true
  persist_for: 1 hour
  from: catalog_product
  joins:
    - join: inventory_facts
      from: catalog_product_facts
      sql_on: inventory.entity_id = inventory_facts.product_id
      relationship: one_to_one
    - join: categories
      from: catalog_category
      sql_on: inventory.entity_id = categories.product_id
      relationship: one_to_many
    - join: impressions
      from: catalog_product_impressions
      sql_on: inventory.entity_id = impressions.product_id
      relationship: one_to_many