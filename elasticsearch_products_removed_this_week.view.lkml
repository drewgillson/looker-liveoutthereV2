view: elasticsearch_products_removed_this_week {
  derived_table: {
    sql: SELECT a.*
      FROM elasticsearch.products_log AS a
      LEFT JOIN elasticsearch.products_log AS b
      ON a.entity_id = b.entity_id AND CAST(b.log_date AS date) = CAST(GETDATE() AS date) -- today
        WHERE CAST(a.log_date AS date) = DATEADD(dd,-7,CAST(GETDATE() AS date)) -- 7 days ago
      AND b.entity_id IS NULL
       ;;
    indexes: ["entity_id", "log_date"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  measure: count {
    type: count
  }

  dimension: log_id {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.log_id ;;
  }

  dimension: product_name {
    type: string
    sql: SUBSTRING(${TABLE}.product_name,2,LEN(${TABLE}.product_name)-2) ;;
  }

  dimension: entity_id {
    type: string
    sql: SUBSTRING(${TABLE}.entity_id,2,LEN(${TABLE}.entity_id)-2) ;;
  }

  dimension: sku {
    type: string
    sql: SUBSTRING(${TABLE}.sku,2,LEN(${TABLE}.sku)-2) ;;
  }

  dimension: url_key {
    type: string
    sql: SUBSTRING(${TABLE}.url_key,2,LEN(${TABLE}.url_key)-2) ;;
  }

  dimension_group: log {
    type: time
    sql: ${TABLE}.log_date ;;
  }
}
