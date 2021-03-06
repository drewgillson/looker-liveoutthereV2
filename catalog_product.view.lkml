view: catalog_product {
  derived_table: {
    sql: SELECT a.sku
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
           , CASE WHEN CAST(m.value AS nvarchar(255)) = '17215' THEN 'Men' WHEN CAST(m.value AS nvarchar(255)) = '17216' THEN 'Women' WHEN CAST(m.value AS nvarchar(255)) = '17215,17216' OR CAST(m.value AS nvarchar(255)) = '17216,17215' THEN 'Men^Women' WHEN CAST(m.value AS nvarchar(255)) = '17213' THEN 'Boys' WHEN CAST(m.value AS nvarchar(255)) = '17214' THEN 'Girls' WHEN CAST(m.value AS nvarchar(255)) = '17213,17214' OR CAST(m.value AS nvarchar(255)) = '17214,17213' THEN 'Boys^Girls' WHEN CAST(m.value AS nvarchar(255)) = '42206' THEN 'Infant' WHEN CAST(m.value AS nvarchar(255)) = '64480' THEN 'Kids' WHEN CAST(m.value AS nvarchar(255)) = '41763' THEN 'Toddler' END AS department
           -- strip tabs and line breaks from product names (they cause issues with CSV/TSV exports)
           , LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(COALESCE(n.value,nn.value),CHAR(10),''),CHAR(13),''),CHAR(9),''))) AS product
           , p.value AS brand
           , q.value AS cost
           , r.value AS price
           , t.value AS season
           , CAST(v.value AS nvarchar(255)) AS colour_family
           , MAX(w.parent_id) AS parent_id
           , COUNT(DISTINCT w.parent_id) AS parent_count
           , MIN(CAST(y.value AS int)) AS merchandise_priority
           , COALESCE('/' + za.value + '.html','/' + z.value + '.html') AS url_key
           , DATALENGTH(zb.value) AS description_length
           , zd.value AS budget_type
           , ze.value AS best_use
           , zf.value AS special_price
           , zg.value AS tax_class_id
           , zh.value AS size_code
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
        LEFT JOIN magento.catalog_product_entity_text AS m
          ON a.entity_id = m.entity_id AND m.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'department' AND entity_type_id = 4)
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
        LEFT JOIN magento.catalog_product_entity_text AS u
          ON a.entity_id = u.entity_id AND u.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'color_family' AND entity_type_id = 4) AND u.store_id = 0
        LEFT JOIN magento.eav_attribute_option_value AS v
          -- only join the label value for the first colour family if the varchar table contains a comma-separated string of colour family value IDs
          ON CASE WHEN CAST(u.value AS nvarchar(255)) LIKE '%,%' THEN LEFT(CAST(u.value AS nvarchar(255)),CHARINDEX(',',CAST(u.value AS nvarchar(255)))-1) ELSE CAST(u.value AS nvarchar(255)) END = v.option_id AND v.store_id = 0
        -- then eliminate multiple configurable parents for one simple product (otherwise we get dupes in our result set)
        LEFT JOIN (
          SELECT MAX(parent_id) AS parent_id
               , product_id
          FROM magento.catalog_product_super_link
          GROUP BY product_id
        ) AS w
          ON a.entity_id = w.product_id
        LEFT JOIN magento.catalog_product_entity_varchar AS n
          ON w.parent_id = n.entity_id AND n.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'name' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_varchar AS nn
          ON a.entity_id = nn.entity_id AND nn.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'name' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_varchar AS y
          ON w.parent_id = y.entity_id AND y.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'merchandise_priority' AND entity_type_id = 4)
        -- url_keys are a little funny because sometimes they belong to store_id 0 and sometimes they belong to store_id 1. We want only the first value if there is a value for both stores, so we use a COALESCE in our select
        LEFT JOIN magento.catalog_product_entity_varchar AS z
          ON w.parent_id = z.entity_id AND z.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'url_key' AND entity_type_id = 4)
          AND z.store_id = 0
        LEFT JOIN magento.catalog_product_entity_varchar AS za
          ON w.parent_id = za.entity_id AND za.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'url_key' AND entity_type_id = 4)
          AND za.store_id = 1
        LEFT JOIN magento.catalog_product_entity_text AS zb
          ON w.parent_id = zb.entity_id AND zb.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'description' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_int AS zc
          ON a.entity_id = zc.entity_id AND zc.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'budget_type' AND entity_type_id = 4) AND zc.store_id = 0
        LEFT JOIN magento.eav_attribute_option_value AS zd
          ON zc.value = zd.option_id AND zd.store_id = 0
        LEFT JOIN magento.catalog_product_entity_varchar AS ze
          ON w.parent_id = ze.entity_id AND ze.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'best_use' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_decimal AS zf
          ON a.entity_id = zf.entity_id AND zf.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'special_price' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_int AS zg
          ON a.entity_id = zg.entity_id AND zg.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'tax_class_id' AND entity_type_id = 4)
        LEFT JOIN magento.catalog_product_entity_varchar AS zh
          ON a.entity_id = zh.entity_id AND zh.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'vendor_size_code' AND entity_type_id = 4)
        WHERE a.type_id IN ('simple','ugiftcert','giftcert','giftvoucher')
        GROUP BY a.sku, a.created_at, a.updated_at, a.entity_id, b.value, c.value, d.value, f.value, h.value, i.value, j.value, l.value, CAST(m.value AS nvarchar(255)), n.value, nn.value, p.value, q.value, r.value, t.value, CAST(v.value AS nvarchar(255)), z.value, za.value, DATALENGTH(zb.value), zd.value, ze.value, zf.value, zg.value, zh.value
        UNION ALL
        -- this line allows us to join the Products explore to Sales & Credits even if a product no longer exists, we use -1 as a substitute product ID (this helps us keep our Explores simple for end-users)
        SELECT NULL, -1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, NULL
      ;;
    indexes: ["sku", "entity_id", "url_key"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  filter: brand_filter {
    description: "Will show the brands you specify in the filter along with another row called 'All Other Brands' which represents all the brands that you did not choose grouped together."
  }

  dimension: entity_id {
    hidden: yes
    primary_key: yes
    value_format: "0"
    sql: ${TABLE}.entity_id ;;
  }

  dimension: parent_id {
    hidden: yes
    value_format: "0"
    sql: ${TABLE}.parent_id ;;
  }

  dimension_group: created_at {
    description: "Time a product was created in Magento"
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: updated_at {
    description: "Time a product was last updated in Magento"
    type: time
    sql: ${TABLE}.updated_at ;;
  }

  dimension: colour_code {
    description: "Colour code for a product"
    sql: ${TABLE}.colour_code ;;
  }

  dimension: size_code {
    description: "Size code for a product"
    sql: ${TABLE}.size_code ;;
  }

  dimension: colour {
    description: "Colour for a product (i.e. Pink Grapefruit)"
    sql: ${TABLE}.colour ;;
  }

  dimension: colour_family {
    description: "Colour family for a product (i.e. Pink)"
    sql: ${TABLE}.colour_family ;;
    drill_fields: [colour]
  }

  dimension: style_code {
    description: "Style code for a product"
    sql: ${TABLE}.style_code ;;
  }

  dimension: best_use {
    description: "'Best Use' attribute value for a product"
    sql: ${TABLE}.best_use ;;
  }

  dimension: image {
    hidden: yes
    sql: ${TABLE}.image ;;
  }

  dimension: style_color_code {
    description: "Concatenated style code and colour code for a product"
    sql: ${TABLE}.style_code + ${TABLE}.colour_code ;;
    drill_fields: [style_code]
  }

  dimension: storefront {
    description: "Assigned storefront for a product (either LiveOutThere.com or TheVan.ca)"
    sql: ${TABLE}.storefront ;;
    drill_fields: [brand]
  }

  dimension: barcode_known {
    type: yesno
    sql: ${gtin} IS NOT NULL ;;
  }

  dimension: barcode {
    description: "Identical to GTIN dimension"
    type: string
    sql: ${gtin} ;;
  }

  dimension: budget_type {
    description: "Budget type of product"
    type: string
    sql: ${TABLE}.budget_type ;;
    drill_fields: [department]
  }

  dimension: gtin {
    description: "Real supplier GTIN/UPC for a product (null if we don't know it)"
    label: "GTIN/UPC"
    type: string
    sql: CASE WHEN LEFT(${TABLE}.barcode,5) != '00000' THEN ${TABLE}.barcode END ;;
  }

  dimension: size {
    description: "Size value for a product"
    type: string
    sql: ${TABLE}.size ;;
  }

  dimension: department {
    description: "Department/gender for a product"
    type: string
    sql: ${TABLE}.department ;;
    drill_fields: [categories.category_1]
  }

  dimension: url_key {
    description: "URL key for a product"
    type: string
    sql: ${TABLE}.url_key ;;
  }

  dimension: is_virtual_product {
    description: "Is 'Yes' if the product has a brand value of LiveOutThere.com, which we use for gift cards, promo items, etc."
    type: yesno
    sql: ${TABLE}.brand = 'Live Out There' ;;
  }

  dimension: has_description {
    description: "Is 'Yes' if the product has a value in the description attribute"
    type: yesno
    sql: ${TABLE}.description_length > 0 AND ${TABLE}.description_length IS NOT NULL ;;
  }

  measure: unique_brands {
    type: count_distinct
    sql: ${TABLE}.brand ;;
  }

  dimension: brand {
    description: "Brand/manufacturer for a product. Will also show brands selected in the 'Brand Filter' compared to all other brands if desired."
    sql: CASE
        WHEN {% condition brand_filter %} ${TABLE}.brand {% endcondition %}
        THEN ${TABLE}.brand
        ELSE 'All Other Brands'
      END
       ;;
    drill_fields: [catalog_product_links.short_product_name, catalog_product_links.long_product_name, department, colour, colour_family, categories.long_category, categories.short_category, purchase_orders.order_number]
  }

  dimension: has_image {
    description: "Will be 'Yes' if a product has an image"
    type: yesno
    sql: ${TABLE}.image != 'no_selection' AND ${TABLE}.image IS NOT NULL ;;
  }

  dimension: has_multiple_configurables {
    type: yesno
    sql: ${TABLE}.parent_count > 1 ;;
  }

  dimension: not_associated_to_configurable {
    type: yesno
    sql: ${TABLE}.parent_count = 0 ;;
  }

  dimension: associated_to_configurable {
    type: yesno
    sql: ${TABLE}.parent_count > 0 ;;
  }

  dimension: cost {
    description: "Wholesale cost for a product"
    type: number
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.cost ;;
  }

  dimension: price {
    description: "MSRP/price for a product"
    label: "Price (MSRP) $"
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.price ;;
  }

  dimension: special_price {
    description: "Special price for a product"
    label: "Special Price $"
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.special_price ;;
  }

  dimension: tax_class {
    case: {
      when: {
        label: "None"
        sql: ${TABLE}.tax_class_id = 0 ;;
      }
      when: {
        label: "Taxable Goods"
        sql: ${TABLE}.tax_class_id = 2 ;;
      }
      when: {
        label: "Shipping"
        sql: ${TABLE}.tax_class_id = 4 ;;
      }
      when: {
        label: "Children's Clothing & Footwear"
        sql: ${TABLE}.tax_class_id = 5 ;;
      }
      else: ""
    }
  }

  measure: average_price {
    description: "Average MSRP/price for a product"
    label: "Average Price (MSRP) $"
    type: average
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.price ;;
  }

  dimension: sort_order {
    description: "This value is what we use to sort the website PLPs by default"
    type: number
    sql: ${TABLE}.merchandise_priority ;;
  }

  measure: count_gtin {
    description: "Unique count of GTIN/UPCs"
    label: "Count of GTIN/UPC"
    type: count_distinct
    sql: ${gtin} ;;
  }

  measure: count_style_colours {
    label: "Count of Style/Colours"
    description: "Unique count of style/colours"
    type: count_distinct
    sql: ${style_color_code} ;;
  }

  dimension: is_map_brand {
    label: "Is MAP Brand"
    type: yesno
    sql: ${TABLE}.brand IN ('Thule',
                   '2Undr',
                   '7Seasons',
                   'Arc''teryx',
                   'Add',
                   'Belstaff',
                   'Bogs',
                   'Brooks',
                   'CMFR',
                   'Colmar Orginals',
                   'Converse',
                   'CP Company',
                   'Denham',
                   'Filson',
                   'Fjallraven',
                   'Hanwag',
                   'Hoka OneOne',
                   'Honns',
                   'Hunter',
                   'Hurley',
                   'Icebreaker',
                   'Indygena',
                   'InReach',
                   'Jansport',
                   'Laundromat',
                   'Mackage',
                   'Mammut',
                   'Merrell',
                   'Michael Kors',
                   'Nike',
                   'Oakley',
                   'Parajumpers',
                   'Patagonia',
                   'Petzl',
                   'Polar',
                   'Rab',
                   'Repeat',
                   'Sanuk',
                   'Saucony',
                   'SAXX',
                   'Smith Optics',
                   'SOIA & KYO',
                   'Spiritual Gangster',
                   'UGG',
                   'Umi',
                   'Under Armour',
                   'United By Blue',
                   'Vasque',
                   'Vince',
                   'White + Warren',
                   'Woolrich John Rich & Bros',
                   'Zanerobe M')
 ;;
  }

  dimension: is_kids_brand {
    label: "Is Kids"
    type: yesno
    sql: ${TABLE}.department IN ('Boys','Girls','Boys^Girls','Toddler','Infant','Kids')
      ;;
  }
}
