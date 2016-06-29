- view: catalog_products_links
  extends: catalog_products
  
  fields:
  
  - dimension: sku
    required_fields: entity_id
    sql: ${TABLE}.sku
    description: "SKU for a product with a specific colour and size - what we call a 'simple SKU'. It is one of the core fields that join most of our models."
    links:
      - label: 'Simple Product'
        url: "https://admin.liveoutthere.com/index.php/inspire/advancedstock_products/edit/product_id/{{ products.entity_id._value | encode_uri }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
      - label: 'Photo'
        url: "https://www.liveoutthere.com/media/catalog/product/{{ products.image._value }}"
        icon_url: 'http://icons.iconarchive.com/icons/rade8/minium-2/16/Sidebar-Pictures-icon.png'
        
  - dimension: long_product_name
    sql: ISNULL(${brand},'') + ' ' + ISNULL(CASE WHEN ${department} NOT LIKE '%^%' THEN ${department} END,'') + ' ' + ISNULL(${short_product_name},'')
    description: "Long product name, like Arc'teryx Men's Gamma Pants"
    drill_fields: [sku, colour, colour_family, size]
    links:
      - label: 'Configurable Product'
        url: "https://admin.liveoutthere.com/index.php/inspire/catalog_product/edit/id/{{ products.parent_id._value | encode_uri }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'

  - dimension: short_product_name
    description: "Name of a product"
    type: string
    sql: ${TABLE}.product
    drill_fields: [sku, colour, colour_family, size]
    links:
      - label: 'Configurable Product'
        url: "https://admin.liveoutthere.com/index.php/inspire/catalog_product/edit/id/{{ products.parent_id._value | encode_uri }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
        
  - measure: count_of_styles
    type: count_distinct
    sql: ${TABLE}.parent_id
    
  - measure: count_of_skus
    label: "Count of SKUS"
    type: count_distinct
    sql: ${TABLE}.sku
    
  - measure: percent_of_total
    type: percent_of_total
    sql: ${count_of_skus}
    
