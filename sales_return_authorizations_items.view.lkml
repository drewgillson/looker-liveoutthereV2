view: sales_return_authorizations_items {
  derived_table: {
    sql: SELECT a.id
        , a.entity_id AS rma_entity_id
        , d.product_id
        , a.qty
        , b.sku
        , c.value AS barcode
      FROM magento.aw_rma_entity_items AS a
      LEFT JOIN magento.sales_flat_order_item AS b
        ON a.product_id = b.item_id
      LEFT JOIN magento.catalog_product_entity_varchar AS c
        ON b.product_id = c.entity_id AND c.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'ean' AND entity_type_id = 4) AND c.store_id = 0
      LEFT JOIN magento.sales_flat_order_item AS d
        ON d.item_id = a.product_id
       ;;
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
    indexes: ["rma_entity_id"]
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: rma_entity_id {
    type: number
    sql: ${TABLE}.rma_entity_id ;;
    hidden: yes
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
    hidden: yes
  }

  dimension: sku {
    label: "SKU"
    type: string
    sql: ${TABLE}.sku ;;
  }

  dimension: barcode {
    type: string
    sql: '''' + ${TABLE}.barcode ;;
  }

  measure: returning_quantity {
    type: sum
    sql: ${TABLE}.qty ;;
  }
}
