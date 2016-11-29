view: plan_weekly_inventory {
  derived_table: {
    sql: SELECT
        products.parent_id AS parent_id,
        DATEADD(ww,1,CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),DATEADD(day,(0 - (((DATEPART(dw,inventory_history.sm_date ) - 1) - 1 + 7) % (7))), inventory_history.sm_date  ),120), 120)) AS inventory_balance,
        products.budget_type AS budget_type,
        products.department AS department,
        products.brand AS brand,
        products.product AS product_name,
        categories.reporting_category_level1 AS category_1,
        categories.reporting_category_level2 AS category_2,
        COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(inventory_history.quantity ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS quantity_on_hand,
        COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(inventory_history.quantity * inventory_history.avg_cost ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS extended_cost,
        COALESCE(COALESCE( ( SUM(DISTINCT (CAST(FLOOR(COALESCE(inventory_history.quantity * products.price ,0)*(1000000*1.0)) AS DECIMAL(38,0))) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),1,8) )) AS DECIMAL(38,0)) ) - SUM(DISTINCT CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),9,8) )) AS DECIMAL(38,0)) * CAST(1.0e8 AS DECIMAL(38,9)) + CAST(ABS(CONVERT(BIGINT, SUBSTRING(HashBytes('MD5',CONVERT(VARCHAR(64), CAST(inventory_history.product_id AS varchar(20)) + CONVERT(VARCHAR, inventory_history.sm_date, 120) )),1,8) )) AS DECIMAL(38,0))) )  / (1000000*1.0), 0), 0) AS extended_retail
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_inventory_history.SQL_TABLE_NAME} AS inventory_history ON products.entity_id = inventory_history.product_id
      LEFT JOIN ${catalog_categories.SQL_TABLE_NAME} AS categories ON products.entity_id = categories.product_id

      WHERE ((inventory_history.sm_date  >= CONVERT(DATETIME,'2015-01-01', 120))) AND ((((DATEPART(dw,inventory_history.sm_date ) - 1) - 1 + 7) % (7)) = 6)
      AND (categories.sequence = 1)
      GROUP BY products.parent_id ,DATEADD(ww,1,CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),DATEADD(day,(0 - (((DATEPART(dw,inventory_history.sm_date ) - 1) - 1 + 7) % (7))), inventory_history.sm_date  ),120), 120)),products.budget_type ,products.department ,products.brand ,products.product ,categories.reporting_category_level1 ,categories.reporting_category_level2;;
    indexes: ["parent_id", "budget_type", "brand", "department", "category_1"]
    sql_trigger_value: SELECT DATEADD(ww,1,CONVERT(VARCHAR(10), CONVERT(VARCHAR(10),DATEADD(day,(0 - (((DATEPART(dw,GETDATE() ) - 1) - 1 + 7) % (7))), GETDATE()  ),120), 120))
      ;;
  }

  dimension: parent_id {
    primary_key: yes
    hidden: yes
  }

  dimension_group: inventory_balance {
    type: time
    timeframes: [week, week_of_year, year]
    sql: ${TABLE}.inventory_balance ;;
  }

  dimension: budget_type {
    type: string
    sql: ${TABLE}.budget_type ;;
    drill_fields: [department, category, brand]
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
    drill_fields: [category, brand]
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    drill_fields: [category, product]
  }

  dimension: product {
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category_1 ;;
    drill_fields: [subcategory, brand, product]
  }

  dimension: subcategory {
    type: string
    sql: ${TABLE}.category_2 ;;
    drill_fields: [brand, product]
  }

  measure: qoh {
    label: "Quantity On Hand"
    type: sum
    sql: ${TABLE}.quantity_on_hand ;;
    drill_fields: [products*]
  }

  measure: cost {
    description: "Quantity of each product multiplied by its cost, and summed"
    label: "Cost On Hand $"
    type: sum
    sql: ${TABLE}.extended_cost ;;
    value_format: "$#,##0"
    drill_fields: [products*]
  }

  measure: opportunity {
    description: "Quantity of each product multiplied by its MSRP, and summed"
    label: "Sales Opportunity $"
    type: sum
    sql: ${TABLE}.extended_retail ;;
    value_format: "$#,##0"
    drill_fields: [products*]
  }

  measure: sell_through_rate {
    label: "Sell Through %"
    type: number
    value_format: "0\%"
    sql: 100.00 * (${sales.net_sold_quantity} / NULLIF(${qoh} + ${sales.net_sold_quantity},0)) ;;
  }

  measure: stock_to_sales {
    type: number
    sql: ${qoh} / NULLIF(${sales.net_sold_quantity},0) ;;
    value_format: "0.#"
    html:
      {% if value <= 1.5 %}
        <font color="darkred">{{ rendered_value }}</font>
      {% elsif value <= 2.5 %}
        <font color="goldenrod">{{ rendered_value }}</font>
      {% elsif value <= 4 %}
        <font color="darkgreen">{{ rendered_value }}</font>
      {% elsif value <= 8 %}
        <font color="goldenrod">{{ rendered_value }}</font>
      {% else %}
        <font color="darkred">{{ rendered_value }}</font>
      {% endif %} ;;
  }

  set: products {
    fields: [
      brand,
      department,
      product,
      qoh,
      cost
    ]
  }
}
