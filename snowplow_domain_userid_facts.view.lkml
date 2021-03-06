view: snowplow_domain_userid_facts {
  sql_table_name: LOT_Reporting.snowplow.consolidated_identities ;;

  dimension: domain_userid {
    primary_key: yes
    sql: ${TABLE}.domain_userid ;;
  }

  dimension: user_id {
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: first_seen {
    type: time
    sql: ${TABLE}.first_created ;;
  }
}
