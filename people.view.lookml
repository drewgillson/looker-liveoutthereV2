- view: people
  derived_table:
    sql: |
      SELECT DISTINCT a.email
      , mailchimp.series_20160414_camping_A.email AS series_20160414_camping_A_email
      , mailchimp.series_20160414_camping_B.email AS series_20160414_camping_B_email
      FROM (
        SELECT email
        FROM magento.customer_entity
        UNION ALL
        SELECT customer_email
        FROM magento.sales_flat_quote
        UNION ALL
        SELECT customer_email
        FROM magento.sales_flat_order
        UNION ALL
        SELECT email_address
        FROM mailchimp.v3api_liveoutthere_list
        UNION ALL
        SELECT user_id
        FROM snowplow.events
        WHERE [user_id] LIKE '%@%.%'
        UNION ALL
        SELECT[order-email]
        FROM shopify.transactions
      ) AS a
      LEFT JOIN mailchimp.series_20160414_camping_A
        ON a.email = mailchimp.series_20160414_camping_A.email
      LEFT JOIN mailchimp.series_20160414_camping_B
        ON a.email = mailchimp.series_20160414_camping_B.email
      WHERE a.email NOT LIKE '%marketplace.amazon%'
    indexes: [email]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: email
    primary_key: true
    type: string
    sql: ${TABLE}.email
    
  - dimension: 20160414_camping_A
    type: yesno
    #group_label: 'Automation Series'
    sql: ${TABLE}.series_20160414_camping_A_email IS NOT NULL

  - dimension: 20160414_camping_B
    type: yesno
    #group_label: 'Automation Series'
    sql: ${TABLE}.series_20160414_camping_B_email IS NOT NULL
    
  - measure: count
    type: count_distinct
    sql: ${TABLE}.email