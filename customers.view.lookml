
- view: customers
  derived_table:
    sql: |
      SELECT a.entity_id
           , a.email
           , e.value AS firstname
           , f.value AS lastname
           , a.created_at
           , a.updated_at
           , a.is_active
           , d.customer_group_code
           , b.value AS date_of_birth
           , c.value AS member_until
      FROM magento.customer_entity AS a
      LEFT JOIN magento.customer_entity_datetime AS b
        ON a.entity_id = b.entity_id AND b.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'dob' AND entity_type_id = 1)
      LEFT JOIN magento.customer_entity_datetime AS c
        ON a.entity_id = c.entity_id AND c.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'member_until' AND entity_type_id = 1)
      LEFT JOIN magento.customer_group AS d
        ON a.group_id = d.customer_group_id
      LEFT JOIN magento.customer_entity_varchar AS e
        ON a.entity_id = e.entity_id AND e.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'firstname' AND entity_type_id = 1)
      LEFT JOIN magento.customer_entity_varchar AS f
        ON a.entity_id = f.entity_id AND f.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'lastname' AND entity_type_id = 1)
    indexes: [entity_id, email, customer_group_code]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: entity_id
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.entity_id

  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: first_name
    type: string
    sql: ${TABLE}.firstname

  - dimension: last_name
    type: string
    sql: ${TABLE}.lastname

  - dimension_group: created
    type: time
    sql: ${TABLE}.created_at

  - dimension_group: updated
    type: time
    sql: ${TABLE}.updated_at

  - dimension: is_active
    type: yesno
    sql: ${TABLE}.is_active = 1

  - dimension: customer_group
    type: string
    sql: ${TABLE}.customer_group_code

  - dimension_group: date_of_birth
    type: time
    timeframes: [date]
    sql: ${TABLE}.date_of_birth

  - dimension_group: member
    type: yesno
    sql: ${TABLE}.member_until IS NOT NULL


