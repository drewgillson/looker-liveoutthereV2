view: organizers_misshipments {
  derived_table: {
    sql: SELECT ot_id
              , CAST(ot_description AS nvarchar(255)) AS sku
              , ot_created_at AS created_at
              , b.increment_id AS order_id
         FROM magento.organizer_task AS a
         LEFT JOIN magento.sales_flat_order AS b
             ON a.ot_entity_id = b.entity_id
         WHERE ot_caption LIKE 'mis%shipment'
      ;;
  }

  dimension: entity_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.ot_id ;;
  }

  dimension: order_id {
    sql: ${TABLE}.order_id ;;
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
