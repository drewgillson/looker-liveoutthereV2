view: elasticsearch_products_latest {
  derived_table: {
    sql: SELECT * FROM elasticsearch.products_log AS a
      WHERE CAST(a.log_date AS date) = CAST(GETDATE() AS date) -- today
       ;;
    indexes: ["entity_id", "log_date"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: log_id {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.log_id ;;
  }

  dimension: entity_id {
    hidden: yes
    type: string
    sql: SUBSTRING(${TABLE}.entity_id,2,LEN(${TABLE}.entity_id)-2) ;;
  }

  dimension: in_product_index {
    type: yesno
    sql: ${entity_id} IS NOT NULL ;;
  }
}
