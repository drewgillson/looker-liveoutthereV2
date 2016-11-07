view: orderforms_category_map {
  sql_table_name: lut_messy_category_data ;;

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: inventory_type {
    type: string
    sql: CASE WHEN ${assortment_planning_not_mapped_to_budget.source_sheet} = 'Fashion' THEN 'Fashion'
           WHEN ${assortment_planning_not_mapped_to_budget.source_sheet} = 'Kids' THEN 'Kids'
           ELSE ${TABLE}.inventory_type
      END
       ;;
  }

  dimension: reporting_category_level1 {
    type: string
    sql: ${TABLE}.reporting_category_level1 ;;
  }

  dimension: reporting_category_level2 {
    type: string
    sql: ${TABLE}.reporting_category_level2 ;;
  }

  dimension: reporting_category_level3 {
    type: string
    sql: ${TABLE}.reporting_category_level3 ;;
  }

  dimension: reporting_category_level4 {
    type: string
    sql: ${TABLE}.reporting_category_level4 ;;
  }

  dimension: reporting_category_level5 {
    type: string
    sql: ${TABLE}.reporting_category_level5 ;;
  }

  set: detail {
    fields: [category, inventory_type, reporting_category_level1, reporting_category_level2, reporting_category_level3, reporting_category_level4, reporting_category_level5]
  }
}
