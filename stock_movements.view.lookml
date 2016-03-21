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
    type: time
    sql: ${TABLE}.sm_date

  - dimension: sm_product_id
    hidden: true
    sql: ${TABLE}.sm_product_id

  - dimension: shelf_location
    type: string
    sql: ${TABLE}.shelf_location

  - dimension: description
    type: string
    sql: ${TABLE}.sm_description

  - dimension: purchase_order_number
    sql: ${TABLE}.po_order_id

  - dimension: type
    type: string
    sql: ${TABLE}.sm_type

  - dimension: source
    type: string
    sql: ${TABLE}.sm_source_stock

  - dimension: target
    type: string
    sql: ${TABLE}.sm_target_stock
    
  - measure: quantity
    type: sum
    sql: ${TABLE}.sm_qty

  - measure: count
    type: count
