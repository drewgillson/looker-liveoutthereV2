- view: catalog_product_facts
  derived_table:
    sql: |
      SELECT a.product_id
        , SUM(qty) AS quantity_on_hand
        , MAX(historic_30_days_ago.quantity_on_hand) AS quantity_on_hand_30_days_ago
        , MAX(min_qty) AS minimum_desired_quantity
        , MAX(is_in_stock) AS is_in_stock
        , MAX(low_stock_date) AS reached_minimum_desired_quantity
        , SUM(stock_reserved_qty) AS quantity_reserved
        , MAX(ideal_stock_level) AS ideal_desired_quantity
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
    sql: ${TABLE}.is_in_stock = 1

  - dimension_group: reached_minimum_desired_quantity
    type: time
    sql: ${TABLE}.reached_minimum_desired_quantity
    
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
    type: average
    hidden: true
    sql: (${quantity_on_hand} + ${quantity_on_hand_30_days_ago}) / 2

  - measure: "quantity_sold_last_30_days"
    type: sum
    sql: ${quantity_on_hand} - ${quantity_on_hand_30_days_ago}

  - measure: average_quantity_sold_per_day
    type: average
    hidden: true
    sql: ${quantity_sold_last_30_days} / 30

  - measure: days_in_inventory
    type: average
    sql: ${quantity_on_hand} / (${quantity_sold_last_30_days} / 30)

  - measure: quantity_available_to_sell
    type: sum
    sql: ${quantity_on_hand} - ${quantity_reserved}

  sets:
    detail:
      - is_in_stock
      - quantity_on_hand
      - quantity_available_to_sell
      - days_in_inventory
      - quantity_sold_last_30_days
      
      
