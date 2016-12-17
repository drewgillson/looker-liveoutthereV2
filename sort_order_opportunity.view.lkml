view: sort_order_opportunity {
  derived_table: {
    sql: SELECT x.*, ROW_NUMBER() OVER (ORDER BY opportunity DESC) AS score FROM (SELECT
        associations.parent_sku  AS configurable_sku,
        COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(product_facts.total_sales_opportunity ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), product_facts.product_id )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS opportunity
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
    sql: ${TABLE}.configurable_sku ;;
  }

  dimension:  opportunity_score {
    type: number
    sql: ${TABLE}.score ;;
    value_format: "0"
  }

  measure: opportunity {
    type: sum
    sql: ${TABLE}.opportunity ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  # Use ISNULL to assign a default score to null values, this puts products that we don't have information about somewhere up near the top - but not at the top!
  dimension: weighted_score_default {
    description: "Anshuman's default sort order with weights as described in LOT Sort Order - Algo Description"
    type: number
    sql: (ISNULL(${page_views.score},5000) * 0.10) +
         (ISNULL(${conversion_rate.score},5000) * 0.30) +
         (ISNULL(${sort_order.opportunity_score},5000) * 0.20) +
         (ISNULL(${price.score},5000) * 0.10) +
         (ISNULL(${days_since_last_receipt.score},5000) * 0.10) +
         (ISNULL(${quantity.score},5000) * 0.10) +
         (ISNULL(${reviews.score},5000) * 0.10);;
    value_format: "0"
  }

  dimension: weighted_score_alt_1 {
    description: "An example alternate sort order heavily weighted towards the Sales Opportunity $ rank/score"
    type: number
    sql: (ISNULL(${conversion_rate.score},1000) * 0.20) +
         (ISNULL(${sort_order.opportunity_score},100) * 0.65) +
         (ISNULL(${days_since_last_receipt.score},100) * 0.15);;
    value_format: "0"
  }

  dimension: weighted_score_alt_2 {
    description: "Another example sort order heavily weighted towards the conversion rate rank, but also factoring in days since last receipt"
    type: number
    sql: (ISNULL(${conversion_rate.score},1000) * 0.75) +
         (ISNULL(${days_since_last_receipt.score},100) * 0.25);;
    value_format: "0"
  }

}