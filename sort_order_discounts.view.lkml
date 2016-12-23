view: sort_order_discounts {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY discount_value DESC) AS score FROM (SELECT
            associations.parent_sku  AS configurable_sku,
            (COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(effective_discounts.discount ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), effective_discounts.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), effective_discounts.row )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), effective_discounts.row )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), effective_discounts.row )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0) / NULLIF(COUNT(DISTINCT CASE WHEN  effective_discounts.discount  IS NOT NULL THEN effective_discounts.row  ELSE NULL END), 0)) AS discount_value
          FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
          LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS associations ON products.entity_id = associations.product_id
          LEFT JOIN ${catalog_effective_discounts.SQL_TABLE_NAME} AS effective_discounts ON products.entity_id = effective_discounts.entity_id
          WHERE
            (effective_discounts.environment = 'Production')
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

  measure: discount_value {
    type: sum
    sql: ${TABLE}.discount_value ;;
    value_format: "0%"
  }
}
