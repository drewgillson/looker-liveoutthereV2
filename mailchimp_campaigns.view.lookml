
- view: mailchimp_campaigns
  sql_table_name: mailchimp.v3api_liveoutthere_campaigns

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: campaign_id
    primary_key: true
    type: string
    sql: ${TABLE}.campaign_id

  - dimension: campaign_type
    type: string
    sql: ${TABLE}.campaign_type

  - dimension: status
    type: string
    sql: ${TABLE}.status

  - dimension: subject_line
    type: string
    sql: ${TABLE}.subject_line

  - dimension: title
    type: string
    sql: ${TABLE}.title

  - dimension: utm_campaign
    type: string
    sql: ${TABLE}.utm_campaign

  - dimension: ab_split_subject_a
    type: string
    sql: ${TABLE}.ab_split_subject_a

  - dimension: ab_split_subject_b
    type: string
    sql: ${TABLE}.ab_split_subject_b

  sets:
    detail:
      - campaign_id
      - campaign_type
      - status
      - subject_line
      - title
      - utm_campaign
      - ab_split_subject_a
      - ab_split_subject_b

