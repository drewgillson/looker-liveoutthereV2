# This view is specifically for Anshuman to get collection values that are formatted like CollectionA^CollectionB^CollectionC to make it easier to work with
view: catalog_product_collections_flattened {
  derived_table: {
    sql: SELECT sku, CAST(value AS varchar(max)) AS value FROM OPENQUERY(MAGENTO,'SELECT sku, GROUP_CONCAT(value SEPARATOR ''^'') AS value FROM (SELECT DISTINCT d.sku AS sku, collections.value FROM (
        SELECT a.option_id, b.value FROM eav_attribute_option AS a
        LEFT JOIN eav_attribute_option_value AS b
        ON a.option_id = b.option_id
        WHERE a.attribute_id = 327 AND b.store_id = 0
      ) AS collections
      LEFT JOIN catalog_product_entity_text AS a
      ON a.value LIKE CONCAT(''%'',CAST(collections.option_id AS CHAR(50)),''%'')
      LEFT JOIN catalog_product_entity AS b
      ON a.entity_id = b.entity_id
      LEFT JOIN catalog_product_super_link AS c
      ON a.entity_id = c.parent_id
      LEFT JOIN catalog_product_entity AS d
      ON c.product_id = d.entity_id
      WHERE a.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = ''collections'' AND entity_type_id = 4)
      AND d.sku IS NOT NULL) AS x GROUP BY sku')
       ;;
    indexes: ["sku"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: sku {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.sku ;;
  }

  dimension: value {
    type: string
    drill_fields: [products.brand, products.department, products.long_product_name, categories.short_category, associations.configurable_sku]
    sql: ${TABLE}.value ;;
  }
}
