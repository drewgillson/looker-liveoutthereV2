- view: catalog_product_impressions
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY period) AS row, * FROM (
        SELECT a.*, COALESCE('/' + b.value + '.html','/' + c.value + '.html') AS url_key FROM magento.cgperformance_report_product_views AS a
        LEFT JOIN magento.catalog_product_entity_varchar AS b
          ON a.product_id = b.entity_id AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'url_key' AND entity_type_id = 4)
          AND b.store_id = 0
        LEFT JOIN magento.catalog_product_entity_varchar AS c
          ON a.product_id = c.entity_id AND c.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'url_key' AND entity_type_id = 4)
          AND c.store_id = 1
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

  - dimension: url_key
    type: string
    hidden: true
    sql: ${TABLE}.url_key

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
    sql: 100.00 * (${sales.orders} / ${count})
    value_format: '#.00\%'