include: "catalog_product.view.lkml"
view: carts_items_product {
  extends: [catalog_product]

  dimension: sku {
    required_fields: [entity_id]
    sql: ${TABLE}.sku ;;
    description: "SKU for a product with a specific colour and size - what we call a 'simple SKU'. It is one of the core fields that join most of our models."
  }

  dimension: long_product_name {
    sql: ISNULL(${brand},'') + ' ' + ISNULL(CASE WHEN ${department} NOT LIKE '%^%' THEN ${department} END,'') + ' ' + ISNULL(${short_product_name},'') ;;
    description: "Long product name, like Arc'teryx Men's Gamma Pants"
  }

  dimension: short_product_name {
    description: "Name of a product"
    type: string
    sql: ${TABLE}.product ;;
  }
}
