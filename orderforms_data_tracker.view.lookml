
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
      FROM [LOT_Reporting].[orderform].[data_tracker]

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: id
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

  sets:
    detail:
      - id
      - brand
      - has_logo
      - has_product_copy
      - has_images
      - has_item_master
      - season

