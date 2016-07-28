- view: mailchimp_list
  sql_table_name: mailchimp.v3api_liveoutthere_list

  fields:

  - dimension: id
    type: number
    primary_key: true
    hidden: true
    sql: ${TABLE}.id

  - dimension: email
    type: string
    sql: ${TABLE}.email_address

  - dimension: subscribed
    type: yesno
    sql: ${subscriber_status} = 'subscribed'

  - dimension: subscriber_status
    type: string
    sql: ${TABLE}.status

  - dimension_group: signup
    type: time
    sql: ISNULL(CAST(NULLIF(REPLACE(LEFT(${TABLE}.timestamp_signup,15),'T',' '),'') AS datetime),'1970-01-01')

  - dimension_group: last_changed
    type: time
    sql: ${TABLE}.last_changed

  - dimension: member_rating
    type: number
    value_format: "#"
    sql: ${TABLE}.member_rating
    
  - measure: count
    type: count