- view: sales_items
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY order_created) AS row, a.*, (qty * average_cost.value) AS extended_cost FROM (
        SELECT c.created_at AS order_created
          , b.created_at AS invoice_created
          , c.entity_id AS order_entity_id
          , c.increment_id AS order_increment_id
          , CASE WHEN a.name NOT LIKE '%Gift Card%' AND a.name NOT LIKE '%Donation%' THEN a.row_total + ISNULL(a.tax_amount,0) - ISNULL(a.discount_amount,0) END AS row_total_incl_tax
          , CASE WHEN a.name NOT LIKE '%Gift Card%' AND a.name NOT LIKE '%Donation%' THEN a.row_total - ISNULL(a.discount_amount,0) END AS row_total
          , a.tax_amount
          , a.discount_amount
          , qty
          , CASE WHEN a.name LIKE '%Gift Card%' OR a.name LIKE '%Donation%' THEN a.row_total - ISNULL(a.discount_amount,0) END AS deferred_revenue
          -- fix an issue where some sales_invoice_items are actually configurable products, and won't have a match in the Products view
          , COALESCE(d.entity_id, a.product_id) AS product_id
          , CASE WHEN marketplace_order_id IS NOT NULL THEN 'Amazon' WHEN custom_storefront IS NOT NULL THEN custom_storefront ELSE 'LiveOutThere.com' END AS storefront
        FROM magento.sales_flat_invoice_item AS a
        INNER JOIN magento.sales_flat_invoice AS b
          ON a.parent_id = b.entity_id
        INNER JOIN magento.sales_flat_order AS c
          ON b.order_id = c.entity_id
        LEFT JOIN magento.catalog_product_entity AS d
          ON a.sku = d.sku
        WHERE row_total > 0
        UNION ALL
        SELECT b.created_at AS order_created
          , a.created_at AS invoice_created
          , b.entity_id AS order_entity_id
          , b.increment_id AS order_increment_id
          , a.shipping_incl_tax AS row_total_incl_tax
          , a.shipping_amount AS row_total
          , a.shipping_tax_amount AS tax_amount
          , 0 AS discount_amount
          , 1 AS qty
          , NULL AS deferred_revenue
          , NULL AS product_id
          , CASE WHEN marketplace_order_id IS NOT NULL THEN 'Amazon' WHEN custom_storefront IS NOT NULL THEN custom_storefront ELSE 'LiveOutThere.com' END AS storefront
        FROM magento.sales_flat_invoice AS a
        INNER JOIN magento.sales_flat_order AS b
          ON a.order_id = b.entity_id
        WHERE a.shipping_amount > 0
        UNION ALL
        SELECT a.created_at AS order_created
          , NULL AS invoice_created
          , a.entity_id AS order_entity_id
          , a.increment_id AS order_increment_id
          , NULL AS row_total_incl_tax
          , NULL AS row_total
          , NULL AS tax_amount
          , NULL AS discount_amount
          , NULL AS qty
          , NULL AS deferred_revenue
          , -1 AS product_id
          , CASE WHEN marketplace_order_id IS NOT NULL THEN 'Amazon' WHEN custom_storefront IS NOT NULL THEN custom_storefront ELSE 'LiveOutThere.com' END AS storefront
        FROM magento.sales_flat_order AS a
        INNER JOIN magento.sales_flat_creditmemo AS b
          ON a.entity_id = b.order_id
        LEFT JOIN magento.sales_flat_creditmemo_item AS c
          ON b.entity_id = c.parent_id
        WHERE c.entity_id IS NULL AND a.marketplace_order_id IS NULL
        UNION ALL
        SELECT CONVERT(VARCHAR(19),[order-created_at],120) + '.0000000 +00:00' AS order_created
            , CONVERT(VARCHAR(19),[order-created_at],120) + '.0000000 +00:00' AS invoice_created
            , c.[order-id] AS order_entity_id
            , a.[order-order_number] AS order_increment_id
            , [order-line_items-charged_price]  AS row_total_incl_tax
            , [order-line_items-charged_price] - ([order-line_items-total_tax] + ([order-line_items-total_shipping] * ([order-line_items-total_tax] / [order-line_items-total_price]))) AS row_total
            , [order-line_items-total_tax] + ([order-line_items-total_shipping] * ([order-line_items-total_tax] / [order-line_items-total_price])) AS tax_amount
            , 0 AS discount_amount
            , [order-line_items-quantity] AS qty
            , NULL AS deferred_revenue
            , b.entity_id AS product_id
            , 'TheVan.ca' AS storefront
        FROM shopify.order_items AS a
        LEFT JOIN magento.catalog_product_entity AS b
          ON a.[order-line_items-sku] = b.sku
        LEFT JOIN shopify.transactions AS c
          ON a.[order-order_number] = c.[order-order_number] AND c.[order-transactions-kind] = 'sale' AND c.[order-transactions-status] = 'success'
        WHERE a.[order-status] IN ('open', 'closed') AND [order-line_items-sku] != ''
      ) AS a
      LEFT JOIN (
        SELECT pop_product_id
           , ROUND(AVG((pop_price_ht * (1-(CASE WHEN pop_discount > 0 THEN pop_discount ELSE 0 END / 100)))), 2) AS value 
        FROM magento.purchase_order_product
        WHERE pop_price_ht <> 0 
        AND pop_supplied_qty > 0 
        AND pop_discount <> 100 
        GROUP BY pop_product_id
      ) AS average_cost
      ON a.product_id = average_cost.pop_product_id
    indexes: [order_entity_id, order_increment_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: product_id
    type: number
    hidden: true
    sql: ${TABLE}.product_id
    
  - dimension: order_entity_id
    hidden: true
    type: number
    sql: ${TABLE}.order_entity_id

  - dimension_group: invoice_created
    description: "Date/time an order was invoiced"
    type: time
    sql: ${TABLE}.invoice_created

  - dimension_group: order_created
    description: "Date/time an order was placed"
    type: time
    sql: ${TABLE}.order_created

  - dimension: order_id
    description: "Order ID from Magento or Shopify (includes links to backends)"
    type: string
    sql: ${TABLE}.order_increment_id
    links:
      - label: 'Magento Sales Order'
        url: "https://admin.liveoutthere.com/index.php/inspire/sales_order/view/order_id/{{ sales.order_entity_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
      - label: 'Shopify Sales Order'
        url: "https://thevan.myshopify.com/admin/orders/{{ sales.order_entity_id._value }}"
        icon_url: 'https://cdn.shopify.com/shopify-marketing_assets/static/shopify-favicon.png'

  - dimension: storefront
    description: "Either LiveOutThere.com, TheVan.ca, or Amazon"
    type: string
    sql: ${TABLE}.storefront
    
  - measure: total_collected
    description: "Total charged to the customer, including taxes"
    label: "Gross Collected $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.row_total_incl_tax

  - measure: subtotal
    description: "Total charged (does not include tax)"
    label: "Gross Sold $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.row_total

  - measure: net_sold
    description: "Total charged less total refunded (does not include tax)"
    label: "Net Sold $"
    type: number
    value_format: '$#,##0'
    sql: CAST(${subtotal} - ${credits.refunded_subtotal} AS decimal(38,2))
    
  - measure: gross_cost
    label: "Gross Cost $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.extended_cost

  - measure: net_cost
    label: "Net Cost $"
    type: number
    value_format: '$#,##0'
    sql: |
      CASE WHEN ${net_sold} > 0 THEN ${gross_cost} - ${credits.extended_cost} END

  - measure: gross_margin
    label: "Gross Margin $"
    description: "Gross margin dollars collected on net sales"
    type: number
    value_format: '$#,##0' 
    sql: CAST(${net_sold} - ${net_cost} AS money)

  - measure: gross_margin_percent
    label: "Gross Margin %"
    description: "Gross margin percentage on net sales"
    type: number
    value_format: '0.0%' 
    sql: |
      CASE
        WHEN ${net_sold} = 0 AND ${gross_margin} = 0 THEN NULL
        WHEN ${net_sold} > 0 THEN ${gross_margin} / ${net_sold}
      END
      
  - measure: tax_collected
    description: "Total tax collected"
    label: "Tax Collected $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.tax_amount

  - measure: cart_discount_amount
    description: "Discount amount due to Shopping Cart Price Rules"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.discount_amount

  - measure: quantity
    description: "Number of units ordered"
    type: sum
    value_format: '0' 
    sql: ${TABLE}.qty

  - measure: deferred_revenue
    description: "Total amount of gift cards sold or donations accepted"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.deferred_revenue
    
  - measure: orders
    description: "Number of orders placed"
    type: count_distinct
    sql: ${order_entity_id}
    
  - measure: unique_products_ordered
    type: count_distinct
    sql: ${TABLE}.product_id


