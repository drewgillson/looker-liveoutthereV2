view: sales_shipping_tracking {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY order_id) AS row, a.* FROM (
        SELECT a.order_id, b.title AS title, b.track_number, COALESCE(c.is_customer_notified,a.email_sent) AS email_sent, a.created_at
        FROM magento.sales_flat_shipment AS a
        LEFT JOIN magento.sales_flat_shipment_track AS b
          ON a.entity_id = b.parent_id
        LEFT JOIN magento.sales_flat_shipment_comment AS c
          ON b.entity_id = c.parent_id AND c.is_customer_notified = 1
        UNION ALL
        -- fill in recent missing shipments
        SELECT a.entity_id, NULL, NULL, 1 AS email_sent, a.created_at
        FROM magento.sales_flat_order AS a
        LEFT JOIN magento.sales_flat_shipment AS b
          ON a.entity_id = b.order_id
        WHERE (b.order_id IS NULL AND a.created_at >= '2016-10-31')
        AND a.state IN ('complete','closed') AND a.status IN ('complete','closed_refunded')
        UNION ALL
        SELECT b.[order-id] AS order_id, a.[order-fulfillments-tracking_company] + ' - ' + a.[order-fulfillments-service], a.[order-fulfillments-tracking_number], NULL, NULL
        FROM shopify.order_trackings AS a
        INNER JOIN shopify.transactions AS b
          ON a.[order-number] = b.[order-order_number]
      ) AS a
       ;;
    indexes: ["order_id"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.row ;;
  }

  dimension: order_id {
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: title {
    description: "Carrier code and service code for shipment"
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: tracking_number {
    description: "Tracking number for shipment"
    type: string
    sql: CAST(${TABLE}.track_number AS varchar(255)) ;;
  }

  dimension_group: shipped {
    description: "Shipment date/time"
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension: has_tracking_number {
    type: yesno
    sql: ${tracking_number} IS NOT NULL ;;
  }

  measure: email_sent {
    type:  count_distinct
    sql: ${TABLE}.order_id ;;
  }
}
