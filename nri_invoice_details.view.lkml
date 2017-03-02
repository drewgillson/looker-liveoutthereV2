view: nri_invoice_details {
  sql_table_name: NRI_Invoice_Details ;;

  dimension: id {
    type: number
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.OrderId ;;
  }

  dimension: client_ref1 {
    label: "Client Reference 1"
    type: number
    sql: ${TABLE}.ClientRef1 ;;
  }

  dimension: client_ref2 {
    label: "Client Reference 2"
    type: string
    sql: ${TABLE}.ClientRef2 ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}.Customer ;;
  }

  dimension: ponumber {
    type: string
    sql: ${TABLE}.PONumber ;;
  }

  dimension: service {
    type: string
    sql: ${TABLE}.Service ;;
  }

  dimension: service_type {
    type: string

    case: {
      when: {
        sql: ${service} = 'Handling' OR ${service} = 'Label Application' OR ${service} = 'Order Manual Data Entry' OR ${service} = 'Order Processing' OR ${service} = 'Order Restocking' OR ${service} = 'Outbound Shipment Materials' OR ${service} = 'Shipment Cancellation' OR ${service} = '' OR ${service} = '' OR ${service} = '' ;;
        label: "Outbound"
      }

      when: {
        sql: ${service} = 'Receipt Carton' OR ${service} = 'Inbound Pallets' OR ${service} = 'Project Labour' OR ${service} = 'Receipt Processing' OR ${service} = 'Receiving' OR ${service} = 'Restock' OR ${service} = 'Tagging' ;;
        label: "Inbound"
      }

      when: {
        sql: ${service} = 'Returns' OR ${service} = 'Service Center Labor' OR ${service} = 'Shop Supplies' ;;
        label: "Returns"
      }

      when: {
        sql: ${service} = 'Inbound Freight' OR ${service} = 'Outbound Freight' OR ${service} = 'Returns Freight' ;;
        label: "Freight"
      }

      when: {
        sql: ${service} = 'Photography' OR ${service} = 'Warehouse Labour' OR ${service} = 'Data Entry Labour' OR ${service} = 'Physical Count'  OR ${service} = 'Manual BOL' ;;
        label: "Labour"
      }

      when: {
        sql: ${service} = 'Cycle Count Units' OR ${service} = 'Storage' OR ${service} = 'Storage Carton Shipped' OR ${service} = 'Quality Control' ;;
        label: "Storage"
      }

      when: {
        sql: ${service} = 'IT Time' ;;
        label: "IT"
      }

      else: "unknown"
    }
  }

  dimension_group: doc_date {
    type: time
    sql: ${TABLE}.DocDate ;;
  }

  dimension_group: completed {
    type: time
    sql: ${TABLE}.Completed ;;
  }

  measure: units {
    type: sum
    value_format: "#"
    sql: ${TABLE}.Units ;;
  }

  measure: value {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.Value ;;
  }

  measure: average_charge {
    type: average
    value_format: "$#,##0.00"
    sql: ${TABLE}.Charges ;;
  }

  measure: charges {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.Charges ;;
  }

  measure: taxes {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.Taxes ;;
  }

  measure: invoice_amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.InvoiceAmount ;;
  }

  measure: orders {
    type: count_distinct
    sql: ${TABLE}.ClientRef1 ;;
  }

  measure: cost_per_order {
    type: number
    value_format: "$#,##0.00"
    sql: ${charges} / NULLIF(${orders},0) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [order_id, client_ref1, client_ref2, customer, ponumber, doc_date_time, completed_time, units, value, service, charges, taxes, invoice_amount]
  }
}
