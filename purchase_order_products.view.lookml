- view: purchase_order_products
  derived_table:
    sql: |
        SELECT po.po_date
           , po.po_order_id
           , po.po_status
           , po.po_data_status
           , po.po_type
           , po.po_carrier
           , po.po_ship_date
           , po.po_arrival_date
           , po.po_cancel_date
           , po.po_terms
           , p.*
           , p.pop_price_ht - (p.pop_price_ht * p.pop_discount / 100) AS discounted_cost
           , p.pop_qty * (p.pop_price_ht - (p.pop_price_ht * p.pop_discount / 100)) AS ordered_amount
           , p.pop_supplied_qty * (p.pop_price_ht - (p.pop_price_ht * p.pop_discount / 100)) AS delivered_amount
           , p.pop_qty * p.pop_price_ht AS ordered_amount_cost
           , p.pop_supplied_qty * p.pop_price_ht AS delivered_amount_cost
           , p.pop_qty * price.value AS ordered_amount_msrp
           , p.pop_supplied_qty * price.value AS delivered_amount_msrp
           , sup.sup_name AS supplier
           , po.po_author
           , 1 AS a
        FROM magento.purchase_order_product AS p
        LEFT JOIN magento.purchase_order AS po
          ON p.pop_order_num = po.po_num
        LEFT JOIN magento.purchase_supplier AS sup
          ON po.po_sup_num = sup.sup_id
        LEFT JOIN magento.catalog_product_entity_decimal AS price
          ON p.pop_product_id = price.entity_id AND price.attribute_id = (SELECT attribute_id FROM magento.eav_attribute WHERE attribute_code = 'price' AND entity_type_id = 4)
    indexes: [pop_product_id, po_order_id]
    persist_for: 2 hours

  fields:

  - dimension: pop_num
    primary_key: true
    hidden: true

  - dimension: purchase_order_id
    hidden: true
    sql: ${TABLE}.pop_order_num

  - dimension: pop_product_id
    hidden: true
    sql: ${TABLE}.pop_product_id
    
  - dimension: supplier
    description: "Supplier name for purchase order in Magento"
    sql: ${TABLE}.supplier

  - dimension: owner
    description: "Owner/author name for purchase order in Magento"
    sql: ${TABLE}.po_author

  - dimension: terms
    description: "Payment terms for purchase order"
    sql: ${TABLE}.po_terms
    
  - dimension: predicted_invoice
    type: time
    description: "Date the 1st invoice will probably arrive, based on terms"
    sql: |
      CASE WHEN ISNUMERIC(${TABLE}.po_terms) = 1 AND ${TABLE}.po_status <> 'cancelled'
           THEN DATEADD(dd,CAST(${TABLE}.po_terms AS int),CASE WHEN ${TABLE}.po_status = 'New' AND ${TABLE}.po_ship_date < GETDATE()
                                                               THEN GETDATE()
                                                               WHEN ${TABLE}.po_arrival_date IS NOT NULL
                                                               THEN ${TABLE}.po_arrival_date
                                                               ELSE ${TABLE}.po_ship_date
                                                          END)
      END

  - dimension: order_number
    description: "Purchase order number in Magento"
    sql: ${TABLE}.po_order_id
    links:
      - label: 'Purchase Order'
        url: "https://admin.liveoutthere.com/index.php/inspire/purchase_orders/Edit/po_num/{{ purchase_orders.purchase_order_id._value }}"
        icon_url: 'https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico'

  - dimension_group: ship
    description: "Requested ship date"
    type: time
    sql: ${TABLE}.po_ship_date
    
  - measure: next_ship_date
    description: "The earliest ship date in the group of dimensions you have filtered"
    sql: MIN(CASE WHEN ${TABLE}.po_status != 'cancelled' AND ${TABLE}.po_arrival_date IS NULL AND ${TABLE}.po_cancel_date > GETDATE() THEN ${TABLE}.po_ship_date END)
    
  - measure: days_to_next_ship_date
    type: number
    description: "The number of days between now and the next ship date in the group of dimensions you have filtered"
    sql: DATEDIFF(d,GETDATE(),${next_ship_date})

  - dimension_group: created
    description: "Date the purchase order was created"
    type: time
    sql: ${TABLE}.po_date

  - dimension_group: arrival
    description: "Date the purchase order landed in the warehouse"
    type: time
    sql: ${TABLE}.po_arrival_date

  - dimension_group: cancel
    description: "Date the purchase order should be canceled if it has not arrived"
    type: time
    sql: ${TABLE}.po_cancel_date

  - dimension_group: 2_weeks_after_cancel
    description: "Date 2 weeks after the cancel date"
    type: time
    sql: DATEADD(week,2,${TABLE}.po_cancel_date)

  - dimension_group: 4_weeks_after_cancel
    description: "Date 4 weeks after the cancel date"
    type: time
    sql: DATEADD(week,4,${TABLE}.po_cancel_date)

  - dimension: is_past_cancel_date
    description: "Is 'Yes' if the purchase order is past its cancel date"
    type: yesno
    sql: ${TABLE}.po_cancel_date < CAST(GETDATE() AS date)

  - dimension: season
    description: "Season of the purchase order and whether it is a booking or closeout order"
    label: "Season"
    sql: ${TABLE}.po_carrier

  - dimension: status
    description: "Current status of the purchase order"
    sql_case:
      'New': ${TABLE}.po_status = 'New' 
      'Acknowledged': ${TABLE}.po_status = 'acknowledged'
      'Shipped': ${TABLE}.po_status = 'waiting_for_delivery'
      'Arrived': ${TABLE}.po_status = 'waiting_to_receive'
      'In Progress': ${TABLE}.po_status = 'in_progress'
      'Partial Receipt': ${TABLE}.po_status = 'in_progress_partial'
      'Complete': ${TABLE}.po_status = 'complete'
      'Cancelled': ${TABLE}.po_status = 'cancelled'
      'Closed': ${TABLE}.po_status = 'closed'
      'Unresolved Discrepancies': ${TABLE}.po_status = 'discrepancy'
      'Waiting for RA': ${TABLE}.po_status = 'waiting_for_supplier'
      else: unknown
      
  - dimension: inventory_type
    description: "Either Apparel, Gear, or Footwear. This is associated to the Purchase Order, not the product."
    sql: ${TABLE}.po_type

  - dimension: is_fully_delivered
    description: "Has the purchase order been fully delivered? i.e. there is no remaining quantity to receive"
    type: yesno
    sql: ${remaining_qty} = 0

  - measure: number_of_styles
    description: "Unique number of styles based on the Long Product Name"
    type: count_distinct
    sql: ${products.long_product_name}

  - measure: pop_discount
    description: "(Average) discount from Wholesale Cost from purchase order line item"
    label: "Discount %"
    type: average
    value_format: '0.00\%'
    sql: ${TABLE}.pop_discount

  - measure: pop_price_ht
    description: "Wholesale Cost from purchase order line item"
    type: sum
    label: "Wholesale Cost $"
    sql: ${TABLE}.pop_price_ht
    value_format: '$#,##0.00'
    
  - measure: cost_after_discount
    description: "Discounted Cost from purchase order line item"
    type: sum
    label: "Discounted Cost $"
    sql: ${TABLE}.discounted_cost
    value_format: '$#,##0.00'
    
  - measure: row_net_delivered_amount
    description: "Delivered amount (Discounted Cost) from purchase order line item"
    label: "Delivered Discounted $"
    type: sum
    sql: ${TABLE}.delivered_amount
    value_format: '$#,##0.00'

  - measure: row_net_delivered_amount_cost
    description: "Delivered amount (Wholesale Cost) from purchase order line item"
    label: "Delivered Wholesale $"
    type: sum
    sql: ${TABLE}.delivered_amount_cost
    value_format: '$#,##0.00'

  - measure: row_net_delivered_amount_msrp
    description: "Delivered amount (Retail Price) from purchase order line item"
    label: "Delivered Retail $"
    type: sum
    sql: ${TABLE}.delivered_amount_msrp
    value_format: '$#,##0.00'

  - measure: row_net_ordered_amount
    description: "Ordered amount (Discounted Cost) from purchase order line item"
    label: "Ordered Discounted $"
    type: sum
    sql: ${TABLE}.ordered_amount
    value_format: '$#,##0.00'

  - measure: row_net_ordered_amount_cost
    description: "Ordered amount (Wholesale Cost) from purchase order line item"
    label: "Ordered Wholesale $"
    type: sum
    sql: ${TABLE}.ordered_amount_cost
    value_format: '$#,##0.00'

  - measure: row_net_ordered_amount_msrp
    description: "Ordered amount (Retail Price) from purchase order line item"
    label: "Ordered Retail $"
    type: sum
    sql: ${TABLE}.ordered_amount_msrp
    value_format: '$#,##0.00'

  - measure: remaining_amount
    description: "Remaining amount (Discounted Cost) from purchase order line item"
    label: "Remaining Discounted $"
    type: number
    sql: ${row_net_ordered_amount} - ${row_net_delivered_amount}
    value_format: '$#,##0.00'

  - measure: remaining_amount_cost
    description: "Remaining amount (Wholesale Cost) from purchase order line item"
    label: "Remaining Wholesale $"
    type: number
    sql: ${row_net_ordered_amount_cost} - ${row_net_delivered_amount_cost}
    value_format: '$#,##0.00'
    
  - measure: remaining_amount_msrp
    description: "Remaining amount (Retail Price) from purchase order line item"
    label: "Remaining Retail $"
    type: number
    sql: ${row_net_ordered_amount_msrp} - ${row_net_delivered_amount_msrp}
    value_format: '$#,##0.00'

  - measure: row_qty
    description: "Number of units that were ordered"
    label: "Ordered Quantity"
    type: sum
    sql: ${TABLE}.pop_qty

  - measure: quantity_on_order
    description: "Number of units that are still on order from purchase orders that don't have a recorded arrival date and have not been cancelled."
    type: sum
    sql: CASE WHEN ${TABLE}.po_status != 'cancelled' AND ${TABLE}.po_arrival_date IS NULL AND ${TABLE}.po_cancel_date > GETDATE() THEN ${TABLE}.pop_qty END

  - measure: row_delivered_qty
    description: "Number of units that were delivered"
    label: "Delivered Quantity"
    type: sum
    sql: ${TABLE}.pop_supplied_qty

  - measure: remaining_qty
    label: "Remaining Quantity"
    description: "Number of units that are remaining to be delivered"
    type: number
    sql: ${row_qty} - ${row_delivered_qty}

  - measure: percent_of_total_delivered_msrp
    description: "Percent of total delivered amount (Retail Price) of this result vs. all results"
    label: "% of Total - Delivered Retail $"
    type: percent_of_total
    sql: ${row_net_delivered_amount_msrp}
    
  - measure: percent_delivered
    description: "Percentage of ordered quantity that has been delivered"
    label: "Delivery %"
    type: number
    value_format: '0.00\%'
    sql: 100 * (${row_net_delivered_amount} / ${row_net_ordered_amount})
    
  - measure: count
    description: "Count of unique purchase order lines"
    label: "# of Lines / SKUs"
    type: count_distinct
    sql: ${TABLE}.pop_num
    
  - measure: count_purchase_orders
    description: "Count of unique purchase orders"
    type: count_distinct
    sql: ${TABLE}.po_order_id
    

