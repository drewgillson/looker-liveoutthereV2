
- view: mailchimp_activity
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY [activity]) AS row, a.*, b.* FROM (
        SELECT a.email_address AS email
           , a.[status] AS activity_status
           , a.avg_open_rate
           , a.avg_click_rate
           , ISNULL(CAST(NULLIF(a.timestamp_signup,'') AS datetime),'1970-01-01') AS signup
           , a.member_rating
           , b.action
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
    indexes: [email, activity]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.row

  - dimension: campaign_type
    type: string
    sql: ${TABLE}.campaign_type

  - dimension: subscriber_status
    type: string
    sql: ${TABLE}.activity_status

  - dimension: subject_line
    type: string
    sql: |
      CASE WHEN ${TABLE}.subject_line IS NOT NULL THEN ${TABLE}.subject_line
           WHEN ${TABLE}.action LIKE 'mandrill%' THEN ${TABLE}.activity_title END

  - dimension: activity_title
    type: string
    sql: ${TABLE}.activity_title

  - dimension: utm_campaign
    label: "UTM Tracking Value"
    type: string
    sql: ${TABLE}.utm_campaign

  - dimension: ab_split_subject_a
    label: "A/B Test - Subject Line A"
    type: string
    sql: ${TABLE}.ab_split_subject_a

  - dimension: ab_split_subject_b
    label: "A/B Test - Subject Line B"
    type: string
    sql: ${TABLE}.ab_split_subject_b

  - dimension: activity_status
    type: string
    sql: ${TABLE}.status

  - dimension_group: signup
    type: time
    sql: ${TABLE}.signup

  - dimension: action
    type: string
    sql: ${TABLE}.action

  - dimension_group: activity
    type: time
    sql: ${TABLE}.activity

  - measure: last_activity
    type: time
    sql: MAX(${TABLE}.activity)

  - dimension: url
    type: string
    sql: ${TABLE}.url

  - dimension: campaign_id
    type: string
    sql: ${TABLE}.campaign_id

  - dimension: campaign_title
    type: string
    sql: ${TABLE}.title
    
  - measure: campaigns_opened_recently
    type: count_distinct
    sql: ${campaign_id}
    
  - measure: average_open_rate
    type: avg
    value_format: "0.00%"
    sql: ${TABLE}.avg_open_rate

  - measure: average_click_rate
    type: avg
    value_format: "0.00%"
    sql: ${TABLE}.avg_click_rate

  - measure: member_rating
    type: avg
    value_format: "0.00"
    sql: ${TABLE}.member_rating

  - measure: campaign_opens
    type: sum_distinct
    sql_distinct_key: ${TABLE}.campaign_id
    sql: ${TABLE}.opens

  - measure: campaign_unique_opens
    type: sum_distinct
    sql_distinct_key: ${TABLE}.campaign_id
    sql: ${TABLE}.unique_opens

  - measure: campaign_open_rate
    type: avg_distinct
    sql_distinct_key: ${TABLE}.campaign_id
    value_format: "0.00%"
    sql: ${TABLE}.open_rate

  - measure: campaign_clicks
    type: sum_distinct
    sql_distinct_key: ${TABLE}.campaign_id
    sql: ${TABLE}.clicks

#  - measure: campaign_unique_clicks
#    type: sum_distinct
#    sql_distinct_key: ${TABLE}.campaign_id
#    sql: ${TABLE}.unique_clicks

  - measure: campaign_click_rate
    type: avg_distinct
    sql_distinct_key: ${TABLE}.campaign_id
    value_format: "0.00%"
    sql: ${TABLE}.click_rate
    
  - measure: activity_count
    type: count
    