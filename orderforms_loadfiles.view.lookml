- view: orderforms_loadfiles
  sql_table_name:  orderform.loadfiles

  fields:
  
  - dimension: id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.id

  - dimension: sku
    type: string
    sql: ${TABLE}.sku

  - dimension: concatenated_name
    type: string
    sql: ${brand} + ' ' + CASE WHEN ${department} != 'Unisex' THEN ${department} + '''s ' ELSE '' END + ${name}

  - dimension: name
    type: string
    sql: REPLACE(${TABLE}.name,'"','')

  - dimension: category
    type: string
    sql: ${TABLE}.category
    drill_fields: [category_level_1, brand]
    
  - dimension: category_level_1
    type: string
    sql: LEFT(${category},CHARINDEX('/',${category})-1)
    drill_fields: [category_level_2, brand]

  - dimension: category_level_2
    type: string
    sql: SUBSTRING(${category},LEN(${category_level_1})+2,CASE WHEN CHARINDEX('/',${category},LEN(${category_level_1})+2) > 0 THEN CHARINDEX('/',${category},LEN(${category_level_1})+2) - LEN(${category_level_1}) - 2 ELSE 255 END)
    drill_fields: [category_level_3, brand]

  - dimension: category_level_3
    type: string
    sql: SUBSTRING(${category},LEN(${category_level_1} + '/' + ${category_level_2})+2,CASE WHEN CHARINDEX('/',${category},LEN(${category_level_1} + '/' + ${category_level_2})+2) > 0 THEN CHARINDEX('/',${category},LEN(${category_level_1} + '/' + ${category_level_2})+2) - LEN(${category_level_1} + '/' + ${category_level_2}) - 2 ELSE 255 END)

  - dimension: price
    type: number
    value_format: "$#,##0.00"
    sql: REPLACE(${TABLE}.price,'$','')

  - dimension: cost
    type: number
    value_format: "$#,##0.00"
    sql: REPLACE(${TABLE}.cost,'$','')

  - dimension: department
    type: string
    sql: ${TABLE}.department
    drill_fields: [category, brand]

  - dimension: size
    type: string
    sql: ${TABLE}.choose_size

  - dimension: size_curve
    type: string
    sql: ${TABLE}.chosen_size_curve

  - dimension: colour
    type: string
    sql: ${TABLE}.choose_color

  - dimension: vendor_colour_code
    type: string
    sql: ${TABLE}.vendor_color_code

  - dimension: colour_family
    type: string
    sql: ${TABLE}.color_family

  - dimension: vendor_style_code
    type: string
    sql: ${TABLE}.vendor_product_id

  - dimension: brand
    type: string
    sql: ${TABLE}.manufacturer
    drill_fields: [category, department]

  - dimension: budget_type
    type: string
    sql: |
      CASE WHEN ${TABLE}.budget_type IS NOT NULL THEN ${TABLE}.budget_type
           WHEN ${source_sheet} = 'Fashion' THEN 'Fashion'
           WHEN ${source_sheet} = 'Kids' THEN 'Kids'
           WHEN ${category} LIKE '%Footwear%' THEN 'Footwear'
           WHEN ${category} LIKE '%Gear%' THEN 'Gear'
           ELSE 'Apparel'
      END
    drill_fields: [category, brand, department]

  - dimension: brand_logo
    type: string
    sql: |
      'https://www.liveoutthere.com/skin/frontend/liveoutthere/default/images/brand/logos/' + LOWER(REPLACE(REPLACE(${brand},' ',''),'''','')) + '/logo-small.png'
    html: <img src="{{ value }}"/>

  - dimension: source_sheet
    type: string
    sql: ${TABLE}.source_sheet
    
  - measure: styles_on_order
    type: count_distinct
    sql: ${concatenated_name}

  - measure: colours_on_order
    label: "Style/Colours on Order"
    type: count_distinct
    sql: ${concatenated_name} + ${colour}

  - measure: skus_on_order
    label: "SKUs on Order"
    type: count_distinct
    sql: ${concatenated_name} + ${colour} + ${size}

  sets:
    detail:
      - sku
      - name
      - category
      - price
      - cost
      - department
      - size
      - size_curve
      - colour
      - vendor_colour_code
      - colour_family
      - vendor_product_id
      - season_id
      - manufacturer