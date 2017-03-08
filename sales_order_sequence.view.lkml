view: sales_order_sequence {
  derived_table: {
    sql: SELECT *, ROW_NUMBER() OVER
        (
           PARTITION BY email
           ORDER BY order_created
        ) AS sequence FROM
      (SELECT DISTINCT sales.email, sales.order_entity_id, sales.order_created
      FROM ${sales_items.SQL_TABLE_NAME} AS sales) AS x ;;
  }

  dimension: order_entity_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.order_entity_id ;;
  }

  dimension: number {
    type: number
    sql: ${TABLE}.sequence ;;
  }

  dimension: new_or_repeat {
    label: "New or Repeat Customer"
    type: string
    sql: CASE WHEN ${number} = 1 THEN 'New' WHEN ${number} > 1 THEN 'Repeat' END
      ;;
  }

  dimension: months_since_first_purchase {
    type: number
    sql:  DATEDIFF(mm,${customers.first_order_date},${sales.order_created_date}) ;;
  }
}
