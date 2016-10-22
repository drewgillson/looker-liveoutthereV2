- view: sales_items
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY order_created) AS row
        , a.*
        , (qty * COALESCE(average_cost.value, cost.value)) AS extended_cost
        , 1 - (row_total / (qty * msrp.price)) AS discount_percentage_from_msrp
        , qty * msrp.price AS gross_sold_msrp
      FROM (
        SELECT email 
           , order_created
           , invoice_created
           , order_entity_id
           , order_increment_id
           , row_total_incl_tax
           -- treat customer credit portion of invoice item as a discount, and if the row_total is less than zero (this happens when customer credit covers the entire order, because credit is applied to the AFTER tax total) just treat it as a zero
           , CASE WHEN row_total - ISNULL(((row_total_incl_tax / NULLIF(invoice_total,0)) * customer_credit_total),0) < 0 THEN 0 ELSE row_total - ISNULL(((row_total_incl_tax / NULLIF(invoice_total,0)) * customer_credit_total),0) END AS row_total
           , tax_amount
           -- fix for the same damn edge case with taxes and totals when customer credit has covered the whole order
           , CASE WHEN discount_amount + ISNULL(((row_total_incl_tax / NULLIF(invoice_total,0)) * customer_credit_total),0) > row_total_incl_tax THEN row_total ELSE discount_amount + ISNULL(((row_total_incl_tax / NULLIF(invoice_total,0)) * customer_credit_total),0) END AS discount_amount
           , qty
           , deferred_revenue
           , product_id
           , storefront
           , ISNULL(((row_total_incl_tax / NULLIF(invoice_total,0)) * customer_credit_total),0) AS customer_credit_amount
           , state
           , status
           , coupon_rule_name
           , discount_description
           , coupon_code
           , kount_ris_score
           , CASE WHEN state = 'complete' AND status = 'complete' THEN 'A' ELSE kount_ris_response END AS kount_ris_response
           , kount_ris_rule
           , kount_ris_description
        FROM (
          SELECT c.customer_email AS email
            , c.created_at AS order_created
            , b.created_at AS invoice_created
            , c.entity_id AS order_entity_id
            , c.increment_id AS order_increment_id
            , CASE WHEN d.type_id NOT LIKE '%gift%' OR d.type_id IS NULL THEN a.row_total + ISNULL(a.tax_amount,0) - ISNULL(a.discount_amount,0) END AS row_total_incl_tax
            , CASE WHEN d.type_id NOT LIKE '%gift%' OR d.type_id IS NULL THEN a.row_total - ISNULL(a.discount_amount,0) END AS row_total
            , a.tax_amount
            , a.discount_amount
            , qty
            , CASE WHEN d.type_id LIKE '%gift%' THEN a.row_total - ISNULL(a.discount_amount,0) END AS deferred_revenue
            -- fix an issue where some sales_invoice_items are actually configurable products, and won't have a match in the Products view
            , COALESCE(d.entity_id, a.product_id, -1) AS product_id
            , CASE WHEN marketplace_order_id IS NOT NULL THEN 'Amazon' WHEN custom_storefront IS NOT NULL THEN custom_storefront ELSE 'LiveOutThere.com' END AS storefront
            , b.subtotal_incl_tax - ISNULL(b.discount_amount,0) AS invoice_total
            , ISNULL(b.customer_credit_amount,0) + ISNULL(c.use_gift_credit_amount,0) AS customer_credit_total
            , c.state
            , c.status
            , c.coupon_rule_name
            , c.discount_description
            , c.coupon_code
            , CAST(c.kount_ris_score AS nvarchar(max)) AS kount_ris_score
            , CAST(c.kount_ris_response AS nvarchar(max)) AS kount_ris_response
            , CAST(c.kount_ris_rule AS nvarchar(max)) AS kount_ris_rule
            , CAST(c.kount_ris_description AS nvarchar(max)) AS kount_ris_description
          FROM magento.sales_flat_invoice_item AS a
          INNER JOIN magento.sales_flat_invoice AS b
            ON a.parent_id = b.entity_id
          INNER JOIN magento.sales_flat_order AS c
            ON b.order_id = c.entity_id
          LEFT JOIN (
            SELECT sku, entity_id, type_id
            FROM magento.catalog_product_entity
            WHERE type_id != 'simple'
          ) AS d
            ON a.sku = d.sku
          WHERE row_total > 0
          AND c.customer_email != 'pk_cs@liveoutthere.com'
        ) AS a
        UNION ALL
        -- insert rows for shipping charges
        SELECT b.customer_email AS email
          , b.created_at AS order_created
          , a.created_at AS invoice_created
          , b.entity_id AS order_entity_id
          , b.increment_id AS order_increment_id
          , a.shipping_incl_tax AS row_total_incl_tax
          , a.shipping_amount AS row_total
          , a.shipping_tax_amount AS tax_amount
          , 0 AS discount_amount
          , 1 AS qty
          , NULL AS deferred_revenue
          , -1 AS product_id
          , CASE WHEN marketplace_order_id IS NOT NULL THEN 'Amazon' WHEN custom_storefront IS NOT NULL THEN custom_storefront ELSE 'LiveOutThere.com' END AS storefront
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , CAST(b.kount_ris_score AS nvarchar(max)) AS kount_ris_score
          , CAST(b.kount_ris_response AS nvarchar(max)) AS kount_ris_response
          , CAST(b.kount_ris_rule AS nvarchar(max)) AS kount_ris_rule
          , CAST(b.kount_ris_description AS nvarchar(max)) AS kount_ris_description
        FROM magento.sales_flat_invoice AS a
        INNER JOIN magento.sales_flat_order AS b
          ON a.order_id = b.entity_id
        WHERE a.shipping_amount > 0
        UNION ALL
        -- insert an additional row in the result set that can be used to join independent refunds for orders that aren't associated to order items
        SELECT a.customer_email AS email
          , a.created_at AS order_created
          , MAX(d.created_at) AS invoice_created
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
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , NULL
          , CAST(a.kount_ris_score AS nvarchar(max)) AS kount_ris_score
          , CAST(a.kount_ris_response AS nvarchar(max)) AS kount_ris_response
          , CAST(a.kount_ris_rule AS nvarchar(max)) AS kount_ris_rule
          , CAST(a.kount_ris_description AS nvarchar(max)) AS kount_ris_description
        FROM magento.sales_flat_order AS a
        INNER JOIN magento.sales_flat_creditmemo AS b
          ON a.entity_id = b.order_id
        LEFT JOIN magento.sales_flat_creditmemo_item AS c
          ON b.entity_id = c.parent_id
        LEFT JOIN magento.sales_flat_invoice AS d
          ON a.entity_id = d.order_id
        WHERE c.entity_id IS NULL AND a.marketplace_order_id IS NULL
        GROUP BY a.customer_email, a.created_at, a.entity_id, a.increment_id, a.marketplace_order_id, a.custom_storefront, CAST(a.kount_ris_score AS nvarchar(max)), CAST(a.kount_ris_response AS nvarchar(max)), CAST(a.kount_ris_rule AS nvarchar(max)), CAST(a.kount_ris_description AS nvarchar(max))
        UNION ALL
        -- Shopify sales
        SELECT a.[order-email] AS email
            , CONVERT(VARCHAR(19),[order-created_at],120) + '.0000000 +00:00' AS order_created
            , CONVERT(VARCHAR(19),[order-created_at],120) + '.0000000 +00:00' AS invoice_created
            , c.[order-id] AS order_entity_id
            , a.[order-order_number] AS order_increment_id
            , [order-line_items-charged_price]  AS row_total_incl_tax
            , [order-line_items-charged_price] - ([order-line_items-total_tax] + ([order-line_items-total_shipping] * ([order-line_items-total_tax] / [order-line_items-total_price]))) AS row_total
            , [order-line_items-total_tax] + ([order-line_items-total_shipping] * ([order-line_items-total_tax] / [order-line_items-total_price])) AS tax_amount
            , 0 AS discount_amount
            , [order-line_items-quantity] AS qty
            , NULL AS deferred_revenue
            , COALESCE(b.entity_id, -1) AS product_id
            , 'TheVan.ca' AS storefront
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
            , NULL
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
      LEFT JOIN (
        SELECT entity_id, value FROM magento.catalog_product_entity_decimal WHERE attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'cost')
      ) AS cost
      ON a.product_id = cost.entity_id
      LEFT JOIN ${catalog_product.SQL_TABLE_NAME} AS msrp
      ON a.product_id = msrp.entity_id
    indexes: [email, order_entity_id, order_increment_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    sql: ${TABLE}.row

  - dimension: product_id
    hidden: true
    type: string
    value_format: '0' 
    sql: ${TABLE}.product_id
    
  - dimension: order_entity_id
    hidden: true
    type: number
    value_format: '0' 
    sql: ${TABLE}.order_entity_id

  - dimension_group: invoice_created
    description: "Date/time an order was invoiced"
    type: time
    sql: ${TABLE}.invoice_created

  - dimension_group: order_created
    description: "Date/time an order was placed"
    type: time
    sql: ${TABLE}.order_created

  - measure: first_order
    type: date
    sql: MIN(${TABLE}.order_created)

  - measure: last_order
    type: date
    sql: MAX(${TABLE}.order_created)

  - dimension: order_id
    description: "Order ID from Magento or Shopify (includes links to backends)"
    type: string
    sql: ${TABLE}.order_increment_id
    links:
      - label: 'Magento Sales Order'
        url: "https://admin.liveoutthere.com/index.php/inspire/sales_order/view/order_id/{{ sales.order_entity_id._value | encode_uri }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'
      - label: 'Shopify Sales Order'
        url: "https://thevan.myshopify.com/admin/orders/{{ sales.order_entity_id._value | encode_uri }}"
        icon_url: 'https://cdn.shopify.com/shopify-marketing_assets/static/shopify-favicon.png'

  - dimension: storefront
    description: "Either LiveOutThere.com, TheVan.ca, or Amazon"
    type: string
    sql: ${TABLE}.storefront
    
  - dimension: email
    type: string
    sql: ${TABLE}.email

  - dimension: status
    type: string
    sql: ${TABLE}.status

  - dimension: state
    type: string
    sql: ${TABLE}.state
    
  - dimension: coupon_rule_name
    type: string
    sql: ${TABLE}.coupon_rule_name

  - dimension: coupon_code
    type: string
    sql: ${TABLE}.coupon_code

  - dimension: coupon_rule_description
    type: string
    sql: ${TABLE}.discount_description
    
  - dimension: kount_score
    type: number
    sql: ${TABLE}.kount_ris_score

  - dimension: kount_response
    type: string
    sql_case:
      escalated: ${TABLE}.kount_ris_response = 'E'
      approved: ${TABLE}.kount_ris_response = 'A' OR ${TABLE}.kount_ris_response IS NULL
      declined: ${TABLE}.kount_ris_response = 'D'
      review: ${TABLE}.kount_ris_response = 'R'
      else: unknown

  - dimension: kount_rule
    type: string
    sql: ${TABLE}.kount_ris_rule

  - dimension: kount_description
    type: string
    sql: ${TABLE}.kount_ris_description
    
  - measure: total_collected
    description: "Total charged to the customer, including taxes"
    label: "Gross Collected $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.row_total_incl_tax

  - measure: gross_sold_msrp
    label: "Gross Sold MSRP $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.gross_sold_msrp
    
  - measure: net_sold_opportunity
    description: "Gross Sold MSRP $ - Refunded MSRP $"
    label: "Net Sold Opportunity $"
    type: number
    value_format: '$#,##0'
    sql: ${gross_sold_msrp} - ${credits.refunded_msrp}

  - measure: subtotal
    description: "Total sold (does not include tax or redeemed customer credit)"
    label: "Gross Sold $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.row_total
    drill_fields: [configurable_products_sales_summary*]
    
  - measure: average_sale_price
    label: "Average Sale Price $"
    description: "Average gross sold price per unit"
    type: number
    value_format: '$#,##0'
    sql: ${subtotal} / NULLIF(${gross_sold_quantity},0)

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
    label: "Gross Margin $ (Net)"
    description: "Gross margin dollars collected on net sales"
    type: number
    value_format: '$#,##0' 
    sql: CAST(${net_sold} - ${net_cost} AS money)
    
  - measure: gross_gross_margin
    label: "Gross Margin $"
    description: "Gross margin dollars collected on gross sales"
    type: number
    value_format: '$#,##0' 
    sql: CAST(${subtotal} - ${gross_cost} AS money)

  - measure: gross_margin_percent
    label: "Gross Margin % (Net)"
    description: "Gross margin percentage on net sales"
    type: number
    value_format: '0\%' 
    sql: |
      100.00 * CASE
        WHEN FLOOR(${net_sold}) = 0 AND ${gross_margin} = 0 THEN NULL
        WHEN FLOOR(${net_sold}) > 0 THEN ${gross_margin} / ${net_sold}
      END

  - measure: gross_gross_margin_percent
    label: "Gross Margin %"
    description: "Gross margin percentage on gross sales"
    type: number
    value_format: '0\%' 
    sql: |
      100.00 * CASE
        WHEN FLOOR(${subtotal}) = 0 AND ${gross_gross_margin} = 0 THEN NULL
        WHEN FLOOR(${subtotal}) > 0 THEN ${gross_gross_margin} / ${subtotal}
      END
      
  - measure: tax_collected
    description: "Total tax collected"
    label: "Tax Collected $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.tax_amount

  - measure: redeemed_customer_credit
    description: "Was there any store credit / customer credit redeemed for the order?"
    type: yesno
    sql: ${customer_credit_amount} > 0

  - measure: customer_credit_amount
    description: "Redeemed customer credit subtotal portion (we treat customer credit like a discount so gross margin is not over-stated, we also remove the tax portion. Example:if someone redeems $10 in Alberta, we count $9.52 towards the subtotal portion and $0.48 towards the tax portion of their receipt)"
    label: "Redeemed Credit $"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.customer_credit_amount

  - dimension: discount_tier
    label: "Discount %"
    type: tier
    tiers: [0,0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]
    style: interval
    value_format: '#%' 
    sql: ${TABLE}.discount_percentage_from_msrp

  - measure: discount
    label: "Discount %"
    type: avg
    value_format: '#%' 
    sql: ${TABLE}.discount_percentage_from_msrp

  - measure: cart_discount_amount
    label: "Cart Discount Amount $"
    description: "Discount amount from catalog (advertised) price because of Shopping Cart Price Rules and redeemed Customer Credit"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.discount_amount

  - measure: gross_sold_quantity
    description: "Number of units ordered"
    type: sum
    value_format: '0' 
    sql: ${TABLE}.qty
    
  - measure: net_sold_quantity
    description: "Number of units ordered less number of units refunded"
    type: number
    value_format: '0'
    sql: ${gross_sold_quantity} - ${credits.refunded_quantity}

  - measure: return_rate_units
    label: "Returned %"
    description: "Number of units returned divided by gross sold units"
    type: number
    value_format: '#.0\%'
    sql: 100.00 * (${credits.refunded_quantity} / NULLIF(${gross_sold_quantity},0))

  - measure: return_rate_dollars
    label: "Refunded %"
    description: "Amount refunded for returned items divided by Gross Sold $"
    type: number
    value_format: '#.0\%'
    sql: 100.00 * (${credits.refund_for_return} / NULLIF(${subtotal},0))

  - measure: deferred_revenue
    description: "Total amount of gift cards sold"
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.deferred_revenue
      
  - measure: net_contribution
    label: "Contribution $"
    description: "Net contribution is calculated by including any shipping costs as well as a 4% levy for credit card charges and packaging. Note that shipping costs don't get imported into the system for 1-2 weeks following a sale or refund, so for recent orders, this number will be too high."
    type: number
    value_format: '$#,##0.00'
    sql: ${net_sold} - ${shipping_charges.total_shipping_charge} - ${net_cost} - (${net_sold} * 0.04)

  - measure: net_contribution_percent
    label: "Contribution %"
    description: "Net contribution (see note on Contribution $) expressed as a percentage"
    type: number
    value_format: '#.0\%' 
    sql: 100.00 * (${net_contribution} / NULLIF(${net_sold},0))

  - measure: orders
    description: "Number of orders placed"
    type: count_distinct
    sql: ${order_id}
    
  - measure: percent_of_total_orders
    type: percent_of_total
    sql: ${orders}
    
  - measure: unique_products_ordered
    type: count_distinct
    sql: ${TABLE}.product_id
    
  sets:
      configurable_products_sales_summary:
        - products.budget_type
        - gross_sold_quantity
        - average_sale_price
        - subtotal
        - discount
        - gross_gross_margin
        - gross_gross_margin_percent
        - product_page_views.count
        - product_page_views.conversion_rate
        
