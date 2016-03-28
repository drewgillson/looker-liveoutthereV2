- view: sales_shipping_charges
  derived_table:
    sql: |
      SELECT ROW_NUMBER() OVER (ORDER BY order_id) AS row, a.* FROM (
        SELECT a.order_id
          , a.shipping_charge AS outbound_shipping_charge
          , b.shipping_charge AS return_shipping_charge
        FROM (
          -- Outbound shipments from Magento:
          SELECT a.order_id
             , SUM(b.Total_Charges - b.GST_Amount) AS shipping_charge
          FROM magento.sales_flat_shipment_track AS a
          INNER JOIN dbo.report_Canada_Post_Shipment_Details AS b
            ON CAST(a.track_number AS varchar(255)) = b.Product_Id
          WHERE a.title LIKE 'Shipment for order%' OR title = 'OTHER'
          GROUP BY a.order_id
          UNION ALL
          -- Outbound shipments from Shopify:
          SELECT c.[order-id] AS order_id
             , SUM(b.Total_Charges - b.GST_Amount) AS shipping_charge
          FROM shopify.order_trackings AS a
          INNER JOIN dbo.report_Canada_Post_Shipment_Details AS b
            ON CAST(a.[order-fulfillments-tracking_number] AS varchar(255)) = b.Product_Id
          INNER JOIN shopify.transactions AS c
            ON a.[order-number] = c.[order-order_number]
          GROUP BY c.[order-id]
        ) AS a
        LEFT JOIN (
          -- Return shipments from Magento:
          SELECT a.order_id
             , SUM(b.Total_Charges - b.GST_Amount) AS shipping_charge
          FROM magento.sales_flat_shipment_track AS a
          INNER JOIN dbo.report_Canada_Post_Shipment_Details AS b
            ON CAST(a.track_number AS varchar(255)) = b.Product_Id
          WHERE a.title LIKE 'Return for order%'
          GROUP BY a.order_id
          -- Return shipments from Shopify are missing because we don't record tracking numbers!
        ) AS b
        ON a.order_id = b.order_id
      ) AS a
    indexes: [order_id]
    sql_trigger_value: |
      SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)

  fields:

  - dimension: row
    primary_key: true
    hidden: true
    type: number
    sql: ${TABLE}.row
    
  - dimension: order_id
    hidden: true
    type: number
    sql: ${TABLE}.order_id

  - measure: outbound_shipping_charge
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.outbound_shipping_charge

  - measure: return_shipping_charge
    type: sum
    value_format: '$#,##0'
    sql: ${TABLE}.return_shipping_charge

  - measure: total_shipping_charge
    type: number
    value_format: '$#,##0'
    sql: ${outbound_shipping_charge} + ${return_shipping_charge}


