- view: catalog_product_associations
  sql_table_name: magento.catalog_product_super_link
  fields:

  - dimension: link_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.link_id
    
  - dimension: parent_id
    hidden: true
    sql: ${TABLE}.parent_id
    
  - dimension: product_id
    hidden: true
    sql: ${TABLE}.product_id