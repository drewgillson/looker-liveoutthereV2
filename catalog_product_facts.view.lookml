- view: catalog_product_facts
  derived_table:
    sql: |
      SELECT a.product_id
        , SUM(qty) AS quantity_on_hand
        , MAX(historic_30_days_ago.quantity_on_hand) AS quantity_on_hand_30_days_ago
        , MAX(quantity_sold_last_30_days) AS quantity_sold_last_30_days
        , MAX(quantity_sold_all_time) AS quantity_sold_all_time
        , MAX(min_qty) AS minimum_desired_quantity
        , MAX(is_in_stock) AS is_in_stock
        , MAX(low_stock_date) AS reached_minimum_desired_quantity
        , SUM(stock_reserved_qty) AS quantity_reserved
        , MAX(ideal_stock_level) AS ideal_desired_quantity
        , MAX(last_receipt) AS last_receipt
        , MAX(last_sold) AS last_sold
        , MAX(quantity_returned_all_time) AS quantity_returned_all_time
      FROM magento.cataloginventory_stock_item AS a
      
      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END) AS quantity_on_hand
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-30,GETDATE())
        AND ((sm_type != 'transfer' OR (
            sm_type = 'transfer' AND (
              (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
            )
          )
        ))
        GROUP BY sm_product_id
      ) AS historic_30_days_ago
      ON a.product_id = historic_30_days_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_last_30_days
        FROM magento.stock_movement
        WHERE sm_date >= DATEADD(d,-30,GETDATE())
        AND sm_type = 'order'
        GROUP BY sm_product_id
      ) AS sales_30_days
      ON a.product_id = sales_30_days.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_all_time
        FROM magento.stock_movement
        WHERE sm_type = 'order'
        GROUP BY sm_product_id
      ) AS sales_all_time
      ON a.product_id = sales_all_time.product_id
      
      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , MAX(sm_date) AS last_receipt
        FROM magento.stock_movement
        WHERE sm_type = 'supply'
        GROUP BY sm_product_id
      ) AS last_received
      ON a.product_id = last_received.product_id
      
      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , MAX(sm_date) AS last_sold
        FROM magento.stock_movement
        WHERE sm_type = 'order'
        GROUP BY sm_product_id
      ) AS last_sold
      ON a.product_id = last_sold.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_returned_all_time
        FROM magento.stock_movement
        WHERE sm_type = 'transfer' AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_all_time
      ON a.product_id = returns_all_time.product_id

      GROUP BY a.product_id
    indexes: [product_id]
    sql_trigger_value: |
      SELECT CAST(GETDATE() AS date)

  fields:

  - dimension: product_id
    type: number
    primary_key: true
    hidden: true
    sql: ${TABLE}.product_id

  - dimension: minimum_desired_quantity
    type: number
    sql: ${TABLE}.minimum_desired_quantity

  - dimension: is_in_stock
    type: yesno
    sql: ${quantity_available_to_sell} > 0

  - dimension_group: reached_minimum_desired_quantity
    type: time
    sql: ${TABLE}.reached_minimum_desired_quantity

  - dimension_group: last_receipt
    type: time
    sql: ${TABLE}.last_receipt

  - dimension_group: last_sold
    type: time
    sql: ${TABLE}.last_sold
    
  - dimension: ideal_desired_quantity
    type: number
    sql: ${TABLE}.ideal_desired_quantity

  - measure: quantity_on_hand
    type: sum
    sql: ${TABLE}.quantity_on_hand

  - measure: quantity_reserved
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_reserved

  - measure: "quantity_on_hand_30_days_ago"
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_on_hand_30_days_ago

  - measure: "average_quantity_on_hand_over_30_days"
    type: number
    sql: (${quantity_on_hand} + ${quantity_on_hand_30_days_ago}) / 2

  - measure: "quantity_sold_last_30_days"
    type: sum
    sql: ${TABLE}.quantity_sold_last_30_days

  - measure: quantity_returned_all_time
    type: sum
    sql: ${TABLE}.quantity_returned_all_time

  - measure: quantity_sold_all_time
    type: sum
    sql: ${TABLE}.quantity_sold_all_time

  - measure: net_sold_quantity_all_time
    type: number
    sql: ${quantity_sold_all_time} - ${quantity_returned_all_time}

  - measure: average_quantity_sold_per_day
    type: number
    value_format_name: decimal_2
    sql: ${quantity_sold_last_30_days} / 30.0

  - measure: days_of_inventory_calculation
    type: number
    hidden: true
    sql: ${quantity_on_hand} / NULLIF((${quantity_sold_last_30_days} / 30.0),0)

  - measure: days_of_inventory_remaining
    type: number
    sql: |
      CASE WHEN ${quantity_available_to_sell} > 0 AND ${days_of_inventory_calculation} IS NULL THEN 9999 ELSE ${days_of_inventory_calculation} END

  - measure: sell_through_rate
    description: "Net sold quantity divided by (quantity on hand plus net sold quantity)"
    type: number
    value_format: "0%"
    sql: (${net_sold_quantity_all_time} / NULLIF(${quantity_on_hand} + ${net_sold_quantity_all_time},0))

  - measure: quantity_available_to_sell
    type: number
    sql: ${quantity_on_hand} - ${quantity_reserved}
    
  - measure: return_rate
    type: number
    value_format: "0%"
    sql: ${quantity_returned_all_time} / NULLIF(CAST(${quantity_sold_all_time} AS float),0)
    
