- view: catalog_akeneo_option_values
  derived_table: 
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY a.parent_id) AS row
        , a.parent_id
        , b.best_use
        , c.fit

      FROM ${catalog_product_associations.SQL_TABLE_NAME} AS a
      
      -- this subselect is a template for multi-value options from Akeneo, like Best Use
      LEFT JOIN OPENQUERY(AKENEO,'SELECT f.value_string AS sku
                                    , GROUP_CONCAT(e.value ORDER BY e.value SEPARATOR '', '') AS best_use
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
                                  GROUP BY sku
      ') AS b
      ON a.parent_sku = b.sku
      
      -- and this subselect can be used for single-value options, like Fit
      LEFT JOIN OPENQUERY(AKENEO,'SELECT f.value_string AS sku
                                    , e.value AS fit
                                  FROM pim_catalog_product AS a
                                  INNER JOIN pim_catalog_product_value AS b
                                    ON a.id = b.entity_id AND b.attribute_id = (SELECT id FROM pim_catalog_attribute WHERE code = ''fit'')
                                  INNER JOIN pim_catalog_attribute_option AS d
                                    ON b.option_id = d.id
                                  INNER JOIN pim_catalog_attribute_option_value AS e
                                    ON d.id = e.option_id AND e.locale_code = ''en_US''
                                  INNER JOIN pim_catalog_product_value AS f
                                    ON a.id = f.entity_id AND f.attribute_id = (SELECT id FROM pim_catalog_attribute WHERE code = ''sku'')
      ') AS c
      ON a.parent_sku = c.sku

      GROUP BY a.parent_id, b.best_use, c.fit
    indexes: [parent_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)