view: catalog_product_impressions_filtered {
  derived_table: {
    sql: SELECT * FROM ${catalog_product_impressions.SQL_TABLE_NAME}
      WHERE {% condition sales.order_created_date %} period {% endcondition %}
      AND {% condition sales.invoice_created_date %} visit {% endcondition %}
       ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  measure: count {
    description: "Number of times a Magento product was loaded on the frontend of the website, this includes carousels, PLP, PDP, etc. - anywhere the product is displayed (for the period of time set by the Sales > Order Created filter)"
    type: sum
    sql: ${TABLE}.views ;;
  }

  measure: conversion_rate {
    label: "Conversion Rate %"
    description: "Calculated conversion rate of impressions to orders (for the period of time set by the Sales > Order Created filter)"
    type: number
    sql: 100.00 * (${sales.orders} / ${count}) ;;
    value_format: "#.00\%"
  }
}
