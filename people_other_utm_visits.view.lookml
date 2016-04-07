- view: people_other_utm_visits
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY visit) AS row
        , a.*
      FROM (
        SELECT CONVERT(date, a.mdt_timestamp, 120) AS visit
           , a.[user_id] AS email
           , a.mkt_medium AS utm_medium
           , a.mkt_source AS utm_source
           , a.mkt_campaign AS utm_campaign
           , a.mkt_content AS utm_content
           , COUNT(DISTINCT CONVERT(VARCHAR, (CONVERT(VARCHAR(19),a.mdt_timestamp,120)), 120) + a.domain_userid) AS page_views
        FROM snowplow.events AS a
        WHERE a.mdt_timestamp > DATEADD(d,-56,GETDATE())
        AND a.[user_id] LIKE '%@%.%'
        AND a.mkt_source <> ''
        GROUP BY CONVERT(date, a.mdt_timestamp, 120), a.mkt_medium, a.mkt_source, a.mkt_campaign, a.mkt_content, a.[user_id]
      ) AS a
    indexes: [visit, utm_medium, utm_source, utm_campaign, email]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: email
    type: string
    hidden: true
    sql: ${TABLE}.email

  - dimension_group: page_view
    description: "Date page view was recorded (note that to speed things up this view only contains the last 8 weeks of data)"
    type: time
    timeframes: [date]
    sql: ${TABLE}.visit
    
  - dimension: utm_medium
    label: "Medium"
    type: string
    sql: ${TABLE}.utm_medium

  - dimension: utm_source
    label: "Source"
    type: string
    sql: ${TABLE}.utm_source

  - dimension: utm_campaign
    label: "Campaign"
    type: string
    sql: ${TABLE}.utm_campaign
    
  - dimension: utm_content
    label: "Content"
    type: string
    sql: ${TABLE}.utm_content

  - measure: page_views
    description: "Number of page views recorded by Snowplow"
    type: sum
    sql: ${TABLE}.page_views
    value_format: "#,##0"

  - measure: unique_visitors
    description: "Number of unique visitors recorded by Snowplow"
    type: count_distinct
    sql: ${TABLE}.email
    value_format: "#,##0"
