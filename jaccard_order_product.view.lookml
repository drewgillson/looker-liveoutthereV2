- view: jaccard_order_product
  derived_table:
    sql: |
      SELECT p.product
      , COUNT(DISTINCT p.product + CAST(oi.order_entity_id AS varchar(20))) AS frequency
      FROM ${sales_items.SQL_TABLE_NAME} AS oi
      JOIN ${catalog_products.SQL_TABLE_NAME} AS p
        ON oi.product_id = p.entity_id
      GROUP BY p.product
    indexes: [product]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  
  - dimension: frequency
    type: number
    sql: ${TABLE}.frequency