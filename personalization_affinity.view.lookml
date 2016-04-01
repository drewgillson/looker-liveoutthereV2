- view: personalization_affinity
  derived_table:
    sql: |
      SELECT 'Brand' AS affinity_type, email, brand AS value, score, page_views
      FROM ${personalization_brand_affinity.SQL_TABLE_NAME}
      UNION ALL
      SELECT 'Category' AS affinity_type, email, category, score, page_views
      FROM ${personalization_category_affinity.SQL_TABLE_NAME}
      UNION ALL
      SELECT 'Department' AS affinity_type, email, department, score, page_views
      FROM ${personalization_department_affinity.SQL_TABLE_NAME}
    indexes: [email,affinity_type,score]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
    
  fields:
  
    - dimension: email
      primary_key: true
      hidden: true
      type: string
      sql: ${TABLE}.email

    - dimension: type
      description: "Currently either 'Brand', 'Category', or 'Department'"
      type: string
      sql: ${TABLE}.affinity_type
      
    - dimension: value
      description: "Values for the affinity type (i.e. brands, categories, and departments)"
      type: string
      sql: ${TABLE}.value
      
    - dimension: score
      description: "Rank for the affinity, based on the number of page views in the last 3 days. A rank of 1 is the highest value and indicates the person spent the most time looking at these kinds of products."
      type: number
      sql: ${TABLE}.score
      
    - measure: page_views
      description: "Page views for the affinity in the last 3 days"
      type: sum
      value_format: '0'
      sql: ${TABLE}.page_views
