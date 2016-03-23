- view: catalog_products
  derived_table:
    sql: |
      SELECT a.sku
           , a.entity_id
           , a.created_at
           , a.updated_at
           , b.value AS colour_code
           , c.value AS style_code
           , CASE WHEN d.value = 'thevan' THEN 'TheVan.ca' ELSE 'LiveOutThere.com' END AS storefront
           , f.value AS carry_over
           , h.value AS colour
           , i.value AS image
           , j.value AS barcode
           , l.value AS size
           , CASE WHEN m.value = '17215' THEN 'Men' WHEN m.value = '17216' THEN 'Women' WHEN m.value = '17215,17216' OR m.value = '17216,17215' THEN 'Men^Women' WHEN m.value = '17213' THEN 'Boy' WHEN m.value = '17214' THEN 'Girl' WHEN m.value = '17213,17214' THEN 'Boy^Girl' WHEN m.value = '42206' THEN 'Infant' END AS department
           , n.value AS product
           , p.value AS brand
           , q.value AS cost
           , r.value AS price
           , t.value AS season
           , v.value AS colour_family
           , MAX(w.parent_id) AS parent_id
           , COUNT(DISTINCT w.parent_id) AS parent_count
           , MIN(CAST(y.value AS int)) AS merchandise_priority
        FROM magento.catalog_product_entity AS a
        LEFT JOIN magento.catalog_product_entity_varchar AS b
          ON a.entity_id = b.entity_id AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'vendor_color_code' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_varchar AS c
          ON a.entity_id = c.entity_id AND c.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'vendor_product_id' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_varchar AS d
          ON a.entity_id = d.entity_id AND d.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'custom_storefront' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_int AS f
          ON a.entity_id = f.entity_id AND f.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'belongs_to_crossover_style' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_int AS g
          ON a.entity_id = g.entity_id AND g.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'choose_color' AND entity_type_id = 4) AND g.store_id = 0
        LEFT JOIN magento.eav_attribute_option_value AS h
          ON g.value = h.option_id AND h.store_id = 0
        LEFT JOIN magento.catalog_product_entity_varchar AS i
          ON a.entity_id = i.entity_id AND i.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'image' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_varchar AS j
          ON a.entity_id = j.entity_id AND j.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'ean' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_int AS k
          ON a.entity_id = k.entity_id AND k.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'choose_size' AND entity_type_id = 4) AND k.store_id = 0
        LEFT JOIN magento.eav_attribute_option_value AS l
          ON k.value = l.option_id AND l.store_id = 0
        LEFT JOIN magento.catalog_product_entity_varchar AS m
          ON a.entity_id = m.entity_id AND m.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'department' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_varchar AS n
          ON a.entity_id = n.entity_id AND n.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'name' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_int AS o
          ON a.entity_id = o.entity_id AND o.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'manufacturer' AND entity_type_id = 4) AND o.store_id = 0
        LEFT JOIN magento.eav_attribute_option_value AS p
          ON o.value = p.option_id AND p.store_id = 0
        LEFT JOIN magento.catalog_product_entity_decimal AS q
          ON a.entity_id = q.entity_id AND q.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'cost' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_decimal AS r
          ON a.entity_id = r.entity_id AND r.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'price' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_int AS s
          ON a.entity_id = s.entity_id AND s.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'season_id' AND entity_type_id = 4) AND s.store_id = 0
        LEFT JOIN magento.eav_attribute_option_value AS t
          ON s.value = t.option_id AND t.store_id = 0
        LEFT JOIN magento.catalog_product_entity_varchar AS u
          ON a.entity_id = u.entity_id AND u.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'color_family' AND entity_type_id = 4) AND u.store_id = 0
        LEFT JOIN magento.eav_attribute_option_value AS v
          ON CASE WHEN u.value LIKE '%,%' THEN LEFT(u.value,CHARINDEX(',',u.value)-1) ELSE u.value END = v.option_id AND v.store_id = 0
        LEFT JOIN magento.catalog_product_super_link AS w
          ON a.entity_id = w.product_id
        LEFT JOIN magento.catalog_product_entity AS x
          ON w.parent_id = x.entity_id
        LEFT JOIN magento.catalog_product_entity_varchar AS y
          ON x.entity_id = y.entity_id AND y.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'merchandise_priority' AND entity_type_id = 4)
        WHERE a.type_id = 'simple'
        AND p.value != 'LiveOutThere.com'
        GROUP BY a.sku, a.created_at, a.updated_at, a.entity_id, b.value, c.value, d.value, f.value, h.value, i.value, j.value, l.value, m.value, n.value, p.value, q.value, r.value, t.value, v.value
    indexes: [sku]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      
  fields:

  - filter: brand_filter
    description: "Will show the brands you specify in the filter along with another row called 'All Other Brands' which represents all the brands that you did not choose grouped together."

  - dimension: entity_id
    hidden: true
    primary_key: true
    value_format: '0'
    sql: ${TABLE}.entity_id

  - dimension: parent_id
    hidden: true
    value_format: '0'
    sql: ${TABLE}.parent_id

  - dimension: sku
    required_fields: entity_id
    sql: ${TABLE}.sku
    description: "SKU for a product with a specific colour and size - what we call a 'simple SKU'. It is one of the core fields that join most of our models."
    links:
      - label: 'Simple Product'
        url: "https://admin.liveoutthere.com/index.php/inspire/advancedstock_products/edit/product_id/{{ inventory.entity_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
      - label: 'Photo'
        url: "https://www.liveoutthere.com/media/catalog/product/{{ inventory.image._value }}"
        icon_url: 'http://icons.iconarchive.com/icons/rade8/minium-2/16/Sidebar-Pictures-icon.png'
        
  - dimension_group: created_at
    description: "Time a product was created in Magento"
    type: time
    sql: ${TABLE}.created_at

  - dimension_group: updated_at
    description: "Time a product was last updated in Magento"
    type: time
    sql: ${TABLE}.updated_at

  - dimension: colour_code
    description: "Colour code for a product"
    sql: ${TABLE}.colour_code

  - dimension: colour
    description: "Colour for a product (i.e. Pink Grapefruit)"
    sql: ${TABLE}.colour

  - dimension: colour_family
    description: "Colour family for a product (i.e. Pink)"
    sql: ${TABLE}.colour_family
    drill_fields: [colour]
    
  - dimension: style_code
    description: "Style code for a product"
    sql: ${TABLE}.style_code
    
  - dimension: image
    hidden: true
    sql: ${TABLE}.image
    
  - dimension: style_color_code
    description: "Concatenated style code and colour code for a product"
    sql: ${TABLE}.style_code + ${TABLE}.colour_code
    drill_fields: [style_code]
    
  - dimension: storefront
    description: "Assigned storefront for a product (either LiveOutThere.com or TheVan.ca)"
    sql: ${TABLE}.storefront
    drill_fields: [brand]

  - dimension: barcode
    description: "Barcode value for a product (even fake barcodes that start with 000000)"
    type: string
    sql: ${TABLE}.barcode
    
  - dimension: gtin
    description: "Real supplier GTIN/UPC for a product (null if we don't know it)"
    label: "GTIN/UPC"
    type: string
    sql: CASE WHEN LEFT(${TABLE}.barcode,5) != '00000' THEN ${TABLE}.barcode END

  - dimension: size
    description: "Size value for a product"
    type: string
    sql: ${TABLE}.size

  - dimension: department
    description: "Department/gender for a product"
    type: string
    sql: ${TABLE}.department
    drill_fields: [brand]

  - dimension: brand
    description: "Brand/manufacturer for a product. Will also show brands selected in the 'Brand Filter' compared to all other brands if desired."
    sql: |
      CASE
        WHEN {% condition brand_filter %} ${TABLE}.brand {% endcondition %}
        THEN ${TABLE}.brand
        ELSE 'All Other Brands'
      END
    drill_fields: [short_product_name, long_product_name, department, colour, colour_family, categories.long_category, categories.short_category]
      
  - dimension: long_product_name
    sql: ISNULL(${brand},'') + ' ' + ISNULL(CASE WHEN ${department} NOT LIKE '%^%' THEN ${department} END,'') + ' ' + ISNULL(${short_product_name},'')
    description: "Long product name, like Arc'teryx Men's Gamma Pants"
    drill_fields: [sku, colour, colour_family, size]
    links:
      - label: 'Configurable Product'
        url: "https://admin.liveoutthere.com/index.php/inspire/catalog_product/edit/id/{{ inventory.parent_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'

  - dimension: short_product_name
    description: "Name of a product"
    type: string
    sql: ${TABLE}.product
    drill_fields: [sku, colour, colour_family, size]
    links:
      - label: 'Configurable Product'
        url: "https://admin.liveoutthere.com/index.php/inspire/catalog_product/edit/id/{{ inventory.parent_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'

  - dimension: has_image
    description: "Will be 'Yes' if a product has an image"
    type: yesno
    sql: ${TABLE}.image != 'no_selection' AND ${TABLE}.image IS NOT NULL
    
  - dimension: has_multiple_configurables
    type: yesno
    sql: ${TABLE}.parent_count > 1

  - dimension: not_associated_to_configurable
    type: yesno
    sql: ${TABLE}.parent_count = 0

  - dimension: cost
    description: "Wholesale cost for a product"
    type: number
    value_format: '$#,##0.00'
    sql: ${TABLE}.cost
      
  - dimension: price
    description: "MSRP/price for a product"
    label: "Price (MSRP)"
    type: number
    value_format: '$#,##0.00'
    sql: ${TABLE}.price

  - dimension: sort_order
    description: "This value is what we use to sort the website PLPs by default"
    type: number
    sql: ${TABLE}.merchandise_priority

  - measure: count_gtin
    description: "Unique count of GTIN/UPCs"
    label: "Count of GTIN/UPC"
    type: count_distinct
    sql: ${gtin}