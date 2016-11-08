view: sort_order_quantity {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY quantity DESC) AS score FROM (SELECT
      associations.parent_sku  AS configurable_sku,
      (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(product_facts.quantity_on_hand ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0)) - (COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(product_facts.quantity_reserved ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0))  AS quantity
    FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
    LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
    LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
    WHERE
      NOT(products.brand = 'LiveOutThere.com' )
    GROUP BY associations.parent_sku) AS x;;
    indexes: ["configurable_sku"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date);;
  }

  dimension: configurable_sku {
    type: string
    hidden: yes
    sql: ${TABLE}.configurable_sku ;;
  }

  dimension:  score {
    type: number
    sql: ${TABLE}.score ;;
    value_format: "0"
  }

  measure: quantity {
    type: sum
    sql: ${TABLE}.quantity ;;
    value_format: "0"
  }
}
