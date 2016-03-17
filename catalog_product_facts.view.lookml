- view: catalog_product_facts
  derived_table:
    sql: |
      SELECT a.product_id
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) END AS quantity_on_hand
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) * MAX(catalog_product.cost) END AS total_cost
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) * MAX(catalog_product.price) END AS total_sales_opportunity
        , MAX(historic_30_days_ago.quantity_on_hand) AS quantity_on_hand_30_days_ago
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_last_30_days) - ABS(SUM(qty)) ELSE MAX(quantity_sold_last_30_days) END AS quantity_sold_last_30_days
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_all_time) - ABS(SUM(qty)) ELSE MAX(quantity_sold_all_time) END AS quantity_sold_all_time
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
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_30_days
      ON a.product_id = sales_30_days.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_all_time
        FROM magento.stock_movement
        WHERE (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
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
        WHERE (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
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

      LEFT JOIN ${catalog_product.SQL_TABLE_NAME} AS catalog_product
      ON a.product_id = catalog_product.entity_id

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
    description: "Minimum quantity we want to keep in stock"
    type: number
    sql: ${TABLE}.minimum_desired_quantity

  - dimension: is_in_stock
    description: "Is 'Yes' if the total quantity available to sell is greater than 0"
    type: yesno
    sql: ${quantity_available_to_sell} > 0

  - dimension_group: reached_minimum_desired_quantity
    description: "Date we reached the minimum desired quantity for a product"
    type: time
    sql: ${TABLE}.reached_minimum_desired_quantity

  - dimension_group: last_receipt
    description: "Date we last received a product"
    type: time
    sql: ${TABLE}.last_receipt

  - dimension_group: last_sold
    description: "Date we lost sold a product"
    type: time
    sql: ${TABLE}.last_sold
    
  - dimension: ideal_desired_quantity
    description: "Ideal quantity we want to keep in stock"
    type: number
    sql: ${TABLE}.ideal_desired_quantity

  - measure: quantity_on_hand
    description: "Quantity currently on hand / in stock"
    type: sum
    sql: ${TABLE}.quantity_on_hand

  - measure: total_cost
    description: "Total cost of the inventory we have on hand before discounts"
    label: "Total Cost $"
    type: sum
    value_format: '$#,##0.00'
    sql: ${TABLE}.total_cost

  - measure: total_sales_opportunity
    description: "Total sales opportunity of the inventory we have on hand"
    label: "Total Sales Opportunity $"
    type: sum
    value_format: '$#,##0.00'
    sql: ${TABLE}.total_sales_opportunity

  - measure: percent_of_total_sales_opportunity
    description: "Percentage of sales opportunity compared to total"
    label: "% of Total Sales Opportunity"
    type: percent_of_total
    value_format: '0.00\%'
    sql: ${total_sales_opportunity}

  - measure: quantity_reserved
    description: "Reserved quantity / units"
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_reserved

  - measure: "quantity_on_hand_30_days_ago"
    description: "Quantity we had on hand 30 days ago (used for days in inventory calculation)"
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_on_hand_30_days_ago

  - measure: "average_quantity_on_hand_over_30_days"
    description: "Average inventory quantity during the past 30 days"
    type: number
    sql: (${quantity_on_hand} + ${quantity_on_hand_30_days_ago}) / 2

  - measure: "quantity_sold_last_30_days"
    description: "Quantity sold during the past 30 days"
    type: sum
    sql: ${TABLE}.quantity_sold_last_30_days

  - measure: quantity_returned_all_time
    description: "All-time quantity returned"
    type: sum
    sql: ${TABLE}.quantity_returned_all_time

  - measure: quantity_sold_all_time
    description: "All-time quantity sold"
    type: sum
    sql: ${TABLE}.quantity_sold_all_time

  - measure: net_sold_quantity_all_time
    description: "Total quantity sold minus the total quantity returned (all-time), used for calculating sell through rate"
    type: number
    sql: ${quantity_sold_all_time} - ${quantity_returned_all_time}

  - measure: average_quantity_sold_per_day
    description: "Quantity of units sold per day based on 30-day sales history"
    type: number
    value_format_name: decimal_2
    sql: ${quantity_sold_last_30_days} / 30.0

  - measure: days_of_inventory_calculation
    type: number
    hidden: true
    sql: ${quantity_on_hand} / NULLIF((${quantity_sold_last_30_days} / 30.0),0)

  - measure: days_of_inventory_remaining
    description: "Based on 30-day sales history, the number of days that will elapse before we run out of inventory"
    type: number
    sql: |
      CASE WHEN ${quantity_available_to_sell} > 0 AND ${days_of_inventory_calculation} IS NULL THEN 9999 ELSE ${days_of_inventory_calculation} END

  - measure: sell_through_rate
    description: "Net sold quantity divided by (quantity on hand plus net sold quantity)"
    type: number
    value_format: '0%'
    sql: (${net_sold_quantity_all_time} / NULLIF(${quantity_on_hand} + ${net_sold_quantity_all_time},0))

  - measure: quantity_available_to_sell
    description: "Quantity on hand minus quantity reserved for orders that haven't shipped"
    type: number
    sql: ${quantity_on_hand} - ${quantity_reserved}
    
  - measure: return_rate
    description: "Percentage of units sold that were returned (warning: this measure seems to return results that are suspiciously low)"
    type: number
    value_format: '0%'
    sql: ${quantity_returned_all_time} / NULLIF(CAST(${quantity_sold_all_time} AS float),0)
    
