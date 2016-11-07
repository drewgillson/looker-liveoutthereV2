view: snowplow_event_sequences {
  derived_table: {
    sql: SELECT event_id, event_sequence FROM snowplow.event_sequences
      ;;
    indexes: ["event_id"]
    sql_trigger_value: SELECT CAST(GETDATE() AS date)
      ;;
  }

  dimension: event_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.event_id ;;
  }

  dimension: number {
    type: number
    sql: ${TABLE}.event_sequence ;;
  }
}
