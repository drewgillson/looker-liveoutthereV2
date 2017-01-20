view: orderforms_po_items {
  derived_table: {
      sql: SELECT *
            , (qty * cost) AS ext_cost
            , (qty * price) AS ext_msrp
            , (qty * cost) - ((CAST(discount AS float) / 100) * cost) AS ext_discounted_cost
           FROM (
              SELECT a.id
              , a.purchase_order
              , a.sku
              -- somehow there are extra spaces and line breaks that are getting imported... figure out how to fix in orderform.synchronize sproc:
              , CASE WHEN ISNUMERIC(LTRIM(RTRIM(REPLACE(a.qty,CHAR(13),'')))) = 1 THEN CAST(LTRIM(RTRIM(REPLACE(a.qty,CHAR(13),''))) AS int) ELSE 0 END AS qty
              , a.season
              , AVG(CAST(CASE WHEN ISNUMERIC(b.cost) = 1 THEN b.cost END AS money)) AS cost
              , AVG(CAST(CASE WHEN ISNUMERIC(b.price) = 1 THEN b.price END AS money)) AS price
              , MAX(b.category) AS category
              , MAX(b.department) AS department
              , MAX(b.budget_type) AS budget_type
              , MAX(b.source_sheet) AS source_sheet
              , c.po_ship_date AS ship
              , c.po_discount AS discount
              , c.po_status AS po_status
             FROM orderform.po_items AS a
             LEFT JOIN orderform.loadfiles AS b
              ON a.sku = b.sku
             LEFT JOIN magento.purchase_order AS c
              ON a.purchase_order = c.po_order_id
             GROUP BY a.id, a.purchase_order, a.sku, a.qty, a.season, c.po_ship_date, c.po_discount, c.po_status
           ) AS x
       ;;
    indexes: ["purchase_order", "sku", "season"]
    persist_for: "1 hour"
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: purchase_order {
    type: string
    sql: ${TABLE}.purchase_order ;;
  }

  dimension: po_status {
    label: "PO Status"
    type: string
    sql: ${TABLE}.po_status ;;
  }

  dimension: source_sheet {
    type: string
    hidden: yes
    sql: ${TABLE}.source_sheet ;;
  }

  dimension: budget_type {
    type: string
    sql: ${TABLE}.budget_type ;;
  }

  dimension: category {
    type: string
    hidden: yes
    sql: ${TABLE}.category ;;
  }

  dimension: category_level_1 {
    type: string
    hidden: yes
    sql: CASE WHEN ${category} LIKE '%/%' THEN LEFT(${category},CHARINDEX('/',${category})-1) ELSE ${category} END ;;
  }

  dimension: department {
    type: string
    hidden: yes
    sql: ${TABLE}.department ;;
  }

  dimension_group: ship {
    type: time
    sql: ${TABLE}.ship ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  measure: qty {
    label: "Units on Order"
    description: "qty quantity uoo"
    type: sum
    sql: ${TABLE}.qty ;;
  }

  dimension: season {
    type: string
    sql: ${TABLE}.season ;;
  }

  measure: extended_cost {
    label: "Ext. Cost $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.ext_cost ;;
  }

  measure: extended_discounted_cost {
    label: "Ext. Discounted Cost $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.ext_discounted_cost ;;
  }

  measure: extended_msrp {
    label: "Ext. MSRP $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.ext_msrp ;;
  }

  measure: extended_margin {
    label: "Ext. Margin %"
    type: number
    value_format: "0%"
    sql: 1 - (${extended_cost} / NULLIF(${extended_msrp},0)) ;;
  }

  measure: percent_of_total_extended_cost {
    label: "% of Total - Ext. Cost $"
    type: percent_of_total
    sql: ${extended_cost} ;;
  }

  measure: percent_of_total_extended_msrp {
    label: "% of Total - Ext. MSRP $"
    type: percent_of_total
    sql: ${extended_msrp} ;;
  }

  set: detail {
    fields: [purchase_order, sku, qty]
  }
}
