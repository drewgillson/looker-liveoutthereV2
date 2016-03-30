- view: catalog_product_impressions
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY period) AS row, * FROM (
        SELECT * FROM magento.cgperformance_report_product_views
      ) AS a
    indexes: [product_id, period]
    sql_trigger_value: |
        SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
  
  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension_group: impression
    description: "Date that impressions were recorded for a product"
    type: time
    sql: ${TABLE}.period

  - dimension: product_id
    type: number
    hidden: true
    sql: ${TABLE}.product_id

  - measure: count
    description: "Number of times a Magento product was loaded on the frontend of the website, this includes carousels, PLP, PDP, etc. - anywhere the product is displayed."
    type: sum
    sql: ${TABLE}.views
    
  - measure: conversion_rate
    label: "Conversion Rate %"
    description: "Calculated conversion rate of impressions to orders"
    type: number
    sql: ${sales.orders} / ${count}
    value_format: "0.0%"