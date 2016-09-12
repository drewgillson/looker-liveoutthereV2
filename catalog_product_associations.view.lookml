- view: catalog_product_associations
  derived_table: 
    sql: |
      SELECT a.link_id
           , a.parent_id
           , a.product_id
           , b.sku AS parent_sku
           , CASE WHEN c.value = '17215' THEN 'Men' WHEN c.value = '17216' THEN 'Women' WHEN c.value = '17215,17216' OR c.value = '17216,17215' THEN 'Men^Women' WHEN c.value = '17213' THEN 'Boys' WHEN c.value = '17214' THEN 'Girls' WHEN c.value = '17213,17214' OR c.value = '17214,17213' THEN 'Boys^Girls' WHEN c.value = '42206' THEN 'Infant' WHEN c.value = '64480' THEN 'Kids' WHEN c.value = '41763' THEN 'Toddler' END AS department
      FROM magento.catalog_product_super_link AS a
      LEFT JOIN magento.catalog_product_entity AS b
        ON a.parent_id = b.entity_id
      LEFT JOIN magento.catalog_product_entity_varchar AS c
        ON b.entity_id = c.entity_id AND c.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'department' AND entity_type_id = 4)
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
    
  - dimension: configurable_department
    sql: ${TABLE}.department