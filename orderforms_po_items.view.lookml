- view: orderforms_po_items
  derived_table:
    sql: |
      SELECT a.id
        , a.purchase_order
        , a.sku
        , a.qty
        , a.season
        , AVG(CAST(CASE WHEN ISNUMERIC(b.cost) = 1 THEN b.cost END AS money)) AS cost
        , AVG(CAST(CASE WHEN ISNUMERIC(b.price) = 1 THEN b.price END AS money)) AS price
        , MAX(b.category) AS category
        , MAX(b.department) AS department
        , MAX(b.budget_type) AS budget_type
        , MAX(b.source_sheet) AS source_sheet
        , MAX(d.inventory_type) AS inventory_type
        , c.po_ship_date AS ship
        , c.po_discount AS discount
      FROM orderform.po_items AS a
      LEFT JOIN orderform.loadfiles AS b
        ON a.sku = b.sku
      LEFT JOIN magento.purchase_order AS c
        ON a.purchase_order = c.po_order_id
      LEFT JOIN lut_messy_category_data AS d
        ON b.category = d.category
      GROUP BY a.id, a.purchase_order, a.sku, a.qty, a.season, c.po_ship_date, c.po_discount
    indexes: [purchase_order, sku, season]
    persist_for: 1 hour

  fields:

  - dimension: id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.id

  - dimension: purchase_order
    type: string
    sql: ${TABLE}.purchase_order

  - dimension: inventory_type
    type: string
    hidden: true
    sql: ${TABLE}.inventory_type

  - dimension: source_sheet
    type: string
    hidden: true
    sql: ${TABLE}.source_sheet
    
  - dimension: budget_type
    type: string
    hidden: true
    sql: |
      CASE WHEN ${TABLE}.budget_type IS NOT NULL THEN ${TABLE}.budget_type
           WHEN ${source_sheet} = 'Fashion' THEN 'Fashion'
           WHEN ${source_sheet} = 'Kids' THEN 'Kids'
           WHEN ${category} LIKE '%Footwear%' THEN 'Footwear'
           WHEN ${category} LIKE '%Gear%' THEN 'Gear'
           ELSE 'Apparel'
      END

  - dimension: category
    type: string
    hidden: true
    sql: ${TABLE}.category

  - dimension: category_level_1
    type: string
    hidden: true
    sql: CASE WHEN ${category} LIKE '%/%' THEN LEFT(${category},CHARINDEX('/',${category})-1) ELSE ${category} END

  - dimension: department
    type: string
    hidden: true
    sql: ${TABLE}.department

  - dimension_group: ship
    type: time
    sql: ${TABLE}.ship

  - dimension: sku
    type: string
    sql: ${TABLE}.sku

  - measure: qty
    label: "Units on Order"
    description: "qty quantity uoo"
    type: sum
    sql: ${TABLE}.qty
    
  - dimension: season
    type: string
    sql: ${TABLE}.season
    
  - measure: extended_cost_item
    hidden: true
    type: sum
    sql: |
      CASE WHEN ISNUMERIC(${TABLE}.qty) = 1 THEN CAST(${TABLE}.qty AS int) * CAST(${TABLE}.cost AS money) END
    
  - measure: extended_cost
    label: "Ext. Cost $"
    type: number
    value_format: "$#,##0"
    sql: ${extended_cost_item}
    
  - measure: extended_discounted_cost_item
    type: sum
    sql: |
      CASE WHEN ISNUMERIC(${TABLE}.qty) = 1 THEN CAST(${TABLE}.qty AS int) * (CAST(${TABLE}.cost AS money) - ((CAST(${TABLE}.discount AS float) / 100) * CAST(${TABLE}.cost AS money))) END
    
  - measure: extended_discounted_cost
    label: "Ext. Discounted Cost $"
    type: number
    value_format: "$#,##0"
    sql: ${extended_discounted_cost_item}

  - measure: extended_msrp_item
    hidden: true
    type: sum
    sql: |
      CASE WHEN ISNUMERIC(${TABLE}.qty) = 1 THEN CAST(${TABLE}.qty AS int) * CAST(${TABLE}.price AS money) END

  - measure: extended_msrp
    label: "Ext. MSRP $"
    type: number
    value_format: "$#,##0"
    sql: ${extended_msrp_item}
    
  - measure: extended_margin
    label: "Ext. Margin %"
    type: number
    value_format: "0%"
    sql: 1 - (${extended_cost} / NULLIF(${extended_msrp},0))

  - measure: percent_of_total_extended_cost
    label: "% of Total - Ext. Cost $"
    type: percent_of_total
    sql: ${extended_cost}
      
  - measure: percent_of_total_extended_msrp
    label: "% of Total - Ext. MSRP $"
    type: percent_of_total
    sql: ${extended_msrp}
    
  sets:
    detail:
      - purchase_order
      - sku
      - qty