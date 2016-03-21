- view: catalog_effective_discounts
  suggestions: false
  # OPENQUERY is used in this view because we always want recent prices from the Magento catalog price index
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY entity_id) AS row, * FROM (
        SELECT entity_id
           , NULLIF(discount,0) AS discount
           , 'Production' AS environment
        FROM OPENQUERY(MAGENTO,'
          SELECT a.entity_id
               , ROUND(1 - (b.final_price / b.price),2) AS discount
          FROM catalog_product_entity AS a
          LEFT JOIN catalog_product_index_price AS b
            ON a.entity_id = b.entity_id AND b.customer_group_id = 0
          WHERE a.type_id = ''simple''
        ') AS x
        UNION ALL
        SELECT entity_id
           , NULLIF(discount,0) AS discount
           , 'Staging' AS environment
        FROM OPENQUERY(STAGING,'
          SELECT a.entity_id
               , ROUND(1 - (b.final_price / b.price),2) AS discount
          FROM catalog_product_entity AS a
          LEFT JOIN catalog_product_index_price AS b
            ON a.entity_id = b.entity_id AND b.customer_group_id = 0
          WHERE a.type_id = ''simple''
        ') AS y
      ) AS z
    indexes: [entity_id]
    persist_for: 8 hours

  fields:

  - dimension: row
    sql: ${TABLE}.row
    primary_key: true
    hidden: true

  - dimension: environment
    description: "Either 'Production' or 'Staging'. This dimension needs to be filtered when you use dimensions or measures from this view, otherwise you will get duplicate results."
    sql: ${TABLE}.environment
    suggestions: ['Production','Staging']

  - measure: count_of_discounted_products
    description: "Unique count of the number of products that are discounted in the Magento catalog"
    type: count_distinct
    sql: CASE WHEN ${discount_in_catalog} IS NOT NULL THEN ${TABLE}.entity_id END
    
  - dimension: has_ranged_pricing
    type: yesno
    sql: ${all_inventory.count_of_available_simple_products} <> ${count_of_discounted_products} AND ${count_of_discounted_products} != 0
    
  - dimension: discount_in_catalog
    description: "Discount in Magento catalog for normal customers"
    sql: ${TABLE}.discount
    value_format: '#%'
    description: "This is the current discount in the catalog for normal customers"
    
  - measure: minimum_discount_in_catalog
    description: "Minimum discount in Magento catalog for normal customers"
    type: min
    sql: ${discount_in_catalog}
    value_format: '#%'
    
  - measure: maximum_discount_in_catalog
    description: "Maximum discount in Magento catalog for normal customers"
    type: max
    sql: ${discount_in_catalog}
    value_format: '#%'

  - measure: average_discount_in_catalog
    description: "Average percentage discount from Magento catalog price index"
    type: avg
    sql: ${discount_in_catalog}
    value_format: '#%'
