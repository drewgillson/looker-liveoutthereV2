- view: people
  derived_table:
    sql: |
      SELECT DISTINCT email FROM (
        SELECT email
        FROM magento.customer_entity
        UNION ALL
        SELECT customer_email
        FROM magento.sales_flat_quote
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
      WHERE email NOT LIKE '%marketplace.amazon%'
    indexes: [email]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: email
    primary_key: true
    type: string
    sql: ${TABLE}.email