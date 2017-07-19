view: organizers_misshipments {
  derived_table: {
    sql: SELECT ot_id
              , CAST(ot_description AS nvarchar(255)) AS sku
              , ot_created_at AS created_at
         FROM magento.organizer_task
         WHERE ot_caption LIKE 'mis%shipment'
      ;;
  }

  dimension: entity_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.ot_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sku {
    type: string
    hidden: yes
    sql: ${TABLE}.sku ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  set: detail {
    fields: [sku, created_at_time]
  }
}
