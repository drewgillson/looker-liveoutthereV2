- view: people_favourite_budget_types
  derived_table:
    sql: |
      SELECT *, ROW_NUMBER() OVER (ORDER BY email) AS id FROM (
      SELECT
        people.email,
        sales_product.budget_type,
        COUNT(DISTINCT sales.product_id) AS products_ordered,
        ROW_NUMBER() OVER (PARTITION BY people.email ORDER BY COUNT(DISTINCT sales.product_id) DESC) AS score
      FROM ${people.SQL_TABLE_NAME} AS people
      LEFT JOIN ${customers.SQL_TABLE_NAME} AS customers ON people.email = customers.email
      LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON customers.email = sales.email
      LEFT JOIN ${carts_items_product.SQL_TABLE_NAME} AS sales_product ON sales.product_id = sales_product.entity_id
      WHERE (((sales.order_created) >= ((DATEADD(day,-364, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ))) AND (sales.order_created) < ((DATEADD(day,365, DATEADD(day,-364, CAST(CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102) AS DATETIME) ) )))))
      AND sales_product.budget_type IS NOT NULL
      GROUP BY people.email, sales_product.budget_type
      ) AS x
    indexes: [email, budget_type]
    persist_for: 24 hours

  fields:
  
  - dimension: id
    hidden: true
    primary_key: true
    sql: ${TABLE}.id
    
  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: budget_type
    type: string
    sql: ${TABLE}.budget_type
    
  - dimension: score
    type: number
    sql: ${TABLE}.score

  - measure: products_ordered
    type: sum
    sql: ${TABLE}.products_ordered