view: orderforms_item_master {
  sql_table_name: orderform.item_master ;;

  dimension: season {
    type: string
    sql: ${TABLE}.season ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: vendor_style_code {
    type: string
    sql: ${TABLE}.vendor_style_code ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: style_name {
    type: string
    sql: ${TABLE}.style_name ;;
  }

  dimension: colour_code {
    type: string
    sql: ${TABLE}.colour_code ;;
  }

  dimension: colour_name {
    type: string
    sql: ${TABLE}.colour_name ;;
  }

  dimension: size {
    type: string
    sql: ${TABLE}.size ;;
  }

  dimension: upc_code {
    type: string
    sql: ${TABLE}.upc_code ;;
  }

  dimension: wholesale_price {
    type: string
    sql: ${TABLE}.wholesale_price ;;
  }

  dimension: retail_price {
    type: string
    sql: ${TABLE}.retail_price ;;
  }

  set: detail {
    fields: [season, brand, vendor_style_code, department, style_name, colour_code, colour_name, size, upc_code, wholesale_price, retail_price]
  }
}
