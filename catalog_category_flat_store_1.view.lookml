- view: catalog_category_flat_store_1
  sql_table_name: magento.catalog_category_flat_store_1
  fields:

  - dimension: all_children
    type: string
    sql: ${TABLE}.all_children

  - dimension: available_sort_by
    type: string
    sql: ${TABLE}.available_sort_by

  - dimension: children
    type: string
    sql: ${TABLE}.children

  - dimension: children_count
    type: number
    sql: ${TABLE}.children_count

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: custom_apply_to_products
    type: number
    sql: ${TABLE}.custom_apply_to_products

  - dimension: custom_design
    type: string
    sql: ${TABLE}.custom_design

  - dimension_group: custom_design_from
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.custom_design_from

  - dimension_group: custom_design_to
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.custom_design_to

  - dimension: custom_layout_update
    type: string
    sql: ${TABLE}.custom_layout_update

  - dimension: custom_use_parent_settings
    type: number
    sql: ${TABLE}.custom_use_parent_settings

  - dimension: default_sort_by
    type: string
    sql: ${TABLE}.default_sort_by

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: display_mode
    type: string
    sql: ${TABLE}.display_mode

  - dimension: entity_id
    type: number
    sql: ${TABLE}.entity_id

  - dimension: filter_price_range
    type: number
    sql: ${TABLE}.filter_price_range

  - dimension: image
    type: string
    sql: ${TABLE}.image

  - dimension: include_in_menu
    type: number
    sql: ${TABLE}.include_in_menu

  - dimension: is_active
    type: number
    sql: ${TABLE}.is_active

  - dimension: is_anchor
    type: number
    sql: ${TABLE}.is_anchor

  - dimension: landing_page
    type: number
    sql: ${TABLE}.landing_page

  - dimension: level
    type: number
    sql: ${TABLE}.level

  - dimension: meta_description
    type: string
    sql: ${TABLE}.meta_description

  - dimension: meta_keywords
    type: string
    sql: ${TABLE}.meta_keywords

  - dimension: meta_title
    type: string
    sql: ${TABLE}.meta_title

  - dimension: name
    type: string
    sql: ${TABLE}.name

  - dimension: page_layout
    type: string
    sql: ${TABLE}.page_layout

  - dimension: parent_id
    type: number
    sql: ${TABLE}.parent_id

  - dimension: path
    type: string
    sql: ${TABLE}.path

  - dimension: path_in_store
    type: string
    sql: ${TABLE}.path_in_store

  - dimension: position
    type: number
    sql: ${TABLE}.position

  - dimension: store_id
    type: number
    sql: ${TABLE}.store_id

  - dimension: thumbnail
    type: string
    sql: ${TABLE}.thumbnail

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - dimension: url_key
    type: string
    sql: ${TABLE}.url_key

  - dimension: url_path
    type: string
    sql: ${TABLE}.url_path

  - measure: count
    type: count
    drill_fields: [name]

