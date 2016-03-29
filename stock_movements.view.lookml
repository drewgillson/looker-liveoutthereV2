- view: stock_movements
  derived_table:
    sql: |
      SELECT a.sm_id
        , a.sm_date
        , a.sm_product_id
        , b.shelf_location
        , a.sm_qty
        , a.sm_description
        , e.po_order_id
        , a.sm_type
        , c.stock_name AS sm_source_stock
        , d.stock_name AS sm_target_stock
      FROM magento.stock_movement AS a
      LEFT JOIN magento.cataloginventory_stock_item AS b ON a.sm_product_id = b.product_id AND b.stock_id = 1
      LEFT JOIN magento.cataloginventory_stock AS c ON a.sm_source_stock = c.stock_id
      LEFT JOIN magento.cataloginventory_stock AS d ON a.sm_target_stock = d.stock_id
      LEFT JOIN magento.purchase_order AS e ON a.sm_po_num = e.po_num
    indexes: [sm_product_id, po_order_id, sm_source_stock, sm_target_stock, shelf_location]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: sm_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.sm_id

  - dimension_group: stock_movement
    description: "Date and time that a stock movement occurred"
    type: time
    sql: ${TABLE}.sm_date

  - dimension: sm_product_id
    hidden: true
    sql: ${TABLE}.sm_product_id

  - dimension: shelf_location
    description: "Shelf location that was recorded during a stock movement"
    type: string
    sql: ${TABLE}.shelf_location

  - dimension: description
    description: "Description that was recorded for a stock movement entry in the Magento audit log"
    type: string
    sql: ${TABLE}.sm_description

  - dimension: purchase_order_number
    description: "Purchase order number associated with a stock movement"
    sql: ${TABLE}.po_order_id

  - dimension: type
    description: "Stock movement type (sale, transfer, return, etc.)"
    type: string
    sql: ${TABLE}.sm_type

  - dimension: source
    description: "Source warehouse (LiveOutThere.com, Returns, etc.)"
    type: string
    sql: ${TABLE}.sm_source_stock

  - dimension: target
    description: "Target warehouse (LiveOutThere.com, Returns, etc.)"
    type: string
    sql: ${TABLE}.sm_target_stock
    
  - measure: quantity
    label: "Number of units on stock movement"
    type: sum
    sql: ${TABLE}.sm_qty

  - measure: count
    label: "Total number of stock movements"
    type: count
