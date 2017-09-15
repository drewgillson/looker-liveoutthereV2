view: catalog_product_inventory_history {
  suggestions: no

  derived_table: {
    sql: SELECT * FROM (
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
         , ISNULL(ROUND(AVG((pop_price_ht * (1-(CASE WHEN pop_discount > 0 THEN pop_discount ELSE 0 END / 100)))), 2), AVG(cost.value)) AS avg_cost
         , ISNULL(SUM(pop_price_ht * (1-(CASE WHEN pop_discount > 0 THEN pop_discount ELSE 0 END / 100)) * pop_qty) / NULLIF(SUM(pop_qty),0), AVG(cost.value)) AS weighted_avg_cost
      FROM magento.stock_movement AS sm
      LEFT JOIN magento.catalog_product_entity AS e
        ON sm.sm_product_id = e.entity_id
      INNER JOIN (
        SELECT DISTINCT CAST(DateFull AS date) AS sm_date
        FROM lut_Date
        WHERE DateFull >= '2016-02-01' AND DateFull <= GETDATE() AND (DATEPART(dd,DateFull) = 1 OR DATEPART(dw,DateFull) = 1)
      ) AS dates
        ON sm.sm_date <= dates.sm_date
      LEFT JOIN magento.purchase_order_product AS pop
        ON sm.sm_product_id = pop.pop_product_id
      INNER JOIN magento.purchase_order AS po
        ON pop.pop_order_num = po.po_num AND po.po_arrival_date <= dates.sm_date
      LEFT JOIN magento.catalog_product_entity_decimal AS cost
        ON sm.sm_product_id = cost.entity_id AND cost.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'cost' AND entity_type_id = 4)
      WHERE ((sm_type != 'transfer' OR (
          sm_type = 'transfer' AND (
            (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
          )
        )
      ))
      AND e.type_id = 'simple'
      AND ((pop_price_ht <> 0 AND pop_discount <> 100) OR pop_price_ht IS NULL)
      GROUP BY dates.sm_date, sm_product_id

      UNION ALL

      -- Consider inventory that was never received against a purchase order but was in-stock anyways
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
         , AVG(cost.value) AS avg_cost
         , AVG(cost.value) AS weighted_avg_cost
      FROM magento.stock_movement AS sm
      LEFT JOIN magento.catalog_product_entity AS e
        ON sm.sm_product_id = e.entity_id
      INNER JOIN (
        SELECT DISTINCT CAST(DateFull AS date) AS sm_date
        FROM lut_Date
        WHERE DateFull = '2016-02-01'
      ) AS dates
        ON sm.sm_date <= dates.sm_date
      LEFT JOIN magento.purchase_order_product AS pop
        ON sm.sm_product_id = pop.pop_product_id
      LEFT JOIN magento.purchase_order AS po
        ON pop.pop_order_num = po.po_num AND po.po_arrival_date <= dates.sm_date
      LEFT JOIN magento.catalog_product_entity_decimal AS cost
        ON sm.sm_product_id = cost.entity_id AND cost.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'cost' AND entity_type_id = 4)
      WHERE
      e.type_id = 'simple' AND
      ((sm_type != 'transfer' OR (
            sm_type = 'transfer' AND (
              (sm_source_stock = 0 OR sm_target_stock = 0) AND NOT (sm_source_stock = 0 AND sm_target_stock = 0)
            )
          )
        ))
      AND po.po_num IS NULL AND pop_order_num IS NULL
      GROUP BY dates.sm_date, sm_product_id
      HAVING COALESCE(COALESCE(        (
                  SUM(DISTINCT
                    (CAST(FLOOR(COALESCE(CASE WHEN sm_target_stock = 0 THEN -sm_qty ELSE sm_qty END,0)*(1000000*1.0)) AS DECIMAL(38,0))) +
                    CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),1,8) )) AS DECIMAL(38,0))
                  )
                  -
                   SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR, sm.sm_id)),1,8) )) AS DECIMAL(38,0)))
                )/(1000000*1.0)
           ,0),0) > 0
    ) AS x
    WHERE quantity > 0
    ;;
    indexes: ["sm_date", "product_id"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: key {
    type: string
    primary_key: yes
    hidden: yes
    sql: CAST(${TABLE}.product_id AS varchar(20)) + CONVERT(VARCHAR, ${TABLE}.sm_date, 120) ;;
  }

  dimension_group: inventory_balance {
    description: "Date of inventory balance record"
    type: time
    sql: ${TABLE}.sm_date ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  measure: quantity_on_hand {
    description: "Quantity on hand / in stock for inventory balance date"
    type: sum
    sql: ${TABLE}.quantity ;;
  }

  measure: extended_cost {
    label: "Ext. Average Cost $"
    description: "Extended (discounted) cost of inventory, using average cost of product as of inventory balance date"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.quantity * ${TABLE}.avg_cost ;;
  }

  measure: extended_weighted_avg_cost {
    label: "Ext. Weighted Average Cost $"
    description: "Extended (discounted) cost of inventory, using weighted average cost of product as of inventory balance date"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.quantity * ${TABLE}.weighted_avg_cost ;;
  }

  measure: extended_retail {
    label: "Ext. Retail $"
    description: "Extended retail value of inventory (calculated using most recent MSRP $)"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.quantity * ${products.price} ;;
  }
}
