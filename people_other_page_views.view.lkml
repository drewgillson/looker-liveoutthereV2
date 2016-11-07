view: people_other_page_views {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY visit) AS row
        , a.*
        , COUNT(DISTINCT b.brand) AS brand_plp
        , COUNT(DISTINCT c.url_key) AS category_plp
      FROM (
        SELECT CONVERT(date, a.mdt_timestamp, 120) AS visit
           , a.[user_id] AS email
           , a.page_urlpath AS url_key
           , COUNT(DISTINCT CONVERT(VARCHAR, (CONVERT(VARCHAR(19),a.mdt_timestamp,120)), 120) + a.domain_userid) AS page_views
        FROM snowplow.events AS a
        LEFT JOIN (SELECT DISTINCT url_key FROM ${catalog_product.SQL_TABLE_NAME}) AS b
          ON a.page_urlpath = b.url_key
        WHERE a.mdt_timestamp > DATEADD(d,-28,GETDATE())
        AND b.url_key IS NULL
        AND a.[user_id] LIKE '%@%.%'
        GROUP BY CONVERT(date, a.mdt_timestamp, 120), a.page_urlpath, a.[user_id]
      ) AS a
      LEFT JOIN (SELECT DISTINCT REPLACE(REPLACE(LOWER(brand),' ','-'),'''','') AS brand
        FROM ${catalog_product.SQL_TABLE_NAME}
      ) AS b
        ON a.url_key LIKE '%' + b.brand + '%'
      LEFT JOIN (SELECT url_key FROM magento.catalog_category_flat_store_1) AS c
        ON a.url_key LIKE '%' + c.url_key + '%'
      GROUP BY a.visit, a.email, a.url_key, a.page_views
       ;;
    indexes: ["visit", "url_key", "email"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  dimension: url_key {
    type: string
    sql: ${TABLE}.url_key ;;
  }

  dimension: email {
    type: string
    hidden: yes
    sql: ${TABLE}.email ;;
  }

  dimension_group: page_view {
    description: "Date page view was recorded (note that to speed things up this view only contains the last 8 weeks of data)"
    type: time
    timeframes: [date]
    sql: ${TABLE}.visit ;;
  }

  dimension: department {
    hidden: yes
    sql: CASE WHEN ${url_key} LIKE '/womens-%' OR ${url_key} LIKE '%womens' OR ${url_key} LIKE '%-womens-%' THEN 'Women'
           WHEN ${url_key} LIKE '/mens-%' OR ${url_key} LIKE '%mens' OR ${url_key} LIKE '%-mens-%' THEN 'Men'
           WHEN ${url_key} LIKE '/boys-%' OR ${url_key} LIKE '%boys' OR ${url_key} LIKE '%-boys-%' THEN 'Boy'
           WHEN ${url_key} LIKE '/girls-%' OR ${url_key} LIKE '%girls' OR ${url_key} LIKE '%-girls-%' THEN 'Girl' END
       ;;
  }

  dimension: category_plp {
    hidden: yes
    type: yesno
    sql: ${TABLE}.category_plp > 0 ;;
  }

  dimension: brand_plp {
    hidden: yes
    type: yesno
    sql: ${TABLE}.brand_plp > 0 ;;
  }

  dimension: discount_plp {
    hidden: yes
    type: yesno
    sql: ${url_key} LIKE '%__-off%' ;;
  }

  dimension: product_listing_page {
    hidden: yes
    type: yesno
    sql: ${department} IS NOT NULL OR ${brand_plp} OR ${discount_plp} OR ${category_plp} OR ${url_key} = '/new' OR ${url_key} = '/sale-rack' OR ${url_key} = '/shop' ;;
  }

  dimension: checkout {
    hidden: yes
    type: yesno
    sql: (${url_key} LIKE '%checkout%' OR ${url_key} LIKE '%paypal%') AND ${url_key} NOT LIKE '%cart%' ;;
  }

  dimension: cart {
    hidden: yes
    type: yesno
    sql: ${url_key} LIKE '%/cart%' ;;
  }

  dimension: account_dashboard {
    hidden: yes
    type: yesno
    sql: ${url_key} LIKE '%account%' ;;
  }

  dimension: policy_page {
    hidden: yes
    type: yesno
    sql: ${url_key} LIKE '/policies-%' OR ${url_key} LIKE '%-policy%' OR ${url_key} LIKE '%terms-conditions%' ;;
  }

  dimension: home_page {
    hidden: yes
    type: yesno
    sql: ${url_key} = '/' OR ${url_key} = '/index.php' ;;
  }

  dimension: page_type {
    type: string

    case: {
      when: {
        sql: ${product_listing_page} ;;
        label: "Product Listing Page"
      }

      when: {
        sql: ${cart} ;;
        label: "Cart"
      }

      when: {
        sql: ${checkout} ;;
        label: "Checkout"
      }

      when: {
        sql: ${policy_page} ;;
        label: "Policy Page"
      }

      when: {
        sql: ${account_dashboard} ;;
        label: "Account Dashboard"
      }

      when: {
        sql: ${home_page} ;;
        label: "Home"
      }

      when: {
        sql: 1=1 ;;
        label: "Other"
      }
    }
  }

  measure: page_views {
    description: "Number of page views recorded by Snowplow"
    type: sum
    sql: ${TABLE}.page_views ;;
    value_format: "#,##0"
  }

  measure: unique_visitors {
    description: "Number of unique visitors recorded by Snowplow"
    type: count_distinct
    sql: ${TABLE}.email ;;
    value_format: "#,##0"
  }
}
