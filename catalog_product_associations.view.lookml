- view: catalog_product_associations
  derived_table: 
    sql: |
      SELECT a.link_id, a.parent_id, a.product_id, b.sku AS parent_sku
      FROM magento.catalog_product_super_link AS a
      LEFT JOIN magento.catalog_product_entity AS b
        ON a.parent_id = b.entity_id
    indexes: [parent_id, product_id, parent_sku]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:

  - dimension: link_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.link_id
    
  - dimension: configurable_sku
    label: "Configurable SKU"
    sql: ${TABLE}.parent_sku