- view: catalog_product_page_views_filtered
  derived_table:
    sql: |
      SELECT * FROM ${catalog_product_page_views.SQL_TABLE_NAME}
      WHERE {% condition sales.order_created_date %} visit {% endcondition %}

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: url_key
    type: string
    hidden: true
    sql: ${TABLE}.url_key

  - measure: count
    description: "Number of unique page views recorded by Snowplow for the period defined by the filter on Sales > Order Created"
    type: sum
    sql: ${TABLE}.page_views
    value_format: "0"
    
  - measure: conversion_rate
    label: "Conversion Rate %"
    description: "Calculated conversion rate of page views to orders for the period defined by the filter on Sales > Order Created"
    type: number
    sql: 100.00 * (${sales.orders} / NULLIF(${count},0))
    value_format: '#.00\%'
