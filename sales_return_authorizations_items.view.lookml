- view: sales_return_authorizations_items
  derived_table:
    sql: |
      SELECT a.id
        , a.entity_id AS rma_entity_id
        , a.product_id
        , a.qty
        , b.sku
      FROM magento.aw_rma_entity_items AS a
      LEFT JOIN magento.sales_flat_order_item AS b
        ON a.product_id = b.item_id
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    indexes: [rma_entity_id]

  fields:
  
  - dimension: id
    primary_key: true
    hidden: true
    sql: ${TABLE}.id

  - dimension: rma_entity_id
    type: number
    sql: ${TABLE}.rma_entity_id
    hidden: true

  - dimension: product_id
    type: number
    sql: ${TABLE}.product_id
    hidden: true

  - dimension: sku
    label: "SKU"
    type: string
    sql: ${TABLE}.sku

  - measure: returning_quantity
    type: sum
    sql: ${TABLE}.qty