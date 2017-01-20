view: orderforms_seasons {
  derived_table: {
    sql: SELECT 1 AS id, NULL AS season, '2016-07-01' AS begin_ship, '2016-10-01' AS end_ship
         UNION ALL
         SELECT 2, NULL, '2017-10-01', '2017-01-01'
         UNION ALL
         SELECT 3, NULL, '2017-01-01', '2017-04-01'
         UNION ALL
         SELECT 4, NULL, '2017-04-01', '2017-07-01'
         UNION ALL
         SELECT 5, NULL, '2017-07-01', '2017-10-01'
         UNION ALL
         SELECT 5, NULL, '2017-10-01', '2018-01-01'
         UNION ALL
         SELECT 6, 'No Ship Date', NULL, NULL
       ;;
    indexes: ["season"]
    persist_for: "168 hours"
  }

  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: season {
    type: string
    sql: ${TABLE}.season ;;
  }

  dimension_group: ship {
    type: time
    timeframes: [quarter]
    sql: ${TABLE}.begin_ship ;;
  }
}
