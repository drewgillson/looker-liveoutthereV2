- view: people_activity
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY event_time) AS row, * FROM (
        SELECT mailchimp_activity.email AS email 
          , CONVERT(VARCHAR(19),mailchimp_activity.activity,120) AS event_time
          , mailchimp_activity.action AS event_type
          , mailchimp_activity.title + ISNULL(' ' + campaigns.subject_line + ' ' + campaigns.ab_split_subject_a + ' ' + campaigns.ab_split_subject_b,'') AS event_description
          , NULL AS page_url
        FROM ${mailchimp_activity.SQL_TABLE_NAME} AS mailchimp_activity
        LEFT JOIN mailchimp.v3api_liveoutthere_campaigns AS campaigns
          ON mailchimp_activity.campaign_id = campaigns.campaign_id
        UNION ALL
        SELECT [user_id]
          , mdt_timestamp
          , CASE WHEN [event] LIKE '%struct' THEN 'page_event' ELSE [event] END
          , ISNULL(CASE WHEN [event] = 'page_view' THEN REPLACE(page_title,'| Live Out There','') + ' (' + page_urlpath + page_urlquery + ')' END,'') + ISNULL(CASE WHEN [event] = 'struct' THEN 'Event: [' + se_category + ',' + se_action + ',' + se_label + ']' END,'')
          , page_urlpath
        FROM snowplow.[events]
        WHERE [user_id] LIKE '%@%.%' AND
        -- if prod -- mdt_timestamp > DATEADD(d,-56,GETDATE())
        -- if dev -- mdt_timestamp > DATEADD(d,-7,GETDATE())
      ) AS a
    indexes: [email]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  
  - filter: description_filter
  
  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row
    
  - measure: count
    type: count
    drill_fields: detail*

  - dimension_group: event
    type: time
    sql: ${TABLE}.event_time

  - dimension: email
    type: string
    hidden: true
    sql: ${TABLE}.email

  - dimension: type
    type: string
    sql: ${TABLE}.event_type

  - dimension: description
    type: string
    sql: |
      CASE
        WHEN {% condition description_filter %} ${TABLE}.event_description {% endcondition %}
        THEN ${TABLE}.event_description
      END

  - dimension: page_url
    label: "Page URL"
    type: string
    sql: ${TABLE}.page_url


