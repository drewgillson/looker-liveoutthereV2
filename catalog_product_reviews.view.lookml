- view: catalog_product_reviews
  derived_table:
    sql: |
      SELECT b.review_id
         , a.entity_id
         , b.created_at
         , e.status_code
         , c.title
         , c.detail
         , c.nickname
         , d.[percent] AS rating_percent
         , d.value AS rating
         , f.email AS customer_email
      FROM magento.catalog_product_entity AS a
      LEFT JOIN magento.review AS b
        ON a.entity_id = b.entity_pk_value
      LEFT JOIN magento.review_detail AS c
        ON b.review_id = c.review_id
      LEFT JOIN magento.rating_option_vote AS d
        ON b.review_id = d.review_id AND d.rating_id = 1
      LEFT JOIN magento.review_status AS e
        ON b.status_id = e.status_id
      LEFT JOIN magento.customer_entity AS f
        ON c.customer_id = f.entity_id 
      WHERE a.type_id = 'configurable'
    indexes: [entity_id, rating]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  - measure: count_of_reviews
    type: count

  - dimension: review_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.review_id

  - dimension: customer_email
    sql: ${TABLE}.customer_email

  - dimension_group: review_created
    type: time
    sql: ${TABLE}.created_at

  - dimension: status
    sql: ${TABLE}.status_code

  - dimension: title
    sql: ${TABLE}.title

  - dimension: detail
    sql: CAST(${TABLE}.detail AS varchar(max))

  - dimension: nickname
    sql: ${TABLE}.nickname

  - dimension: rating_percent
    type: number
    sql: ${TABLE}.rating_percent

  - dimension: rating
    type: number
    sql: ${TABLE}.rating

  - measure: average_rating_percent
    type: avg
    sql: ${TABLE}.rating_percent

  - measure: average_rating
    type: avg
    value_format: '#.00' 
    sql: ${TABLE}.rating
