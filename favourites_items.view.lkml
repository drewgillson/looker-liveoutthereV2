view: favourites_items {
  suggestions: no

  sql_table_name: magento.lot_wishlist_customeritem ;;

  dimension: id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: customer_id {
    type: number
    hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: added_at {
    type: time
    sql: ${TABLE}.added_at ;;
  }

  dimension_group: removed_at {
    type: time
    sql: ${TABLE}.removed_at ;;
  }

  dimension: is_still_active {
    description: "Shows if items are still active in a customer's favourites list or if they have removed them."
    type: yesno
    sql: ${TABLE}.is_active = 1 ;;
  }

}
