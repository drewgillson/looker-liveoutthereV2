- view: akeneo_option_values
  derived_table: 
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY sku) AS row, a.best_use, b.parent_id
      FROM OPENQUERY(AKENEO,'SELECT f.value_string AS sku
                                  , GROUP_CONCAT(e.value SEPARATOR '', '') AS best_use
                             FROM pim_catalog_product AS a
                             INNER JOIN pim_catalog_product_value AS b
                               ON a.id = b.entity_id AND b.attribute_id = (SELECT id FROM pim_catalog_attribute WHERE code = ''best_use'')
                             INNER JOIN pim_catalog_product_value_option AS c
                               ON b.id = c.value_id
                             INNER JOIN pim_catalog_attribute_option AS d
                               ON c.option_id = d.id
                             INNER JOIN pim_catalog_attribute_option_value AS e
                               ON d.id = e.option_id AND e.locale_code = ''en_US''
                             INNER JOIN pim_catalog_product_value AS f
                               ON a.id = f.entity_id AND f.attribute_id = (SELECT id FROM pim_catalog_attribute WHERE code = ''sku'')
                             GROUP BY sku') AS a
      LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS b
        ON a.sku = b.parent_sku
    indexes: [parent_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    hidden: true
    primary_key: true
    sql: ${TABLE}.row

  - dimension: best_use
    sql: ${TABLE}.best_use