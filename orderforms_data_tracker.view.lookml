
- view: orderforms_data_tracker
  derived_table:
    sql: |
      SELECT [id]
        , [On Orders Brand] AS brand
        , [Brand Logo File] AS has_logo
        , [Product Copy] AS has_product_copy
        , [Product Imagery] AS has_images
        , [Item Master] AS has_item_master
        , [season]
        , CASE WHEN [Brand Logo File] IN ('Yes','NA') THEN 0.25 ELSE 0.00 END AS has_logo_status
        , CASE WHEN [Product Copy] IN ('Yes','NA') THEN 0.25 ELSE 0.00 END AS has_product_copy_status
        , CASE WHEN [Product Imagery] IN ('Yes','NA') THEN 0.25 ELSE 0.00 END AS has_images_status
        , CASE WHEN [Item Master] IN ('Yes','NA') THEN 0.25 ELSE 0.00 END AS has_item_master_status
      FROM orderform.data_tracker
    indexes: [brand, season]
    persist_for: 5 minutes

  fields:

  - dimension: id
    primary_key: true
    type: number
    sql: ${TABLE}.id

  - dimension: brand
    type: string
    sql: ${TABLE}.brand

  - dimension: has_logo
    type: string
    sql: ${TABLE}.has_logo

  - dimension: has_product_copy
    type: string
    sql: ${TABLE}.has_product_copy

  - dimension: has_images
    type: string
    sql: ${TABLE}.has_images

  - dimension: has_item_master
    type: string
    sql: ${TABLE}.has_item_master

  - dimension: season
    type: string
    sql: ${TABLE}.season

  - dimension: progress
    type: number
    value_format: "0%"
    sql: ${TABLE}.has_logo_status + ${TABLE}.has_product_copy_status + ${TABLE}.has_images_status + ${TABLE}.has_item_master_status
    
  - measure: average_progress
    type: avg
    value_format: "0%"
    sql: ${progress}