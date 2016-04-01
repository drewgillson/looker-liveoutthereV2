
- view: mailchimp_activity
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY [activity]) AS row, a.* FROM (
        SELECT a.email_address AS email
           , a.[status]
           , a.avg_open_rate
           , a.avg_click_rate
           , ISNULL(CAST(NULLIF(a.timestamp_signup,'') AS datetime),'1970-01-01') AS signup
           , a.member_rating
           , b.action
           , DATEADD(hh,-7,CAST(REPLACE(LEFT(b.[timestamp],15),'T',' ') AS datetime)) AS [activity]
           , b.url
           , b.campaign_id
           , b.title
        FROM [mailchimp].v3api_liveoutthere_list AS a
        LEFT JOIN [mailchimp].[v3api_liveoutthere_list_activity] AS b
          ON a.id = b.subscriber_id
      ) AS a
    indexes: [email, activity]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.row

  - dimension: status
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

  - dimension: email_title
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
    
  - measure: count
    type: count
    