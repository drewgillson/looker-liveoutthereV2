view: orderforms_seasons {
  derived_table: {
    sql: SELECT 1 AS id, 'FW16' AS season
      UNION ALL
      SELECT 2, 'SS17'
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
}
