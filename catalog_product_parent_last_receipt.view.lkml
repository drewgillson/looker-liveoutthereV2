view: catalog_product_parent_last_receipt {
  derived_table: {
    sql: SELECT
        products.parent_id,
        MAX(product_facts.last_receipt) AS max_last_receipt
      FROM ${catalog_product_links.SQL_TABLE_NAME} AS products
      LEFT JOIN ${catalog_product_facts.SQL_TABLE_NAME} AS product_facts ON products.entity_id = product_facts.product_id
      GROUP BY products.parent_id
       ;;
  }

  dimension: parent_id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.parent_id ;;
  }

  dimension_group: max_last_receipt {
    view_label: "Weekly Inventory Performance"
    label: "Last Receipt"
    type: time
    sql: ${TABLE}.max_last_receipt ;;
  }

  dimension: bucket {
    description: "Based on last receipt date, 2016-07-01 to date is Bucket 1, 2016-01-01 to 2016-06-30 is Bucket 2, 2015-07-01 to 2015-12-31 is Bucket 3, and everything else is Bucket 4."
    view_label: "Weekly Inventory Performance"
    label: "Last Receipt Bucket"
    case: {
      when: {
        label: "Bucket 1"
        sql: ${max_last_receipt_date} >= '2016-07-01' ;;
      }
      when: {
        label: "Bucket 2"
        sql: ${max_last_receipt_date} >= '2016-01-01' AND ${max_last_receipt_date} < '2016-07-01' ;;
      }
      when: {
        label: "Bucket 3"
        sql: ${max_last_receipt_date} >= '2015-07-01' AND ${max_last_receipt_date} < '2016-01-01' ;;
      }
      else: "Bucket 4"
    }
  }
}
