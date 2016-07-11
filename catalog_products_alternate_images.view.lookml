- view: catalog_products_alternate_images
  derived_table:
    sql: |
      SELECT sku, COUNT(*) - 1 AS count_of_alternate_images FROM (
        SELECT a.sku, NULL AS count_of_alternate_images FROM magento.catalog_product_entity AS a
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt1')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt2')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt3')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt4')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt5')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt6')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt7')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt8')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt9')
        WHERE a.type_id = 'configurable'
        UNION ALL
        SELECT a.sku, b.value AS image FROM magento.catalog_product_entity AS a
        INNER JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.value != 'no_selection' AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image_alt10')
        WHERE a.type_id = 'configurable'
      ) AS x
      GROUP BY sku
    indexes: [sku]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: sku
    primary_key: true
    hidden: true
    sql: ${TABLE}.sku
    
  - dimension: has_alternate_images
    type: yesno
    sql: ${TABLE}.count_of_alternate_images > 0

  - dimension: count_of_alternate_images
    sql: ${TABLE}.count_of_alternate_images
    