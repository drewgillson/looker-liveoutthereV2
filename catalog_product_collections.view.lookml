
- view: catalog_product_collections
  derived_table:
    sql: |
      SELECT DISTINCT d.sku AS sku, collections.value FROM (
        SELECT a.option_id, b.value FROM magento.eav_attribute_option AS a
        LEFT JOIN magento.eav_attribute_option_value AS b
        ON a.option_id = b.option_id
        WHERE a.attribute_id = 327 AND b.store_id = 0
      ) AS collections
      LEFT JOIN magento.catalog_product_entity_varchar AS a
      ON a.value LIKE '%' + CAST(collections.option_id AS varchar(10)) + '%'
      LEFT JOIN magento.catalog_product_entity AS b
      ON a.entity_id = b.entity_id
      LEFT JOIN magento.catalog_product_super_link AS c
      ON a.entity_id = c.parent_id
      LEFT JOIN magento.catalog_product_entity AS d
      ON c.product_id = d.entity_id
      WHERE a.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'collections' AND entity_type_id = 4)
      AND d.sku IS NOT NULL
    indexes: [sku, value]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: sku
    type: string
    primary_key: true
    hidden: true
    sql: ${TABLE}.sku

  - dimension: value
    type: string
    sql: ${TABLE}.value