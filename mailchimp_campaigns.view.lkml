view: mailchimp_campaigns {
  sql_table_name: mailchimp.v3api_liveoutthere_campaigns ;;

  dimension: campaign_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.campaign_id ;;
  }

  dimension: campaign_type {
    type: string
    sql: ${TABLE}.campaign_type ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: subject_line {
    type: string
    sql: ${TABLE}.subject_line ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: utm_campaign {
    label: "UTM Tracking Value"
    type: string
    sql: ${TABLE}.utm_campaign ;;
  }

  dimension: ab_split_subject_a {
    label: "A/B Test - Subject Line A"
    type: string
    sql: ${TABLE}.ab_split_subject_a ;;
  }

  dimension: ab_split_subject_b {
    label: "A/B Test - Subject Line B"
    type: string
    sql: ${TABLE}.ab_split_subject_b ;;
  }

  measure: opens {
    type: sum
    sql: ${TABLE}.opens ;;
  }

  measure: unique_opens {
    type: sum
    sql: ${TABLE}.unique_opens ;;
  }

  measure: open_rate {
    type: average
    value_format: "0.00%"
    sql: ${TABLE}.open_rate ;;
  }

  measure: clicks {
    type: sum
    sql: ${TABLE}.clicks ;;
  }

  measure: unique_clicks {
    type: sum
    sql: ${TABLE}.unique_clicks ;;
  }

  measure: click_rate {
    type: average
    value_format: "0.00%"
    sql: ${TABLE}.click_rate ;;
  }

  set: detail {
    fields: [campaign_id, campaign_type, status, subject_line, title, utm_campaign, ab_split_subject_a, ab_split_subject_b]
  }
}
