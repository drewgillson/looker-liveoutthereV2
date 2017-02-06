view: sales_return_authorizations {
  derived_table: {
    sql: SELECT *, ROW_NUMBER() OVER (ORDER BY id) AS row FROM (
        SELECT a.id
          , a.created_at
          , a.order_id AS increment_id
          , CAST(d.track_number AS varchar(255)) AS track_number
          , CAST(SUM(f.qty) / COUNT(DISTINCT a.id) AS int) AS items_refunded
          , 'Canada Post' AS return_service
          , a.request_type
          , a.status
          , COALESCE(g.ot_caption,CAST(a.reason_details AS nvarchar(max))) AS reason_details
          , return_posted.ot_created_at AS return_posted
          , delivery_posted.ot_created_at AS delivery_posted
        FROM magento.aw_rma_entity AS a
        LEFT JOIN magento.sales_flat_order AS b
          ON a.order_id = b.increment_id
        LEFT JOIN magento.sales_flat_shipment AS c
          ON b.entity_id = c.order_id
        LEFT JOIN magento.sales_flat_shipment_track AS d
          ON c.entity_id = d.parent_id AND d.title LIKE 'Return%'
        LEFT JOIN magento.sales_flat_creditmemo AS e
          ON b.entity_id = e.order_id
        LEFT JOIN magento.sales_flat_creditmemo_item AS f
          ON e.entity_id = f.parent_id
        LEFT JOIN (SELECT DISTINCT ot_entity_id, ot_created_at, ot_caption FROM magento.organizer_task WHERE ot_caption = 'Holiday Return Exception') AS g
          ON b.entity_id = g.ot_entity_id
        LEFT JOIN (SELECT DISTINCT ot_entity_id, ot_created_at, ot_caption FROM magento.organizer_task WHERE ot_caption = 'Return item accepted at Post Office') AS return_posted
          ON b.entity_id = return_posted.ot_entity_id
        LEFT JOIN (SELECT DISTINCT ot_entity_id, ot_created_at, ot_caption FROM magento.organizer_task WHERE ot_caption = 'Delivered' AND ot_description NOT LIKE 'Return for order%') AS delivery_posted
          ON b.entity_id = delivery_posted.ot_entity_id
        GROUP BY a.id, a.created_at, a.order_id, CAST(d.track_number AS varchar(255)), a.request_type, a.status, CAST(a.reason_details AS nvarchar(max)),g.ot_caption,return_posted.ot_created_at,delivery_posted.ot_created_at
      ) AS x
       ;;
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
    indexes: ["increment_id"]
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  measure: count {
    type: count
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivery_posted {
    type: time
    sql: ${TABLE}.delivery_posted ;;
  }

  dimension_group: return_posted {
    type: time
    sql: ${TABLE}.return_posted ;;
  }

  dimension: days_elapsed {
    description: "Days between delivery posted date and return posted date"
    type: number
    value_format: "#"
    sql: DATEDIFF(dd,${TABLE}.delivery_posted,${TABLE}.return_posted) ;;
  }

  dimension: increment_id {
    type: number
    sql: ${TABLE}.increment_id ;;
  }

  dimension: reason_details {
    type: string
    sql: ${TABLE}.reason_details ;;
  }

  dimension: status {
    type: string

    case: {
      when: {
        sql: ${TABLE}.status = 1 ;;
        label: "Pending Approval"
      }

      when: {
        sql: ${TABLE}.status = 2 ;;
        label: "Approved"
      }

      when: {
        sql: ${TABLE}.status = 3 ;;
        label: "Package sent"
      }

      when: {
        sql: ${TABLE}.status = 4 ;;
        label: "Resolved (canceled)"
      }

      when: {
        sql: ${TABLE}.status = 5 ;;
        label: "Resolved (refunded)"
      }

      when: {
        sql: ${TABLE}.status = 6 ;;
        label: "Resolved (replaced)"
      }
    }
  }

  dimension: request_type {
    type: string

    case: {
      when: {
        sql: ${TABLE}.request_type = 1 ;;
        label: "Refund - Wrong Size"
      }

      when: {
        sql: ${TABLE}.request_type = 2 ;;
        label: "Refund - Wrong Colour"
      }

      when: {
        sql: ${TABLE}.request_type = 3 ;;
        label: "Warranty Issue"
      }

      when: {
        sql: ${TABLE}.request_type = 5 ;;
        label: "Refund - Not As Expected"
      }

      when: {
        sql: ${TABLE}.request_type = 6 ;;
        label: "Other"
      }

      when: {
        sql: ${TABLE}.request_type = 10 ;;
        label: "Refund - Found Better Price"
      }
    }

    html:
      {% if value == 'Warranty Issue' %}
        <font color="red"><strong>{{ rendered_value }}</strong></font>
      {% elsif value == 'Other' %}
        <font color="red"><strong>{{rendered_value}}</strong></font>
      {% else %}
        {{rendered_value}}
      {% endif %} ;;
  }

  dimension: return_service {
    type: string
    sql: ${TABLE}.return_service ;;
  }

  dimension: track_number {
    type: string
    sql: '''' + CAST(${TABLE}.track_number AS varchar(255)) ;;
  }

  measure: items_refunded {
    type: sum
    sql: ${TABLE}.items_refunded ;;
  }

  measure: orders_refunded {
    type: sum
    sql: CASE WHEN ${TABLE}.items_refunded > 1 THEN 1 ELSE ${TABLE}.items_refunded END
      ;;
  }
}
