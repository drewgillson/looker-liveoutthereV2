view: jaccard_product_view {
  derived_table: {
    sql: SELECT p.url_key
        , p.parent_id
        , COUNT(DISTINCT p.url_key + CAST(oi.email AS varchar(20))) AS frequency
      FROM ${people_products_page_views.SQL_TABLE_NAME} AS oi
      JOIN (SELECT DISTINCT parent_id, url_key
            FROM ${catalog_product.SQL_TABLE_NAME}
      ) AS p
        ON oi.url_key = p.url_key
      GROUP BY p.url_key, p.parent_id
       ;;
    indexes: ["url_key"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: url_key {
    type: string
    sql: ${TABLE}.url_key ;;
  }

  dimension: parent_id {
    type: number
    sql: ${TABLE}.parent_id ;;
  }

  dimension: frequency {
    type: number
    sql: ${TABLE}.frequency ;;
  }
}
