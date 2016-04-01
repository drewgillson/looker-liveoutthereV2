- view: people_other_events
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY visit) AS row
        , a.*
      FROM (
        SELECT CONVERT(date, a.mdt_timestamp, 120) AS visit
           , a.[user_id] AS email
           , a.se_category
           , a.se_action
           , a.se_label
           , COUNT(DISTINCT CONVERT(VARCHAR, (CONVERT(VARCHAR(19),a.mdt_timestamp,120)), 120) + a.domain_userid) AS page_views
        FROM snowplow.events AS a
        WHERE a.mdt_timestamp > DATEADD(d,-56,GETDATE())
        AND a.[event] IN ('struct','unstruct')
        AND a.[user_id] LIKE '%@%.%'
        GROUP BY CONVERT(date, a.mdt_timestamp, 120), a.[user_id], a.se_category, a.se_action, a.se_label
      ) AS a
    indexes: [visit, se_category, email]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: category
    type: string
    sql: ${TABLE}.se_category

  - dimension: action
    type: string
    sql: ${TABLE}.se_action

  - dimension: label
    type: string
    sql: ${TABLE}.se_label

  - dimension: email
    type: string
    hidden: true
    sql: ${TABLE}.email

  - dimension_group: event
    description: "Date event was recorded (note that to speed things up this view only contains the last 8 weeks of data)"
    type: time
    timeframes: [date]
    sql: ${TABLE}.visit
    
  - measure: events
    description: "Number of events recorded by Snowplow"
    type: sum
    sql: ${TABLE}.page_views
    value_format: "#,##0"