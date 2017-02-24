view: customers {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY created_at) AS entity_id, * FROM (
        SELECT s.customer_email AS email
           , COALESCE(MAX(e.value), MAX(s.customer_firstname)) AS firstname
           , COALESCE(MAX(f.value), MAX(s.customer_lastname)) AS lastname
           , COALESCE(MIN(a.created_at), MIN(s.created_at)) AS created_at
           , COALESCE(MAX(a.updated_at), MAX(s.created_at)) AS updated_at
           , COALESCE(MAX(a.is_active), 1) AS is_active
           , ISNULL(MAX(d.customer_group_code), 'Guest') AS customer_group_code
           , MAX(b.value) AS date_of_birth
           , MAX(c.value) AS member_until
           , CASE WHEN MAX(g.value) = 1 THEN 'Male' WHEN MAX(g.value) = 2 THEN 'Female' END AS gender
           , CASE WHEN MIN(s.created_at) < ISNULL(MIN(h.first_order),GETDATE()) THEN MIN(s.created_at) ELSE MIN(h.first_order) END AS first_order
           , MAX(s.created_at) AS last_order
           , COUNT(DISTINCT s.entity_id) AS orders
        FROM magento.sales_flat_order AS s
        LEFT JOIN magento.customer_entity AS a
          ON s.customer_id = a.entity_id
        LEFT JOIN magento.customer_entity_datetime AS b
          ON a.entity_id = b.entity_id AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'dob' AND entity_type_id = 1)
        LEFT JOIN magento.customer_entity_datetime AS c
          ON a.entity_id = c.entity_id AND c.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'member_until' AND entity_type_id = 1)
        LEFT JOIN magento.customer_group AS d
          ON a.group_id = d.customer_group_id
        LEFT JOIN magento.customer_entity_varchar AS e
          ON a.entity_id = e.entity_id AND e.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'firstname' AND entity_type_id = 1)
        LEFT JOIN magento.customer_entity_varchar AS f
          ON a.entity_id = f.entity_id AND f.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'lastname' AND entity_type_id = 1)
        LEFT JOIN magento.customer_entity_int AS g
          ON a.entity_id = g.entity_id AND g.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'gender' AND entity_type_id = 1)
        LEFT JOIN (SELECT a.[order-email] AS email
                    , CONVERT(VARCHAR(19),MIN(a.[order-created_at]),120) + '.0000000 +00:00' AS first_order
                   FROM shopify.order_items AS a
                   GROUP BY a.[order-email]) AS h
        ON s.customer_email = h.email
        GROUP BY s.customer_email
      ) AS a
      LEFT JOIN (
        SELECT a.email AS customer_email
          , CASE WHEN MIN(a.order_created) >= MIN(b.first_created) THEN DATEDIFF(d, MIN(b.first_created), MIN(a.order_created)) ELSE NULL END AS days_to_1st_purchase
          , CAST(AVG(a.row_total / a.qty) AS money) AS avg_item_price
          , SUM(a.row_total) AS sales
          , MIN(b.first_created) AS first_seen
        FROM ${sales_items.SQL_TABLE_NAME} AS a
        LEFT JOIN snowplow.consolidated_identities AS b
          ON a.email = b.user_id
        GROUP BY a.email
      ) AS b
      ON a.email = b.customer_email
       ;;
    indexes: ["entity_id", "email", "customer_group_code"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  filter: days_to_1st_purchase_limit {}

  dimension: entity_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.entity_id ;;
  }

  dimension: email {
    #hidden: yes
    description: "Email addresses associated with Magento orders"
    sql: LOWER(${TABLE}.email) ;;
  }

  dimension: first_name {
    type: string
    sql: CASE WHEN ${TABLE}.firstname != 'First Name' THEN ${TABLE}.firstname END ;;
  }

  dimension: last_name {
    type: string
    sql: CASE WHEN ${TABLE}.lastname != 'Last Name' THEN ${TABLE}.lastname END ;;
  }

  dimension: name {
    type: string
    sql: ${first_name} + ' ' + ${last_name} ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: updated {
    type: time
    sql: ${TABLE}.updated_at ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active = 1 ;;
  }

  dimension: customer_group {
    type: string
    sql: ${TABLE}.customer_group_code ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension_group: birth {
    type: time
    timeframes: [date]
    sql: ${TABLE}.date_of_birth ;;
  }

  dimension: member {
    type: yesno
    sql: ${TABLE}.member_until IS NOT NULL ;;
  }

  dimension_group: first_order {
    type: time
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: first_order_fiscal {
    type: time
    timeframes: [year, quarter, quarter_of_year]
    sql: DATEADD(mm,-1,${TABLE}.first_order) ;;
  }

  dimension: months_since_1st_order {
    type: number
    value_format: "#"
    sql: ISNULL(DATEDIFF(mm,${first_order_date},${sales.order_created_date}),0) ;;
  }

  dimension_group: last_order {
    type: time
    sql: ${TABLE}.last_order ;;
  }

  measure: days_to_1st_purchase {
    type: average
    sql: CASE
        WHEN {% condition days_to_1st_purchase_limit %} ${TABLE}.days_to_1st_purchase {% endcondition %}
        THEN NULL
        ELSE ${TABLE}.days_to_1st_purchase
      END
       ;;
    description: "Number of days that elapse before prospects make their 1st purchase"
  }

  dimension: days_since_last_purchase_tier {
    description: "Number of days that have elapsed since customer's last purchases"
    type: number
    sql: DATEDIFF(d,${TABLE}.last_order,GETDATE()) ;;
  }

  measure: total_orders {
    description: "Total number of orders"
    label: "Total Orders"
    type: sum
    sql: ${TABLE}.orders ;;
  }

  measure: unique_customers {
    label: "Unique Customer Count"
    type: count_distinct
    sql: ${email} ;;
  }

  measure: unique_customers_running_count {
    label: "Unique Customer Count Running Total"
    type: running_total
    sql: ${unique_customers} ;;
  }

  measure: average_orders_per_customer {
    type: number
    value_format: "0.00"
    sql: ${total_orders} / NULLIF(CAST(${unique_customers} AS float),0) ;;
  }

  measure: average_item_price {
    description: "Average price paid for items"
    type: average
    value_format: "$#,##0.00"
    sql: ${TABLE}.avg_item_price ;;
  }

  measure: sales {
    description: "The total dollar value customers have spent"
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.sales ;;
  }

  measure: average_order_value {
    description: "The average amount customers spend on each order"
    type: number
    value_format: "$#,##0.00"
    sql: ${sales} / NULLIF(${total_orders},0) ;;
  }

  measure: percent_of_orders {
    type: percent_of_total
    sql: ${total_orders} ;;
  }

  measure: count {
    type: count
  }
}
