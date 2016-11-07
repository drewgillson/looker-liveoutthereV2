view: people_facts {
  sql_table_name: LOT_Reporting.snowplow.consolidated_identities ;;

  dimension: email {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: first_seen {
    type: time
    sql: ${TABLE}.first_created ;;
  }

  dimension: snowplow_id {
    label: "Snowplow Identifier"
    type: string
    sql: ${TABLE}.domain_userid ;;
  }
}
