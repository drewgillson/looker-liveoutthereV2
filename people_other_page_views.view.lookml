- view: people_other_page_views
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY visit) AS row
        , a.*
        , COUNT(DISTINCT b.brand) AS brand_plp
        , COUNT(DISTINCT c.url_key) AS category_plp
      FROM (
        SELECT CONVERT(date, a.mdt_timestamp, 120) AS visit
           , a.[user_id] AS email
           , a.page_urlpath AS url_key
           , COUNT(DISTINCT CONVERT(VARCHAR, (CONVERT(VARCHAR(19),a.mdt_timestamp,120)), 120) + a.domain_userid) AS page_views
        FROM snowplow.events AS a
        LEFT JOIN (SELECT DISTINCT url_key FROM ${catalog_products.SQL_TABLE_NAME}) AS b
          ON a.page_urlpath = b.url_key
        WHERE a.mdt_timestamp > DATEADD(d,-28,GETDATE())
        AND b.url_key IS NULL
        AND a.[user_id] LIKE '%@%.%'
        GROUP BY CONVERT(date, a.mdt_timestamp, 120), a.page_urlpath, a.[user_id]
      ) AS a
      LEFT JOIN (SELECT DISTINCT REPLACE(REPLACE(LOWER(brand),' ','-'),'''','') AS brand
        FROM ${catalog_products.SQL_TABLE_NAME}
      ) AS b
        ON a.url_key LIKE '%' + b.brand + '%'
      LEFT JOIN (SELECT url_key FROM magento.catalog_category_flat_store_1) AS c
        ON a.url_key LIKE '%' + c.url_key + '%'
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
    hidden: true
    sql: |
      CASE WHEN ${url_key} LIKE '/womens-%' OR ${url_key} LIKE '%womens' OR ${url_key} LIKE '%-womens-%' THEN 'Women'
           WHEN ${url_key} LIKE '/mens-%' OR ${url_key} LIKE '%mens' OR ${url_key} LIKE '%-mens-%' THEN 'Men'
           WHEN ${url_key} LIKE '/boys-%' OR ${url_key} LIKE '%boys' OR ${url_key} LIKE '%-boys-%' THEN 'Boy'
           WHEN ${url_key} LIKE '/girls-%' OR ${url_key} LIKE '%girls' OR ${url_key} LIKE '%-girls-%' THEN 'Girl' END

  - dimension: category_plp
    hidden: true
    type: yesno
    sql: ${TABLE}.category_plp > 0

  - dimension: brand_plp
    hidden: true
    type: yesno
    sql: ${TABLE}.brand_plp > 0

  - dimension: discount_plp
    hidden: true
    type: yesno
    sql: ${url_key} LIKE '%__-off%'

  - dimension: product_listing_page
    hidden: true
    type: yesno
    sql: ${department} IS NOT NULL OR ${brand_plp} OR ${discount_plp} OR ${category_plp} OR ${url_key} = '/new' OR ${url_key} = '/sale-rack' OR ${url_key} = '/shop'

  - dimension: checkout
    hidden: true
    type: yesno
    sql: (${url_key} LIKE '%checkout%' OR ${url_key} LIKE '%paypal%') AND ${url_key} NOT LIKE '%cart%'

  - dimension: cart
    hidden: true
    type: yesno
    sql: ${url_key} LIKE '%/cart%'

  - dimension: account_dashboard
    hidden: true
    type: yesno
    sql: ${url_key} LIKE '%account%'

  - dimension: policy_page
    hidden: true
    type: yesno
    sql: ${url_key} LIKE '/policies-%' OR ${url_key} LIKE '%-policy%' OR ${url_key} LIKE '%terms-conditions%'

  - dimension: home_page
    hidden: true
    type: yesno
    sql: ${url_key} = '/' OR ${url_key} = '/index.php'
    
  - dimension: page_type
    type: string
    sql_case:
      'Product Listing Page': ${product_listing_page}
      'Cart': ${cart}
      'Checkout': ${checkout}
      'Policy Page': ${policy_page}
      'Account Dashboard': ${account_dashboard}
      'Home': ${home_page}
      'Other': 1=1
    
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
