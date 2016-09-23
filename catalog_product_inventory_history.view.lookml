- view: catalog_product_inventory_history
  suggestions: false
  derived_table:
    sql: |
      SELECT dates.sm_date
         , sm_product_id AS product_id
         , COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
           ,0),0) AS quantity
         , ROUND(AVG((pop_price_ht * (1-(CASE WHEN pop_discount > 0 THEN pop_discount ELSE 0 END / 100)))), 2) AS avg_cost
      FROM magento.stock_movement AS sm
      LEFT JOIN (
        SELECT DISTINCT CAST(DateFull AS date) AS sm_date
        FROM lut_Date
        WHERE DateFull >= '2012-02-01' AND DateFull <= GETDATE() AND (DATEPART(dd,DateFull) = 1 OR DATEPART(dw,DateFull) = 1)
      ) AS dates
        ON sm.sm_date <= dates.sm_date
      LEFT JOIN magento.purchase_order_product AS pop
        ON sm.sm_product_id = pop.pop_product_id
      LEFT JOIN magento.purchase_order AS po
        ON pop.pop_order_num = po.po_num AND po.po_arrival_date <= dates.sm_date
      WHERE ((sm_type != 'transfer' OR (
          sm_type = 'transfer' AND (
            (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
          )
        )
      ))
      AND pop_price_ht <> 0
      AND pop_supplied_qty > 0
      AND pop_discount <> 100
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
    
  - measure: extended_cost
    label: "Ext. Cost $"
    description: "Extended (discounted) cost of inventory, using average cost of product as of inventory balance date"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.quantity * ${TABLE}.avg_cost
    
  - measure: extended_retail
    label: "Ext. Retail $"
    description: "Extended retail value of inventory (calculated using most recent MSRP $)"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.quantity * ${products.price}