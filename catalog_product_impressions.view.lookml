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
    type: time
    sql: ${TABLE}.period

  - dimension: product_id
    type: number
    hidden: true
    sql: ${TABLE}.product_id

  - measure: impressions
    type: sum
    sql: ${TABLE}.views