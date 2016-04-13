- view: sales_return_authorizations
  derived_table:
    sql: |
      SELECT a.id
        , a.created_at
        , a.order_id AS increment_id
        , CAST(d.track_number AS varchar(255)) AS track_number
        , CAST(SUM(f.qty) / COUNT(DISTINCT a.id) AS int) AS items_refunded
        , 'Canada Post' AS return_service
      FROM magento.aw_rma_entity AS a
      LEFT JOIN magento.sales_flat_order AS b
        ON a.order_id = b.increment_id
      LEFT JOIN magento.sales_flat_shipment AS c
        ON b.entity_id = c.order_id
      LEFT JOIN magento.sales_flat_shipment_track AS d
        ON c.entity_id = d.parent_id
      LEFT JOIN magento.sales_flat_creditmemo AS e
        ON b.entity_id = e.order_id
      LEFT JOIN magento.sales_flat_creditmemo_item AS f
        ON e.entity_id = f.parent_id
      WHERE (d.title LIKE 'Return%' OR d.title IS NULL)
      GROUP BY a.id, a.created_at, a.order_id, CAST(d.track_number AS varchar(255))
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    indexes: [increment_id]
    
  fields:
  
  - dimension: id
    primary_key: true
    hidden: true
    sql: ${TABLE}.id
  
  - measure: count
    type: count
    drill_fields: detail*

  - dimension_group: created
    type: time
    sql: ${TABLE}.created_at

  - dimension: increment_id
    type: number
    sql: ${TABLE}.increment_id
    
  - dimension: return_service
    type: string
    sql: ${TABLE}.return_service

  - dimension: track_number
    type: string
    sql: CAST(${TABLE}.track_number AS varchar(255))

  - measure: items_refunded
    type: sum
    sql: ${TABLE}.items_refunded
    
  - measure: orders_refunded
    type: sum
    sql: |
      CASE WHEN ${TABLE}.items_refunded > 1 THEN 1 ELSE ${TABLE}.items_refunded END