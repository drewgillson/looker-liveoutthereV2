view: sales_shipping_tracking {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY order_id) AS row, a.* FROM (
        SELECT a.order_id, a.title, a.track_number, COALESCE(c.is_customer_notified,b.email_sent) AS email_sent, b.created_at
        FROM magento.sales_flat_shipment_track AS a
        INNER JOIN magento.sales_flat_shipment AS b
          ON a.parent_id = b.entity_id
        INNER JOIN magento.sales_flat_shipment_comment AS c
          ON b.entity_id = c.parent_id AND c.is_customer_notified = 1
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

  dimension: email_sent {
    label: "Email Sent?"
    type: yesno
    sql: ${TABLE}.email_sent = 1 ;;
  }
}
