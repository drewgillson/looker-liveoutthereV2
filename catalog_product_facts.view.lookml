- view: catalog_product_facts
  derived_table:
    sql: |
      SELECT a.product_id AS product_id
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) END AS quantity_on_hand
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) * MAX(catalog_product.cost) END AS total_cost
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) * MAX(average_cost.value) END AS total_discounted_cost
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) * MAX(catalog_product.price) END AS total_sales_opportunity
        , MAX(historic_30_days_ago.quantity_on_hand) AS quantity_on_hand_30_days_ago
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_last_30_days) - ABS(SUM(qty)) ELSE MAX(quantity_sold_last_30_days) END AS quantity_sold_last_30_days
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_last_180_days) - ABS(SUM(qty)) ELSE MAX(quantity_sold_last_180_days) END AS quantity_sold_last_180_days
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_all_time) - ABS(SUM(qty)) ELSE MAX(quantity_sold_all_time) END AS quantity_sold_all_time
        , MAX(min_qty) AS minimum_desired_quantity
        , MAX(is_in_stock) AS is_in_stock
        , MAX(low_stock_date) AS reached_minimum_desired_quantity
        , SUM(stock_reserved_qty) AS quantity_reserved
        , MAX(ideal_stock_level) AS ideal_desired_quantity
        , MAX(last_receipt) AS last_receipt
        , MAX(last_sold) AS last_sold
        , MAX(quantity_returned_all_time) AS quantity_returned_all_time
        , MAX(quantity_returned_last_180_days) AS quantity_returned_last_180_days
        , MAX(average_cost.value) AS average_cost
        , (MAX(catalog_product.price) - COALESCE(MAX(average_cost.value),MAX(cost.value))) / NULLIF(MAX(catalog_product.price),0) AS opening_margin
        , MAX(quantity_on_order) AS quantity_on_order

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
             , SUM(sm_qty) AS quantity_sold_last_180_days
        FROM magento.stock_movement
        WHERE sm_date >= DATEADD(d,-180,GETDATE())
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_180_days
      ON a.product_id = sales_180_days.product_id

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
        WHERE (sm_type = 'transfer' OR sm_type = 'return') AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_all_time
      ON a.product_id = returns_all_time.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_returned_last_180_days
        FROM magento.stock_movement
        WHERE sm_date >= DATEADD(d,-180,GETDATE()) AND (sm_type = 'transfer' OR sm_type = 'return') AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_180_days
      ON a.product_id = returns_180_days.product_id

      LEFT JOIN ${catalog_product.SQL_TABLE_NAME} AS catalog_product
      ON a.product_id = catalog_product.entity_id
      
      LEFT JOIN (
        SELECT pop_product_id
           , ROUND(AVG((pop_price_ht * (1-(CASE WHEN pop_discount > 0 THEN pop_discount ELSE 0 END / 100)))), 2) AS value 
        FROM magento.purchase_order_product
        WHERE pop_price_ht <> 0 
        AND pop_supplied_qty > 0 
        AND pop_discount <> 100 
        GROUP BY pop_product_id
      ) AS average_cost
      ON a.product_id = average_cost.pop_product_id
      
      LEFT JOIN (
        SELECT entity_id, value FROM magento.catalog_product_entity_decimal WHERE attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'cost')
      ) AS cost
      ON a.product_id = cost.entity_id
      
      LEFT JOIN (
        SELECT a.pop_product_id AS product_id
             , (SUM(a.pop_qty) - SUM(a.pop_supplied_qty)) AS quantity_on_order
        FROM magento.purchase_order_product AS a
        INNER JOIN magento.purchase_order AS b
          ON a.pop_order_num = b.po_num
        WHERE b.po_status NOT IN ('complete','closed','cancelled') AND b.po_cancel_date > GETDATE()
        GROUP BY a.pop_product_id
      ) AS quantity_on_order
      ON a.product_id = quantity_on_order.product_id
      
      GROUP BY a.product_id
    indexes: [product_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - filter: last_receipt_date_filter

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
    sql: ${TABLE}.quantity_on_hand > 0

  - dimension: is_available_to_sell
    description: "Is 'Yes' if the total quantity available to sell is greater than 0"
    type: yesno
    sql: (${TABLE}.quantity_on_hand - ${TABLE}.quantity_reserved) > 0

  - dimension_group: reached_minimum_desired_quantity
    description: "Date we reached the minimum desired quantity for a product"
    type: time
    sql: ${TABLE}.reached_minimum_desired_quantity

  - dimension: last_receipt
    description: "Date we last received a product"
    type: time
    sql: |
      CASE
        WHEN {% condition last_receipt_date_filter %} LEFT(CONVERT(VARCHAR, ${TABLE}.last_receipt, 120), 10) {% endcondition %}
        THEN ${TABLE}.last_receipt
        ELSE '9999-01-01'
      END

  - dimension: last_sold
    description: "Date we lost sold a product"
    type: time
    sql: ${TABLE}.last_sold

  - measure: max_last_receipt
    description: "Date we last received a product"
    type: date
    sql: |
      CASE
        WHEN {% condition last_receipt_date_filter %} LEFT(CONVERT(VARCHAR, MAX(${TABLE}.last_receipt), 120), 10) {% endcondition %}
        THEN MAX(${TABLE}.last_receipt)
        ELSE '9999-01-01'
      END

  - measure: max_last_sold
    description: "Date we lost sold a product"
    type: date
    sql: MAX(${TABLE}.last_sold)
    
  - dimension: ideal_desired_quantity
    description: "Ideal quantity we want to keep in stock"
    type: number
    sql: ${TABLE}.ideal_desired_quantity
    
  - measure: average_cost
    label: "Average Cost $"
    description: "Average landed cost per unit, after discounts"
    type: avg
    value_format: '$#,##0.00'
    sql: ISNULL(${TABLE}.average_cost,${products.cost})

  - measure: skus_on_hand
    hidden: true
    type: sum
    sql: CASE WHEN ${TABLE}.quantity_on_hand > 0 THEN 1 END

  - measure: quantity_on_order
    description: "Quantity currently on order from purchase orders that are not complete, closed, or cancelled, and are not past their cancel date"
    type: sum
    sql: ${TABLE}.quantity_on_order
    
  - measure: quantity_on_hand
    description: "Quantity currently on hand / in stock"
    type: sum
    sql: ${TABLE}.quantity_on_hand
    drill_fields: [inventory_facts*]

  - measure: total_discounted_cost
    description: "Total cost of the inventory we have on hand (at average cost after discounts)"
    label: "Discounted Cost On Hand $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.total_discounted_cost

  - measure: total_cost
    description: "Total cost of the inventory we have on hand (at wholesale cost before discounts)"
    label: "Wholesale Cost On Hand $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.total_cost

  - measure: total_sales_opportunity
    description: "Total sales opportunity of the inventory we have on hand"
    label: "Sales Opportunity On Hand $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.total_sales_opportunity
    drill_fields: [inventory_facts*]
    
  - measure: opening_margin
    label: "Opening Margin %"
    type: avg
    value_format: '0\%'
    sql: 100.00 * ${TABLE}.opening_margin

  - measure: percent_of_total_sales_opportunity
    description: "Percentage of sales opportunity compared to total"
    label: "% of Sales Opportunity"
    type: percent_of_total
    value_format: '0.00\%'
    sql: ${total_sales_opportunity}

  - measure: skus_reserved
    hidden: true
    type: sum
    sql: CASE WHEN ${TABLE}.quantity_reserved > 0 THEN 1 END

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

  - measure: quantity_returned_last_180_days
    description: "Quantity returned during the last 180 days"
    type: sum
    sql: ${TABLE}.quantity_returned_last_180_days

  - measure: quantity_sold_last_180_days
    description: "Quantity sold during the last 180 days"
    type: sum
    sql: ${TABLE}.quantity_sold_last_180_days

  - measure: net_sold_quantity_all_time
    description: "Total quantity sold minus the total quantity returned (all-time)"
    type: number
    sql: ${quantity_sold_all_time} - ${quantity_returned_all_time}

  - measure: net_sold_quantity_last_180_days
    description: "Total quantity sold minus the total quantity returned (last 180 days), used for calculating sell through rate"
    type: number
    sql: ${quantity_sold_last_180_days} - ${quantity_returned_last_180_days}

  - measure: average_quantity_sold_per_day
    description: "Quantity of units sold per day based on 30-day sales history"
    type: number
    value_format_name: decimal_2
    sql: ${quantity_sold_last_30_days} / 30.0

  - measure: days_of_inventory_calculation
    type: number
    hidden: true
    sql: ${quantity_available_to_sell} / NULLIF((${quantity_sold_last_30_days} / 30.0),0)

  - measure: days_of_inventory_remaining
    label: "Days of Inventory Remaining (for 30-day rolling sales)"
    description: "Based on 30-day sales history, the number of days that will elapse before we run out of inventory"
    type: number
    value_format: "0"
    sql: |
      CASE WHEN ${quantity_available_to_sell} > 0 AND ${days_of_inventory_calculation} IS NULL THEN 9999 ELSE ${days_of_inventory_calculation} END

  - measure: sell_through_rate
    label: "Sell Through %"
    description: "Net sold quantity divided by (quantity on hand plus net sold quantity) for the last 180 days"
    type: number
    value_format: '0\%'
    sql: 100.00 * ((${quantity_sold_last_180_days} - ${quantity_returned_last_180_days}) / NULLIF(${quantity_available_to_sell} + (${quantity_sold_last_180_days} - ${quantity_returned_last_180_days}),0))

  - measure: quantity_available_to_sell
    description: "Quantity on hand minus quantity reserved for orders that haven't shipped"
    type: number
    sql: ${quantity_on_hand} - ${quantity_reserved}
    drill_fields: [inventory_facts*]

  - measure: is_in_stock_or_created_within_last_year
    description: "Will return SKUs that are either in stock, or have been added to Magento within the last 3 years. This is used to produce an item master for NRI."
    type: yesno
    sql: SUM(${TABLE}.quantity_on_hand) > 0 OR DATEDIFF(d,${products.created_at_time},GETDATE()) < 365

  - measure: skus_available_to_sell
    label: "SKUs Available to Sell"
    description: "Unique count of SKUs / simple products that we have available for sale"
    type: number
    sql: ${skus_on_hand} - ${skus_reserved}
    
#  - measure: return_rate
#    description: "Percentage of units sold that were returned (warning: this measure seems to return results that are suspiciously low)"
#    type: number
#    value_format: '0%'
#    sql: ${quantity_returned_all_time} / NULLIF(CAST(${quantity_sold_all_time} AS float),0)

  sets:
    inventory_facts:
      - products.budget_type
      - products.department
      - categories.category_1
      - products.brand
      - total_sales_opportunity
      - percent_of_total_sales_opportunity
      - sell_through_rate
      - quantity_on_hand
      - quantity_sold_last_180_days
      - quantity_returned_last_180_days
      - net_sold_quantity_last_180_days
      - days_of_inventory_remaining