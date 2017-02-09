view: sales_return_authorizations_comments {
  derived_table: {
    sql: SELECT id
          , entity_id
          , created_at
          , text AS comment
         FROM magento.aw_rma_entity_comments
         WHERE text NOT LIKE 'Please make sure your order can be returned%'
         AND text NOT LIKE 'Your refund or exchange request has been saved%'
      ;;
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date) ;;
    indexes: ["entity_id"]
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: entity_id {
    hidden: yes
    type: number
    sql: ${TABLE}.entity_id ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension: comment {
    type: string
    sql: ${TABLE}.comment ;;
  }

  set: detail {
    fields: [id, entity_id, created_at_time, comment]
  }
}
