view: report_return_requests_for_suntec {
  derived_table: {
    sql: SELECT DISTINCT
        products.parent_id  AS "products.parent_id",
        return_authorizations.increment_id  AS "return_authorizations.increment_id",
        CASE
      WHEN return_authorizations.request_type = 1  THEN '0'
      WHEN return_authorizations.request_type = 2  THEN '1'
      WHEN return_authorizations.request_type = 3  THEN '2'
      WHEN return_authorizations.request_type = 5  THEN '3'
      WHEN return_authorizations.request_type = 6  THEN '4'
      WHEN return_authorizations.request_type = 10  THEN '5'
      END AS "return_authorizations.request_type__sort_",
        CONVERT(VARCHAR(10),return_authorizations.created_at ,120) AS "return_authorizations.created_date",
        return_authorization_product_parent.parent_sku  AS "return_authorization_product_parent.configurable_sku",
        ISNULL((CASE
              WHEN 1=1 -- no filter on 'return_authorization_items_product.brand_filter'

              THEN return_authorization_items_product.brand
              ELSE 'All Other Brands'
            END
      ),'') + ' ' + ISNULL(CASE WHEN return_authorization_items_product.department NOT LIKE '%^%' THEN return_authorization_items_product.department END,'') + ' ' + ISNULL(return_authorization_items_product.product,'')  AS "return_authorization_items_product.long_product_name",
        CASE
      WHEN return_authorizations.request_type = 1  THEN 'Item I received did not fit'
      WHEN return_authorizations.request_type = 2  THEN 'I did not like the colour of the item'
      WHEN return_authorizations.request_type = 3  THEN 'Item arrived damaged or incomplete'
      WHEN return_authorizations.request_type = 5  THEN 'The description did not match the item I received'
      WHEN return_authorizations.request_type = 6  THEN 'Other'
      WHEN return_authorizations.request_type = 10  THEN 'I found a better price at a competitor'
      END AS "return_authorizations.request_type",
        return_authorizations_comments.comment  AS "return_authorizations_comments.comment"
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
      LEFT JOIN ${catalog_categories.SQL_TABLE_NAME} AS categories ON products.entity_id = categories.product_id
      LEFT JOIN ${sales_items.SQL_TABLE_NAME} AS sales ON products.entity_id = sales.product_id
      LEFT JOIN ${sales_credits_items.SQL_TABLE_NAME} AS credits ON sales.order_entity_id = credits.order_entity_id
            AND sales.product_id = credits.product_id

      LEFT JOIN ${sales_return_authorizations.SQL_TABLE_NAME} AS return_authorizations ON sales.order_increment_id = return_authorizations.increment_id
      LEFT JOIN ${sales_return_authorizations_comments.SQL_TABLE_NAME} AS return_authorizations_comments ON return_authorizations.id = return_authorizations_comments.entity_id
      LEFT JOIN ${sales_return_authorizations_items.SQL_TABLE_NAME} AS return_authorization_items ON return_authorizations.id = return_authorization_items.rma_entity_id
      LEFT JOIN ${catalog_product_links.SQL_TABLE_NAME} AS return_authorization_items_product ON return_authorization_items.product_id = return_authorization_items_product.entity_id
      LEFT JOIN ${catalog_product_associations.SQL_TABLE_NAME} AS return_authorization_product_parent ON return_authorization_items_product.entity_id = return_authorization_product_parent.product_id

      WHERE (((return_authorizations.created_at ) >= ((DATEADD(day,-29, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ))) AND (return_authorizations.created_at ) < ((DATEADD(day,30, DATEADD(day,-29, CONVERT(DATETIME, CONVERT(VARCHAR, CURRENT_TIMESTAMP, 102), 120) ) ))))) AND ((CASE
      WHEN return_authorizations.request_type = 1  THEN 'Item I received did not fit'
      WHEN return_authorizations.request_type = 2  THEN 'I did not like the colour of the item'
      WHEN return_authorizations.request_type = 3  THEN 'Item arrived damaged or incomplete'
      WHEN return_authorizations.request_type = 5  THEN 'The description did not match the item I received'
      WHEN return_authorizations.request_type = 6  THEN 'Other'
      WHEN return_authorizations.request_type = 10  THEN 'I found a better price at a competitor'
      END IN ('The description did not match the item I received', 'Other')))
      GROUP BY products.parent_id ,return_authorizations.increment_id ,CASE
      WHEN return_authorizations.request_type = 1  THEN '0'
      WHEN return_authorizations.request_type = 2  THEN '1'
      WHEN return_authorizations.request_type = 3  THEN '2'
      WHEN return_authorizations.request_type = 5  THEN '3'
      WHEN return_authorizations.request_type = 6  THEN '4'
      WHEN return_authorizations.request_type = 10  THEN '5'
      END,CONVERT(VARCHAR(10),return_authorizations.created_at ,120),return_authorization_product_parent.parent_sku ,ISNULL((CASE
              WHEN 1=1 -- no filter on 'return_authorization_items_product.brand_filter'

              THEN return_authorization_items_product.brand
              ELSE 'All Other Brands'
            END
      ),'') + ' ' + ISNULL(CASE WHEN return_authorization_items_product.department NOT LIKE '%^%' THEN return_authorization_items_product.department END,'') + ' ' + ISNULL(return_authorization_items_product.product,'') ,CASE
      WHEN return_authorizations.request_type = 1  THEN 'Item I received did not fit'
      WHEN return_authorizations.request_type = 2  THEN 'I did not like the colour of the item'
      WHEN return_authorizations.request_type = 3  THEN 'Item arrived damaged or incomplete'
      WHEN return_authorizations.request_type = 5  THEN 'The description did not match the item I received'
      WHEN return_authorizations.request_type = 6  THEN 'Other'
      WHEN return_authorizations.request_type = 10  THEN 'I found a better price at a competitor'
      END,return_authorizations_comments.comment ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."return_authorizations.increment_id" ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}."return_authorizations.created_date" ;;
  }

  dimension: configurable_sku {
    type: string
    sql: ${TABLE}."return_authorization_product_parent.configurable_sku" ;;
  }

  dimension: long_product_name {
    type: string
    sql: ${TABLE}."return_authorization_items_product.long_product_name" ;;
  }

  dimension: request_type {
    type: string
    sql: ${TABLE}."return_authorizations.request_type" ;;
  }

  dimension: comment {
    type: string
    sql: ${TABLE}."return_authorizations_comments.comment" ;;
  }
}
