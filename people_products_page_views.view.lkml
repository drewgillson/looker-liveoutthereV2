view: people_products_page_views {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY visit) AS row, * FROM (
        SELECT CONVERT(date, a.mdt_timestamp, 120) AS visit
           , a.[user_id] AS email
           , a.page_urlpath AS url_key
           , COUNT(DISTINCT CONVERT(VARCHAR, (CONVERT(VARCHAR(19),a.mdt_timestamp,120)), 120) + a.domain_userid) AS page_views
        FROM snowplow.events AS a
        INNER JOIN (SELECT DISTINCT url_key FROM ${catalog_product.SQL_TABLE_NAME}) AS b
          ON a.page_urlpath = b.url_key
        WHERE a.mdt_timestamp > DATEADD(d,-56,GETDATE())
        GROUP BY CONVERT(date, a.mdt_timestamp, 120), a.page_urlpath, a.[user_id]
      ) AS a
       ;;
    indexes: ["visit", "url_key", "email"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  dimension: url_key {
    type: string
    sql: ${TABLE}.url_key ;;
  }

  dimension: email {
    type: string
    hidden: yes
    sql: ${TABLE}.email ;;
  }

  dimension_group: page_view {
    description: "Date page view was recorded (note that to speed things up this view only contains the last 8 weeks of data)"
    type: time
    timeframes: [date]
    sql: ${TABLE}.visit ;;
  }

  measure: count {
    description: "Number of unique page views recorded by Snowplow"
    type: sum
    sql: ${TABLE}.page_views ;;
    value_format: "0"
  }
}
