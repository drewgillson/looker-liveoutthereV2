view: orderforms_seasons {
  derived_table: {
    sql: SELECT 1 AS id, 'FW16' AS season, '2016-07-01' AS begin_ship, '2017-01-01' AS end_ship
         UNION ALL
         SELECT 2, 'SS17', '2017-01-01' AS begin_ship, '2017-07-01' AS end_ship
         UNION ALL
         SELECT 3, 'FW17', '2017-07-01' AS begin_ship, '2018-01-01' AS end_ship
         UNION ALL
         SELECT 4, 'No Ship Date', NULL, NULL
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
