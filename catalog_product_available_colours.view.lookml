- view: catalog_product_available_colours
  derived_table:
    sql: |
      SELECT sku AS configurable_sku, count_colors, count_colors_in_stock
      FROM (
        SELECT sku
           , COUNT(DISTINCT color) AS count_colors
           , COUNT(DISTINCT CASE WHEN qty > 0 THEN color END) AS count_colors_in_stock
        FROM (
          SELECT a.sku
           , d.value AS color
           , SUM(s.qty) - SUM(s.stock_reserved_qty) AS qty
          FROM magento.catalog_product_entity AS a
          LEFT JOIN magento.catalog_product_super_link AS b
            ON a.entity_id = b.parent_id
          INNER JOIN magento.cataloginventory_stock_item AS s ON b.product_id = s.product_id
          LEFT JOIN magento.catalog_product_entity_int AS c
            ON b.product_id = c.entity_id AND c.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'choose_color' AND entity_type_id = 4)
          LEFT JOIN magento.eav_attribute_option_value AS d
            ON c.value = d.option_id AND d.store_id = 0
          WHERE a.type_id = 'configurable'
          GROUP BY a.sku, d.value
        ) AS x
        GROUP BY sku
      ) AS a

  fields:
  
  - dimension: configurable_sku
    primary_key: true
    hidden: true
    sql: ${TABLE}.configurable_sku

  - measure: total
    type: sum
    sql: ${TABLE}.count_colors

  - measure: in_stock
    type: sum
    sql: ${TABLE}.count_colors_in_stock

  - measure: percentage_of_colors_in_stock
    label: "% of Colors in Stock"
    type: number
    sql: CAST(${in_stock} AS float) / ${total}
    value_format: "0.00%"