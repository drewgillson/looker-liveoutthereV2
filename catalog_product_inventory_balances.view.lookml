- view: catalog_product_inventory_balances
  derived_table:
    sql: |
      SELECT dates.sm_date
         , sm_product_id AS product_id
           , SUM(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END) AS quantity
      FROM magento.stock_movement
      LEFT JOIN (
        SELECT DISTINCT CAST(sm_date AS date) AS sm_date FROM magento.stock_movement
      ) AS dates
      ON magento.stock_movement.sm_date <= dates.sm_date
      WHERE ((sm_type != 'transfer' OR (
          sm_type = 'transfer' AND (
            (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
          )
        )
      ))
      GROUP BY dates.sm_date, sm_product_id
    indexes: [sm_date, product_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: key
    type: string
    primary_key: true
    hidden: true
    sql: CAST(${TABLE}.product_id AS varchar(20)) + CONVERT(VARCHAR, ${TABLE}.sm_date, 120)

  - dimension_group: inventory_balance
    description: "Date of inventory balance record"
    type: time
    sql: ${TABLE}.sm_date

  - dimension: product_id
    type: number
    hidden: true
    sql: ${TABLE}.product_id

  - measure: quantity_on_hand
    description: "Quantity on hand / in stock for inventory balance date"
    type: sum
    sql: ${TABLE}.quantity