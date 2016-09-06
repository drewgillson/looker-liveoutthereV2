- view: organizers
  derived_table:
    sql: |
      SELECT x.*, ROW_NUMBER() OVER (PARTITION BY entity_description ORDER BY created_at) AS sequence
      FROM (
      SELECT * FROM OPENQUERY(MAGENTO,'SELECT a.ot_id AS id
                          , CONVERT_TZ(a.ot_created_at, ''UTC'', ''America/Edmonton'') AS created_at
                          , a.ot_caption AS caption
                          , a.ot_description AS description
                          , a.ot_entity_type AS entity_type
                          , a.ot_entity_id AS entity_id
                          , a.ot_entity_description AS entity_description
                          , b.username AS author
                          , c.username AS target
                       FROM organizer_task AS a
                       LEFT JOIN admin_user AS b
                           ON a.ot_author_user = b.user_id
                       LEFT JOIN admin_user AS c
                           ON a.ot_target_user = c.user_id')) AS x
    indexes: [entity_id,entity_type]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: id
    type: number
    primary_key: true
    hidden: true
    sql: ${TABLE}.id

  - dimension_group: created_at
    type: time
    sql: ${TABLE}.created_at

  - dimension: caption
    type: string
    sql: ${TABLE}.caption

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: entity_type
    type: string
    sql: ${TABLE}.entity_type

  - dimension: entity_id
    type: number
    hidden: true
    sql: ${TABLE}.entity_id

  - dimension: entity_description
    type: string
    sql: ${TABLE}.entity_description

  - dimension: author
    type: string
    sql: ${TABLE}.author

  - dimension: target
    type: string
    sql: ${TABLE}.target

  - dimension: sequence
    type: number
    sql: ${TABLE}.sequence