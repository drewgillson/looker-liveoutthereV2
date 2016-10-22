- view: sales_order_sequence
  derived_table:
    sql: |
      SELECT sales.email, sales.order_entity_id, ROW_NUMBER() OVER
      (
         PARTITION BY sales.email
         ORDER BY sales.order_created
      ) AS sequence
      FROM ${sales_items.SQL_TABLE_NAME} AS sales

  fields:

   - dimension: order_entity_id
     type: number
     primary_key: true
     hidden: true
     sql: ${TABLE}.order_entity_id
  
   - dimension: number
     type: number
     sql: ${TABLE}.sequence
     
   - dimension: new_or_repeat
     label: "New or Repeat Customer"
     type: string
     sql: |
      CASE WHEN ${number} = 1 THEN 'New' WHEN ${number} > 1 THEN 'Repeat' END
