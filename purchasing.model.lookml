- label: "2. Purchasing"
- connection: mssql

- include: "*.view.lookml"       # include all views in this project
- include: "*.dashboard.lookml"  # include all dashboards in this project

- explore: assortment_planning
  description: "Use to explore the order line item data entered in Google Sheets order forms"
  from: orderforms_seasons
  joins:
    - join: budgets
      from: orderforms_budgets
      sql_on: assortment_planning.season = budgets.season
      relationship: many_to_many
    - join: items
      from: orderforms_po_items
      sql_on: assortment_planning.season = items.season
      relationship: many_to_one
    - join: loadfile
      from: orderforms_loadfiles
      sql_on: items.sku = loadfile.sku
      relationship: many_to_one
      required_joins: [items]
    - join: items_for_budget
      from: orderforms_po_items
      sql_on: |
        budgets.season = items_for_budget.season
        AND LEFT(${budgets.month},7) = ${items_for_budget.ship_month}
        AND budgets.department = CASE WHEN items_for_budget.budget_type = 'Footwear' AND items_for_budget.department IN ('Men^Women') THEN 'Men' WHEN items_for_budget.department IN ('Boys','Girls','Kids','Men^Women','Infant','Toddler','Toddler^Infant') THEN 'Unisex' ELSE items_for_budget.department END
        AND budgets.type = ${items_for_budget.budget_type}
      relationship: one_to_many
    - join: products
      from: catalog_products_links
      sql_on: loadfile.sku = products.sku
      relationship: many_to_one
      required_joins: [loadfile]
    - join: product_facts
      from: catalog_product_facts
      sql_on: products.entity_id = product_facts.product_id
      relationship: one_to_many
    - join: errors
      from: orderforms_error_tracker
      sql_on: assortment_planning.season = errors.brand
      type: full_outer
      relationship: one_to_many

- explore: assortment_planning_not_mapped_to_budget
  description: "Hidden explore to complement the explore above, but with a slightly different join predicate to find ordered items that don't map to a budget."
  hidden: true
  from: orderforms_loadfiles
  joins:
    - join: items
      from: orderforms_po_items
      sql_on: assortment_planning_not_mapped_to_budget.sku = items.sku
      relationship: many_to_one
    - join: categories
      from: orderforms_category_map
      sql_on: assortment_planning_not_mapped_to_budget.category = categories.category
      relationship: one_to_one
    - join: budgets
      from: orderforms_budgets
      sql_on: | 
        budgets.season = items.season
        AND LEFT(${budgets.month},7) = ${items.ship_month}
        AND budgets.department = CASE WHEN assortment_planning_not_mapped_to_budget.budget_type = 'Footwear' AND assortment_planning_not_mapped_to_budget.department IN ('Men^Women') THEN 'Men' WHEN assortment_planning_not_mapped_to_budget.department IN ('Boys','Girls','Kids','Men^Women','Infant','Toddler','Toddler^Infant') THEN 'Unisex' ELSE assortment_planning_not_mapped_to_budget.department END
        AND budgets.type = ${assortment_planning_not_mapped_to_budget.budget_type}
      relationship: one_to_one
      required_joins: [categories]

- explore: item_master
  description: "Use to explore the raw supplier item master data entered in (old) Google Sheets item masters. Replaced by in-order-form item masters for SS17 and forward."
  label: "Supplier Item Masters"
  from: orderforms_item_master
