view: catalog_product_bucketed_sellthrough {

  # Current buckets:
  # 1: 2017-01-01 to present
  # 2: 2016-07-01 to 2017-01-01
  # 3: 2016-01-03 to 2016-07-01

  derived_table: {
    sql: SELECT a.product_id AS product_id
        , CASE WHEN SUM(qty) < 0 THEN 0 ELSE SUM(qty) END AS quantity_on_hand

        , MAX(inventory_history_bucket1.quantity_on_hand) AS quantity_on_hand_bucket1
        , MAX(returns_since_bucket1.quantity_returned) AS quantity_returned_since_bucket1
        , MAX(sales_since_bucket1.quantity_sold) AS quantity_sold_since_bucket1
        , MAX(receipts_since_bucket1.quantity_received) AS quantity_received_since_bucket1
        , MAX(inventory_history_bucket1.quantity_on_hand) * MAX(catalog_product.price) AS sales_opportunity_bucket1

        , MAX(inventory_history_bucket2.quantity_on_hand) AS quantity_on_hand_bucket2
        , MAX(returns_since_bucket2.quantity_returned) AS quantity_returned_since_bucket2
        , MAX(sales_since_bucket2.quantity_sold) AS quantity_sold_since_bucket2
        , MAX(receipts_since_bucket2.quantity_received) AS quantity_received_since_bucket2
        , MAX(inventory_history_bucket2.quantity_on_hand) * MAX(catalog_product.price) AS sales_opportunity_bucket2

        , MAX(inventory_history_bucket3.quantity_on_hand) AS quantity_on_hand_bucket3
        , MAX(returns_since_bucket3.quantity_returned) AS quantity_returned_since_bucket3
        , MAX(sales_since_bucket3.quantity_sold) AS quantity_sold_since_bucket3
        , MAX(receipts_since_bucket3.quantity_received) AS quantity_received_since_bucket3
        , MAX(inventory_history_bucket3.quantity_on_hand) * MAX(catalog_product.price) AS sales_opportunity_bucket3

      FROM magento.cataloginventory_stock_item AS a

      LEFT JOIN (
        SELECT
          products.entity_id,
          COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(inventory_history.quantity,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS quantity_on_hand
        FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
        LEFT JOIN ${catalog_product_inventory_history.SQL_TABLE_NAME} AS inventory_history ON products.entity_id = inventory_history.product_id
        WHERE
          (((inventory_history.sm_date) >= ((CONVERT(DATETIME,'2017-01-01', 120))) AND (inventory_history.sm_date) < ((DATEADD(day,1, CONVERT(DATETIME,'2017-01-01', 120) )))))
        GROUP BY products.entity_id
      ) AS inventory_history_bucket1
      ON a.product_id = inventory_history_bucket1.entity_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_received
        FROM magento.stock_movement
        WHERE sm_date >= '2017-01-01'
        AND (sm_type = 'supply')
        GROUP BY sm_product_id
      ) AS receipts_since_bucket1
      ON a.product_id = receipts_since_bucket1.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold
        FROM magento.stock_movement
        WHERE sm_date >= '2017-01-01'
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_since_bucket1
      ON a.product_id = sales_since_bucket1.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_returned
        FROM magento.stock_movement
        WHERE sm_date >= '2017-01-01'
        AND sm_type = 'adjustment' AND sm_target_stock = 1 AND sm_description = 'Manual adjustment (drew.gillson)'
        -- "Manual adjustment (drew.gillson)" is the stock movement description that gets logged when I import stock movements after syncing with NRI
        GROUP BY sm_product_id
      ) AS returns_since_bucket1
      ON a.product_id = returns_since_bucket1.product_id

      LEFT JOIN (
        SELECT
          products.entity_id,
          COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(inventory_history.quantity,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS quantity_on_hand
        FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
        LEFT JOIN ${catalog_product_inventory_history.SQL_TABLE_NAME} AS inventory_history ON products.entity_id = inventory_history.product_id
        WHERE
          (((inventory_history.sm_date) >= ((CONVERT(DATETIME,'2016-07-01', 120))) AND (inventory_history.sm_date) < ((DATEADD(day,1, CONVERT(DATETIME,'2016-07-01', 120) )))))
        GROUP BY products.entity_id
      ) AS inventory_history_bucket2
      ON a.product_id = inventory_history_bucket2.entity_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_received
        FROM magento.stock_movement
        WHERE sm_date >= '2016-07-01' AND sm_date < '2017-01-01'
        AND (sm_type = 'supply')
        GROUP BY sm_product_id
      ) AS receipts_since_bucket2
      ON a.product_id = receipts_since_bucket2.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold
        FROM magento.stock_movement
        WHERE sm_date >= '2016-07-01' AND sm_date < '2017-01-01'
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_since_bucket2
      ON a.product_id = sales_since_bucket2.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_returned
        FROM magento.stock_movement
        WHERE sm_date >= '2016-07-01' AND sm_date < '2017-01-01'
        AND sm_type = 'adjustment' AND sm_target_stock = 1 AND sm_description = 'Manual adjustment (drew.gillson)'
        GROUP BY sm_product_id
      ) AS returns_since_bucket2
      ON a.product_id = returns_since_bucket2.product_id

      LEFT JOIN (
        SELECT
          products.entity_id,
          COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(inventory_history.quantity,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120))),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS quantity_on_hand
        FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
        LEFT JOIN ${catalog_product_inventory_history.SQL_TABLE_NAME} AS inventory_history ON products.entity_id = inventory_history.product_id
        WHERE
          (((inventory_history.sm_date) >= ((CONVERT(DATETIME,'2016-01-03', 120))) AND (inventory_history.sm_date) < ((DATEADD(day,1, CONVERT(DATETIME,'2016-01-03', 120) )))))
        GROUP BY products.entity_id
      ) AS inventory_history_bucket3
      ON a.product_id = inventory_history_bucket3.entity_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_received
        FROM magento.stock_movement
        WHERE sm_date >= '2016-01-03' AND sm_date < '2016-07-01'
        AND (sm_type = 'supply')
        GROUP BY sm_product_id
      ) AS receipts_since_bucket3
      ON a.product_id = receipts_since_bucket3.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_sold
        FROM magento.stock_movement
        WHERE sm_date >= '2016-01-03' AND sm_date < '2016-07-01'
        AND (sm_type = 'order' OR (sm_type = 'transfer' AND sm_description LIKE '%van order%'))
        GROUP BY sm_product_id
      ) AS sales_since_bucket3
      ON a.product_id = sales_since_bucket3.product_id

      LEFT JOIN (
        SELECT sm_product_id AS product_id
             , SUM(sm_qty) AS quantity_returned
        FROM magento.stock_movement
        WHERE sm_date >= '2016-01-03' AND sm_date < '2016-07-01'
        AND sm_type = 'adjustment' AND sm_target_stock = 1 AND sm_description = 'Manual adjustment (drew.gillson)'
        GROUP BY sm_product_id
      ) AS returns_since_bucket3
      ON a.product_id = returns_since_bucket3.product_id

      LEFT JOIN ${catalog_product.SQL_TABLE_NAME} AS catalog_product
      ON a.product_id = catalog_product.entity_id

      GROUP BY a.product_id
       ;;
    indexes: ["product_id"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: product_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  measure: quantity_on_hand {
    type: sum
    sql: ${TABLE}.quantity_on_hand ;;
  }

  measure: quantity_on_hand_bucket1 {
    type: sum
    sql: ${TABLE}.quantity_on_hand_bucket1 ;;
  }

  measure: quantity_sold_since_bucket1 {
    type: sum
    sql: ${TABLE}.quantity_sold_since_bucket1 ;;
  }

  measure: quantity_received_since_bucket1 {
    type: sum
    sql: ${TABLE}.quantity_received_since_bucket1 ;;
  }

  measure: quantity_returned_since_bucket1 {
    type: sum
    sql: ${TABLE}.quantity_returned_since_bucket1 ;;
  }

  measure: net_sold_quantity_since_bucket1 {
    type: number
    sql: ${quantity_sold_since_bucket1} - ${quantity_returned_since_bucket1} ;;
  }

  measure: sell_through_rate_bucket_1 {
    label: "% (Bucket 1)"
    type: number
    value_format: "0\%"
    sql: 100.00 * ((${net_sold_quantity_since_bucket1}) / NULLIF(CAST(${quantity_on_hand_bucket1} AS float) + (${quantity_received_since_bucket1}),0)) ;;
  }

  measure: sales_opportunity_bucket1 {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.sales_opportunity_bucket1 ;;
  }

  measure: quantity_on_hand_bucket2 {
    type: sum
    sql: ${TABLE}.quantity_on_hand_bucket2 ;;
  }

  measure: quantity_sold_since_bucket2 {
    type: sum
    sql: ${TABLE}.quantity_sold_since_bucket2 ;;
  }

  measure: quantity_received_since_bucket2 {
    type: sum
    sql: ${TABLE}.quantity_received_since_bucket2 ;;
  }

  measure: quantity_returned_since_bucket2 {
    type: sum
    sql: ${TABLE}.quantity_returned_since_bucket2 ;;
  }

  measure: net_sold_quantity_since_bucket2 {
    type: number
    sql: ${quantity_sold_since_bucket2} - ${quantity_returned_since_bucket2} ;;
  }

  measure: sell_through_rate_bucket_2 {
    label: "% (Bucket 2)"
    type: number
    value_format: "0\%"
    sql: 100.00 * ((${net_sold_quantity_since_bucket2}) / NULLIF(CAST(${quantity_on_hand_bucket2} AS float) + (${quantity_received_since_bucket2}),0)) ;;
  }

  measure: sales_opportunity_bucket2 {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.sales_opportunity_bucket2 ;;
  }

  measure: quantity_on_hand_bucket3 {
    type: sum
    sql: ${TABLE}.quantity_on_hand_bucket3 ;;
  }

  measure: quantity_sold_since_bucket3 {
    type: sum
    sql: ${TABLE}.quantity_sold_since_bucket3 ;;
  }

  measure: quantity_received_since_bucket3 {
    type: sum
    sql: ${TABLE}.quantity_received_since_bucket3 ;;
  }

  measure: quantity_returned_since_bucket3 {
    type: sum
    sql: ${TABLE}.quantity_returned_since_bucket3 ;;
  }

  measure: net_sold_quantity_since_bucket3 {
    type: number
    sql: ${quantity_sold_since_bucket3} - ${quantity_returned_since_bucket3} ;;
  }

  measure: sell_through_rate_bucket_3 {
    label: "% (Bucket 3)"
    type: number
    value_format: "0\%"
    sql: 100.00 * ((${net_sold_quantity_since_bucket3}) / NULLIF(CAST(${quantity_on_hand_bucket3} AS float) + (${quantity_received_since_bucket3}),0)) ;;
  }

  measure: sales_opportunity_bucket3 {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.sales_opportunity_bucket3 ;;
  }
}
