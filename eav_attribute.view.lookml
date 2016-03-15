- view: eav_attribute
  sql_table_name: magento.eav_attribute
  fields:

  - dimension: attribute_code
    type: string
    sql: ${TABLE}.attribute_code

  - dimension: attribute_id
    type: number
    sql: ${TABLE}.attribute_id

  - dimension: attribute_model
    type: string
    sql: ${TABLE}.attribute_model

  - dimension: backend_model
    type: string
    sql: ${TABLE}.backend_model

  - dimension: backend_table
    type: string
    sql: ${TABLE}.backend_table

  - dimension: backend_type
    type: string
    sql: ${TABLE}.backend_type

  - dimension: default_value
    type: string
    sql: ${TABLE}.default_value

  - dimension: entity_type_id
    type: number
    sql: ${TABLE}.entity_type_id

  - dimension: frontend_class
    type: string
    sql: ${TABLE}.frontend_class

  - dimension: frontend_input
    type: string
    sql: ${TABLE}.frontend_input

  - dimension: frontend_label
    type: string
    sql: ${TABLE}.frontend_label

  - dimension: frontend_model
    type: string
    sql: ${TABLE}.frontend_model

  - dimension: is_required
    type: number
    sql: ${TABLE}.is_required

  - dimension: is_unique
    type: number
    sql: ${TABLE}.is_unique

  - dimension: is_user_defined
    type: number
    sql: ${TABLE}.is_user_defined

  - dimension: note
    type: string
    sql: ${TABLE}.note

  - dimension: source_model
    type: string
    sql: ${TABLE}.source_model

  - measure: count
    type: count
    drill_fields: []

