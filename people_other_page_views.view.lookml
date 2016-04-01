- view: people_other_page_views
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY visit) AS row, a.*, COUNT(DISTINCT b.brand) AS brand_plp
      FROM (
        SELECT CONVERT(date, a.mdt_timestamp, 120) AS visit
           , a.[user_id] AS email
           , a.page_urlpath AS url_key
           , COUNT(DISTINCT CONVERT(VARCHAR, (CONVERT(VARCHAR(19),a.mdt_timestamp,120)), 120) + a.domain_userid) AS page_views
        FROM snowplow.events AS a
        LEFT JOIN (SELECT DISTINCT url_key FROM ${catalog_products.SQL_TABLE_NAME}) AS b
          ON a.page_urlpath = b.url_key
        WHERE
        -- if prod -- a.mdt_timestamp > DATEADD(d,-56,GETDATE())
        -- if dev -- a.mdt_timestamp > DATEADD(d,-3,GETDATE())
        AND b.url_key IS NULL
        AND a.[user_id] LIKE '%@%.%'
        GROUP BY CONVERT(date, a.mdt_timestamp, 120), a.page_urlpath, a.[user_id]
      ) AS a
      LEFT JOIN (SELECT DISTINCT REPLACE(REPLACE(LOWER(brand),' ','-'),'''','') AS brand
        FROM ${catalog_products.SQL_TABLE_NAME}) AS b
      ON a.url_key LIKE '%' + b.brand + '%'
      GROUP BY a.visit, a.email, a.url_key, a.page_views
    indexes: [visit, url_key, email]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: url_key
    type: string
    sql: ${TABLE}.url_key

  - dimension: email
    type: string
    hidden: true
    sql: ${TABLE}.email

  - dimension_group: page_view
    description: "Date page view was recorded (note that to speed things up this view only contains the last 8 weeks of data)"
    type: time
    timeframes: [date]
    sql: ${TABLE}.visit
    
  - dimension: department
    sql: |
      CASE WHEN ${url_key} LIKE '/womens-%' OR ${url_key} = '/womens' THEN 'Women'
           WHEN ${url_key} LIKE '/mens-%' OR ${url_key} = '/mens' THEN 'Men'
           WHEN ${url_key} LIKE '/boys-%' OR ${url_key} = '/boys' THEN 'Boy'
           WHEN ${url_key} LIKE '/girls-%' OR ${url_key} = '/girls' THEN 'Girl' END

  - dimension: brand_plp
    label: "Brand PLP"
    type: number
    sql: ${TABLE}.brand_plp

  - dimension: discount_plp
    label: "Discount PLP"
    type: yesno
    sql: ${url_key} LIKE '%__-off%'

  - dimension: checkout
    type: yesno
    sql: ${url_key} LIKE '%checkout%' OR ${url_key} LIKE '%paypal%'

  - dimension: cart
    type: yesno
    sql: ${url_key} LIKE '%cart%'

  - dimension: account
    type: yesno
    sql: ${url_key} LIKE '%account%'
    
  - measure: count
    description: "Number of unique page views recorded by Snowplow"
    type: sum
    sql: ${TABLE}.page_views
    value_format: "0"
