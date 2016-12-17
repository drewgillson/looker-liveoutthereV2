view: mailchimp_activity {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY [activity]) AS row, a.*, b.*, c.transactions, c.revenue FROM (
        SELECT a.[email_address] AS email
           , a.[status] AS activity_status
           , a.avg_open_rate
           , a.avg_click_rate
           , ISNULL(CAST(NULLIF(REPLACE(LEFT(a.timestamp_signup,15),'T',' '),'') AS datetime),'1970-01-01') AS signup
           , a.member_rating
           , CASE WHEN CAST(NULLIF(REPLACE(LEFT(a.timestamp_signup,15),'T',' '),'') AS date) = CAST(REPLACE(LEFT(b.[timestamp],15),'T',' ') AS date) THEN 'subscribe' ELSE b.action END AS action
           , DATEADD(hh,-7,CAST(REPLACE(LEFT(b.[timestamp],15),'T',' ') AS datetime)) AS [activity]
           , b.url
           , b.campaign_id AS activity_campaign_id
           , b.title AS activity_title
        FROM mailchimp.v3api_liveoutthere_list AS a
        LEFT JOIN mailchimp.v3api_liveoutthere_list_activity AS b
          ON a.id = b.subscriber_id
      ) AS a
      LEFT JOIN mailchimp.v3api_liveoutthere_campaigns AS b
        ON a.activity_campaign_id = b.campaign_id
      LEFT JOIN ga.email_transactions AS c
        ON a.activity_title = c.campaign
       ;;
    indexes: ["email", "activity", "action", "title"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-7,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.row ;;
  }

  dimension: campaign_type {
    label: "Campaign: Type"
    type: string
    sql: ${TABLE}.campaign_type ;;
  }

  dimension: subscriber_status {
    label: "Subscriber: Status"
    type: string
    sql: ${TABLE}.activity_status ;;
  }

  dimension: subject_line {
    label: "Campaign: Subject Line"
    type: string
    sql: CASE WHEN ${TABLE}.subject_line IS NOT NULL THEN ${TABLE}.subject_line
           WHEN ${TABLE}.action LIKE 'mandrill%' THEN ${TABLE}.activity_title END
       ;;
  }

  dimension: activity_title {
    label: "Activity: Title"
    type: string
    sql: ${TABLE}.activity_title ;;
  }

  dimension: utm_campaign {
    label: "Campaign: UTM Tracking Value"
    type: string
    sql: ${TABLE}.utm_campaign ;;
  }

  dimension: ab_split_subject_a {
    label: "Campaign: A/B Test - Subject Line A"
    type: string
    sql: ${TABLE}.ab_split_subject_a ;;
  }

  dimension: ab_split_subject_b {
    label: "Campaign: A/B Test - Subject Line B"
    type: string
    sql: ${TABLE}.ab_split_subject_b ;;
  }

  dimension: activity_status {
    label: "Activity: Status"
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: signup {
    label: "Subscriber: Signup"
    type: time
    sql: ${TABLE}.signup ;;
  }

  dimension: action {
    label: "Activity: Action"
    type: string
    sql: ${TABLE}.action ;;
  }

  dimension_group: activity {
    label: "Activity: "
    type: time
    sql: ${TABLE}.activity ;;
  }

  measure: last_activity {
    label: "Subscriber: Last Activity"
    type: date
    sql: MAX(${TABLE}.activity) ;;
  }

  dimension: url {
    label: "Activity: URL"
    type: string
    sql: ${TABLE}.url ;;
  }

  dimension: campaign_id {
    label: "Campaign: ID"
    type: string
    sql: ${TABLE}.campaign_id ;;
  }

  dimension: campaign_title {
    label: "Campaign: Title"
    type: string
    sql: ${TABLE}.title ;;
  }

  measure: campaigns_opened_recently {
    label: "Subscriber: Campaigns Opened Recently"
    type: count_distinct
    sql: ${campaign_id} ;;
  }

  measure: average_open_rate {
    label: "Subscriber: Avg. Open Rate %"
    type: average
    value_format: "0.00%"
    sql: ${TABLE}.avg_open_rate ;;
  }

  measure: average_click_rate {
    label: "Subscriber: Avg. Click Rate"
    type: average
    value_format: "0.00%"
    sql: ${TABLE}.avg_click_rate ;;
  }

  measure: member_rating {
    label: "Subscriber: Avg. Member Rating"
    type: average
    value_format: "0.00"
    sql: ${TABLE}.member_rating ;;
  }

  measure: campaign_opens {
    label: "Campaign: Opens"
    type: sum_distinct
    sql_distinct_key: ${TABLE}.campaign_id ;;
    sql: ${TABLE}.opens ;;
  }

  measure: campaign_unique_opens {
    label: "Campaign: Unique Opens"
    type: sum_distinct
    sql_distinct_key: ${TABLE}.campaign_id ;;
    sql: ${TABLE}.unique_opens ;;
  }

  measure: campaign_open_rate {
    label: "Campaign: Open Rate %"
    type: average_distinct
    sql_distinct_key: ${TABLE}.campaign_id ;;
    value_format: "0.00%"
    sql: ${TABLE}.open_rate ;;
  }

  measure: campaign_clicks {
    label: "Campaign: Clicks"
    type: sum_distinct
    sql_distinct_key: ${TABLE}.campaign_id ;;
    sql: ${TABLE}.clicks ;;
  }

  #  - measure: campaign_unique_clicks
  #    type: sum_distinct
  #    sql_distinct_key: ${TABLE}.campaign_id
  #    sql: ${TABLE}.unique_clicks

  measure: campaign_click_rate {
    label: "Campaign: Click Rate %"
    type: average_distinct
    sql_distinct_key: ${TABLE}.campaign_id ;;
    value_format: "0.00%"
    sql: ${TABLE}.click_rate ;;
  }

  measure: activity_count {
    label: "Subscriber: Activity Count"
    description: "Use to get the number of individual activities at the subscriber level"
    type: count
  }

  measure: transactions {
    type: sum_distinct
    sql_distinct_key: ${TABLE}.activity_title ;;
    sql: ${TABLE}.transactions ;;
  }

  measure: revenue {
    type: sum_distinct
    sql_distinct_key: ${TABLE}.activity_title ;;
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.revenue ;;
  }
}