- view: catalog_product_facts_weekly_sellthrough
  derived_table:
    sql: |
      SELECT a.product_id AS product_id
      
        , MAX(quantity_5_weeks_ago) AS quantity_on_hand_5_weeks_ago
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_5_weeks_ago) - ABS(SUM(qty)) ELSE MAX(quantity_sold_5_weeks_ago) END AS quantity_sold_5_weeks_ago
        , MAX(returns_5_weeks_ago) AS quantity_returned_5_weeks_ago

        , MAX(quantity_4_weeks_ago) AS quantity_on_hand_4_weeks_ago
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_4_weeks_ago) - ABS(SUM(qty)) ELSE MAX(quantity_sold_4_weeks_ago) END AS quantity_sold_4_weeks_ago
        , MAX(returns_4_weeks_ago) AS quantity_returned_4_weeks_ago

        , MAX(quantity_3_weeks_ago) AS quantity_on_hand_3_weeks_ago
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_3_weeks_ago) - ABS(SUM(qty)) ELSE MAX(quantity_sold_3_weeks_ago) END AS quantity_sold_3_weeks_ago
        , MAX(returns_3_weeks_ago) AS quantity_returned_3_weeks_ago

        , MAX(quantity_2_weeks_ago) AS quantity_on_hand_2_weeks_ago
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_2_weeks_ago) - ABS(SUM(qty)) ELSE MAX(quantity_sold_2_weeks_ago) END AS quantity_sold_2_weeks_ago
        , MAX(returns_2_weeks_ago) AS quantity_returned_2_weeks_ago

        , MAX(quantity_1_week_ago) AS quantity_on_hand_1_week_ago
        , CASE WHEN SUM(qty) < 0 THEN MAX(quantity_sold_1_week_ago) - ABS(SUM(qty)) ELSE MAX(quantity_sold_1_week_ago) END AS quantity_sold_1_week_ago
        , MAX(returns_1_week_ago) AS quantity_returned_1_week_ago

      FROM magento.cataloginventory_stock_item AS a
      
      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END) AS quantity_5_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-28,GETDATE())
        AND ((sm_type != 'transfer' OR (
            sm_type = 'transfer' AND (
              (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
            )
          )
        ))
        GROUP BY sm_product_id
      ) AS quantity_5_weeks_ago
      ON a.product_id = quantity_5_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_5_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-28,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_5_weeks_ago
      ON a.product_id = sales_5_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS returns_5_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-28,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'transfer' OR sm_type = 'return') AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_5_weeks_ago
      ON a.product_id = returns_5_weeks_ago.product_id
      
      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END) AS quantity_4_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-21,GETDATE())
        AND ((sm_type != 'transfer' OR (
            sm_type = 'transfer' AND (
              (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
            )
          )
        ))
        GROUP BY sm_product_id
      ) AS quantity_4_weeks_ago
      ON a.product_id = quantity_4_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_4_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-21,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_4_weeks_ago
      ON a.product_id = sales_4_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS returns_4_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-21,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'transfer' OR sm_type = 'return') AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_4_weeks_ago
      ON a.product_id = returns_4_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END) AS quantity_3_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-14,GETDATE())
        AND ((sm_type != 'transfer' OR (
            sm_type = 'transfer' AND (
              (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
            )
          )
        ))
        GROUP BY sm_product_id
      ) AS quantity_3_weeks_ago
      ON a.product_id = quantity_3_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_3_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-14,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_3_weeks_ago
      ON a.product_id = sales_3_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS returns_3_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-14,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'transfer' OR sm_type = 'return') AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_3_weeks_ago
      ON a.product_id = returns_3_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END) AS quantity_2_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-7,GETDATE())
        AND ((sm_type != 'transfer' OR (
            sm_type = 'transfer' AND (
              (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
            )
          )
        ))
        GROUP BY sm_product_id
      ) AS quantity_2_weeks_ago
      ON a.product_id = quantity_2_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_2_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-7,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_2_weeks_ago
      ON a.product_id = sales_2_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS returns_2_weeks_ago
        FROM magento.stock_movement
        WHERE sm_date <= DATEADD(d,-7,GETDATE()) AND sm_date > DATEADD(d,-180,GETDATE())
        AND (sm_type = 'transfer' OR sm_type = 'return') AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_2_weeks_ago
      ON a.product_id = returns_2_weeks_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END) AS quantity_1_week_ago
        FROM magento.stock_movement
        WHERE ((sm_type != 'transfer' OR (
            sm_type = 'transfer' AND (
              (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
            )
          )
        ))
        GROUP BY sm_product_id
      ) AS quantity_1_week_ago
      ON a.product_id = quantity_1_week_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold_1_week_ago
        FROM magento.stock_movement
        WHERE sm_date > DATEADD(d,-180,GETDATE()) AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_1_week_ago
      ON a.product_id = sales_1_week_ago.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS returns_1_week_ago
        FROM magento.stock_movement
        WHERE sm_date > DATEADD(d,-180,GETDATE()) AND (sm_type = 'transfer' OR sm_type = 'return') AND sm_target_stock = 1 AND sm_description LIKE '%return%'
        GROUP BY sm_product_id
      ) AS returns_1_week_ago
      ON a.product_id = returns_1_week_ago.product_id
      
      GROUP BY a.product_id
    indexes: [product_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: product_id
    type: number
    primary_key: true
    hidden: true
    sql: ${TABLE}.product_id

  - measure: quantity_on_hand_5_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_on_hand_5_weeks_ago

  - measure: quantity_returned_5_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_returned_5_weeks_ago

  - measure: quantity_sold_5_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_sold_5_weeks_ago

  - measure: net_sold_quantity_5_weeks_ago
    hidden: true
    type: number
    sql: ${quantity_sold_5_weeks_ago} - ${quantity_returned_5_weeks_ago}

  - measure: quantity_on_hand_4_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_on_hand_4_weeks_ago

  - measure: quantity_returned_4_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_returned_4_weeks_ago

  - measure: quantity_sold_4_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_sold_4_weeks_ago

  - measure: net_sold_quantity_4_weeks_ago
    hidden: true
    type: number
    sql: ${quantity_sold_4_weeks_ago} - ${quantity_returned_4_weeks_ago}

  - measure: quantity_on_hand_3_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_on_hand_3_weeks_ago

  - measure: quantity_returned_3_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_returned_3_weeks_ago

  - measure: quantity_sold_3_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_sold_3_weeks_ago

  - measure: net_sold_quantity_3_weeks_ago
    hidden: true
    type: number
    sql: ${quantity_sold_3_weeks_ago} - ${quantity_returned_3_weeks_ago}

  - measure: quantity_on_hand_2_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_on_hand_2_weeks_ago

  - measure: quantity_returned_2_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_returned_2_weeks_ago

  - measure: quantity_sold_2_weeks_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_sold_2_weeks_ago

  - measure: net_sold_quantity_2_weeks_ago
    hidden: true
    type: number
    sql: ${quantity_sold_2_weeks_ago} - ${quantity_returned_2_weeks_ago}

  - measure: quantity_on_hand_1_week_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_on_hand_1_week_ago

  - measure: quantity_returned_1_week_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_returned_1_week_ago

  - measure: quantity_sold_1_week_ago
    type: sum
    hidden: true
    sql: ${TABLE}.quantity_sold_1_week_ago

  - measure: net_sold_quantity_1_week_ago
    hidden: true
    type: number
    sql: ${quantity_sold_1_week_ago} - ${quantity_returned_1_week_ago}

  - measure: sell_through_rate_1_week_ago
    label: "Current %"
    description: "Sell through rate as of today"
    type: number
    value_format: '0\%'
    sql: 100.00 * (${net_sold_quantity_1_week_ago} / NULLIF(${quantity_on_hand_1_week_ago} + ${net_sold_quantity_1_week_ago},0))

  - measure: sell_through_rate_2_weeks_ago
    label: "7 Days Ago %"
    description: "Sell through rate as of 7 days ago"
    type: number
    value_format: '0\%'
    sql: 100.00 * (${net_sold_quantity_2_weeks_ago} / NULLIF(${quantity_on_hand_2_weeks_ago} + ${net_sold_quantity_2_weeks_ago},0))

  - measure: sell_through_rate_3_weeks_ago
    label: "14 Days Ago %"
    description: "Sell through rate as of 14 days ago"
    type: number
    value_format: '0\%'
    sql: 100.00 * (${net_sold_quantity_3_weeks_ago} / NULLIF(${quantity_on_hand_3_weeks_ago} + ${net_sold_quantity_3_weeks_ago},0))
    
  - measure: sell_through_rate_4_weeks_ago
    label: "21 Days Ago %"
    description: "Sell through rate as of 21 days ago"
    type: number
    value_format: '0\%'
    sql: 100.00 * (${net_sold_quantity_4_weeks_ago} / NULLIF(${quantity_on_hand_4_weeks_ago} + ${net_sold_quantity_4_weeks_ago},0))

  - measure: sell_through_rate_5_weeks_ago
    label: "28 Days Ago %"
    description: "Sell through rate as of 28 days ago"
    type: number
    value_format: '0\%'
    sql: 100.00 * (${net_sold_quantity_5_weeks_ago} / NULLIF(${quantity_on_hand_5_weeks_ago} + ${net_sold_quantity_5_weeks_ago},0))

  - measure: sell_through_rate_1_week_ago_not_cumulative
    label: "Period 0-7 Days Ago %"
    description: "Sell through rate in last 7 days"
    type: number
    value_format: '0\%'
    sql: ${sell_through_rate_1_week_ago} - ${sell_through_rate_2_weeks_ago}

  - measure: sell_through_rate_2_weeks_ago_not_cumulative
    label: "Period 7-14 Days Ago %"
    description: "Sell through rate 7 to 14 days ago"
    type: number
    value_format: '0\%'
    sql: ${sell_through_rate_2_weeks_ago} - ${sell_through_rate_3_weeks_ago}

  - measure: sell_through_rate_3_weeks_ago_not_cumulative
    label: "Period 14-21 Days Ago %"
    description: "Sell through rate 14 to 21 days ago"
    type: number
    value_format: '0\%'
    sql: ${sell_through_rate_3_weeks_ago} - ${sell_through_rate_4_weeks_ago}

  - measure: sell_through_rate_4_weeks_ago_not_cumulative
    label: "Period 21-28 Days Ago %"
    description: "Sell through rate 21 to 28 days ago"
    type: number
    value_format: '0\%'
    sql: ${sell_through_rate_4_weeks_ago} - ${sell_through_rate_5_weeks_ago}

  - measure: net_sold_quantity_1_week_ago_visible
    label: "0-7 Days Ago #"
    description: "Net sold units in the last 7 days ago"
    type: number
    value_format: "#,##0"
    sql: ${net_sold_quantity_1_week_ago} - ${net_sold_quantity_2_weeks_ago}
    
  - measure: net_sold_quantity_2_weeks_ago_visible
    label: "7-14 Days Ago #"
    description: "Net sold units in the period 7 to 14 days ago"
    type: number
    value_format: "#,##0"
    sql: ${net_sold_quantity_2_weeks_ago} - ${net_sold_quantity_3_weeks_ago}

  - measure: net_sold_quantity_3_weeks_ago_visible
    label: "14-21 Days Ago #"
    description: "Net sold units in the period 14 to 21 days ago"
    type: number
    value_format: "#,##0"
    sql: ${net_sold_quantity_3_weeks_ago} - ${net_sold_quantity_4_weeks_ago}

  - measure: net_sold_quantity_4_weeks_ago_visible
    label: "21-28 Days Ago #"
    description: "Net sold units in the period 21 to 28 days ago"
    type: number
    value_format: "#,##0"
    sql: ${net_sold_quantity_4_weeks_ago} - ${net_sold_quantity_5_weeks_ago}