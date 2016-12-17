view: carts_items {
  derived_table: {
    sql: SELECT b.item_id
        , a.customer_email AS email
        , b.created_at
        , b.product_id
        , b.row_total
        , b.qty
      FROM magento.sales_flat_quote AS a
      INNER JOIN magento.sales_flat_quote_item AS b
        ON a.entity_id = b.quote_id
      WHERE a.customer_email IS NOT NULL
       ;;
    indexes: ["email"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: item_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.item_id ;;
  }

  dimension: email {
    type: string
    hidden: yes
    sql: ${TABLE}.email ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  measure: amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.row_total ;;
  }

  measure: quantity {
    type: sum
    value_format: "0"
    sql: ${TABLE}.qty ;;
  }
}