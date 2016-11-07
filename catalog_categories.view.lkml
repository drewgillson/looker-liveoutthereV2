view: catalog_categories {
  derived_table: {
    # the magic number in the WHERE clause (entity_id = 2261) is for the Root category,
    # and NOT IN (11358,2237,8779) excludes eGift Cards, Uncategorized, Campaigns, and Door Crashers
    sql: SELECT DISTINCT a.product_id
         , a.category_name AS raw_category_path
         , b.inventory_type
         , b.reporting_category_level1
         , b.reporting_category_level2
         , b.reporting_category_level3
         , b.reporting_category_level4
         , b.reporting_category_level5
         , ROW_NUMBER() OVER (PARTITION BY a.product_id ORDER BY LEN(a.category_name) DESC) AS sequence
      FROM (
        SELECT DISTINCT REPLACE(b.name + ISNULL('/' + c.name,'') + ISNULL('/' + d.name,''),'LiveOutThere.com/','') AS category_name
           , f.entity_id AS product_id
        FROM magento.catalog_category_flat_store_1 AS a
        LEFT JOIN magento.catalog_category_flat_store_1 AS b
          ON b.parent_id = a.entity_id AND b.entity_id NOT IN (11358,2237,8779,11425)
        LEFT JOIN magento.catalog_category_flat_store_1 AS c
          ON c.parent_id = b.entity_id AND c.entity_id NOT IN (11358,2237,8779,11425)
        LEFT JOIN magento.catalog_category_flat_store_1 AS d
          ON d.parent_id = COALESCE(c.entity_id,b.entity_id)
        LEFT JOIN magento.catalog_category_product AS e
          ON e.category_id = COALESCE(d.entity_id,c.entity_id,b.entity_id,a.entity_id)
        LEFT JOIN magento.catalog_product_entity AS f
          ON e.product_id = f.entity_id
        WHERE (a.entity_id = 2261 OR a.entity_id = 1)
      ) AS a
      LEFT JOIN lut_Messy_Category_Data AS b
        ON a.category_name = b.category
       ;;
    indexes: ["product_id", "inventory_type", "reporting_category_level1", "reporting_category_level2"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: product_id {
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: sequence {
    description: "Use this sequence dimension to remove duplicate categories from your looks, by filtering this dimension to 1, you can only show the 'longest' category for a product, which is usually the most specific category as well."
    type: number
    value_format: "0"
    sql: ${TABLE}.sequence ;;
  }

  dimension: is_categorized {
    description: "Does the product belong to a category in our master list of categories?"
    type: yesno
    sql: ${short_category} IS NOT NULL ;;
  }

  dimension: inventory_type {
    description: "Either Apparel, Gear, or Footwear"
    sql: ${TABLE}.inventory_type ;;
    drill_fields: [short_category, long_category, products.brand]
  }

  dimension: raw_category_path {
    description: "The raw category value from Magento, this may or may not match to a category in our master list, so if this has a value but the other dimensions are NULL, a row needs to be added to lut_Messy_Category_Data."
    sql: ${TABLE}.raw_category_path ;;
  }

  dimension: category_1 {
    description: "i.e. Gear"
    label: "1st-Level Category"
    sql: ${TABLE}.reporting_category_level1 ;;
    drill_fields: [long_category, category_2, products.brand]
  }

  dimension: category_2 {
    description: "i.e. Equipment"
    label: "2nd-Level Category"
    sql: ${TABLE}.reporting_category_level2 ;;
    drill_fields: [category_3, products.brand]
  }

  dimension: category_3 {
    description: "i.e. Poles"
    label: "3rd-Level Category"
    sql: ${TABLE}.reporting_category_level3 ;;
    drill_fields: [category_4, products.brand]
  }

  dimension: category_4 {
    description: "i.e. Ski Poles"
    label: "4th-Level Category"
    sql: ${TABLE}.reporting_category_level4 ;;
    drill_fields: [category_5, products.brand]
  }

  dimension: category_5 {
    description: "i.e. Collapsible Ski Poles"
    label: "5th-Level Category"
    sql: ${TABLE}.reporting_category_level5 ;;
  }

  dimension: long_category {
    description: "i.e. Accessories/Mitts/Waterproof Mitts"
    sql: ${category_1} + ISNULL('/' + NULLIF(${category_2},''),'') + ISNULL('/' + NULLIF(${category_3},''),'') + ISNULL('/' + NULLIF(${category_4},''),'') + ISNULL('/' + NULLIF(${category_5},''),'') ;;
    drill_fields: [inventory.brand, inventory.short_product_name, products.long_product_name, products.brand]
  }

  dimension: short_category {
    description: "i.e. Accessories/Mitts"
    sql: ${category_1} + ISNULL('/' + NULLIF(${category_2},''),'') ;;
    drill_fields: [long_category, products.brand, products.long_product_name]
  }
}
