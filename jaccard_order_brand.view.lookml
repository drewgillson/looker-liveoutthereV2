- view: jaccard_order_brand
  derived_table:
    sql: |
      SELECT p.brand
      , COUNT(DISTINCT p.brand + CAST(oi.order_entity_id AS varchar(20))) AS frequency
      FROM ${sales_items.SQL_TABLE_NAME} AS oi
      JOIN ${catalog_product.SQL_TABLE_NAME} AS p
        ON oi.product_id = p.entity_id
      GROUP BY p.brand
    indexes: [brand]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  
  - dimension: frequency
    type: number
    sql: ${TABLE}.frequency