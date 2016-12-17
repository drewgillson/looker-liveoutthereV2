view: orderforms_budgets {
  sql_table_name: orderform.budgets ;;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}.month ;;
  }

  dimension: season {
    type: string
    sql: ${TABLE}.season ;;
  }

  measure: amount {
    type: sum
    sql: ${TABLE}.amount ;;
    value_format: "$#,##0.00;($#,##0.00)"
  }

  set: detail {
    fields: [department, type, month, amount]
  }
}