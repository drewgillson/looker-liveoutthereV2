view: purchase_order_invoices {
  sql_table_name: magento.purchase_order_invoice ;;

  dimension: poi_num {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.poi_num ;;
  }

  dimension: poi_order_num {
    hidden: yes
    sql: ${TABLE}.poi_order_num ;;
  }

  dimension_group: created {
    description: "Recorded invoice date from Magento"
    type: time
    sql: ${TABLE}.poi_invoice_date ;;
  }

  dimension_group: due {
    description: "Recorded invoice due date from Magento"
    type: time
    sql: ${TABLE}.poi_invoice_due ;;
  }

  dimension: reference_number {
    description: "Recorded invoice reference number from Magento"
    sql: ${TABLE}.poi_invoice_ref ;;
  }

  dimension: terms {
    description: "Recorded terms from Magento"
    sql: ${TABLE}.poi_invoice_terms ;;
  }

  dimension: has_been_paid {
    description: "Is 'Yes' if an invoice is marked as Paid"
    type: yesno
    sql: ${TABLE}.poi_paid = 1 ;;
  }

  dimension: invoice_amount {
    description: "Recorded invoice amount from Magento"
    label: "Invoice Amount $"
    type: number
    sql: ${TABLE}.poi_invoice_amount ;;
    value_format: "$#,##0.00"
  }

  measure: invoice_grand_total {
    description: "Sum of recorded invoice amounts from Magento"
    label: "Invoice Amount $"
    type: sum
    sql: ${TABLE}.poi_invoice_amount ;;
    value_format: "$#,##0.00"
  }

  measure: invoice_count {
    description: "Unique number of invoices"
    type: count_distinct
    sql: ${TABLE}.poi_num ;;
  }
}
