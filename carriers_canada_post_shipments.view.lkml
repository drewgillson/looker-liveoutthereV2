view: carriers_canada_post_shipments {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY b.order_id) AS id
           , a.*
           , CAST(b.order_id AS varchar(50)) AS order_entity_id
      FROM (SELECT Int_Sys_Date_Time
                 , Invoice_Date
                 , Invoice_Due_Date
                 , Invoice_Num
                 , SUM(CASE WHEN ISNUMERIC(Additional_Coverage_Charge) = 1 THEN CAST(Additional_Coverage_Charge AS money) END) AS Additional_Coverage_Charge
                 , Manifest_SOM_PO_Date
                 , Manifest_SOM_PO_Num
                 , Service_Desc
                 , Rate_Code_Return_Service_Desc
                 , Product_Id
                 , GST_HST_Tax_Status
                 , Provincial_Tax_Code
                 , SUM(CASE WHEN ISNUMERIC(Total_Charges) = 1 THEN CAST(Total_Charges AS money) END) AS Total_Charges
                 , SUM(CASE WHEN ISNUMERIC(Transportation_Charge) = 1 THEN CAST(Transportation_Charge AS money) END) AS Transportation_Charge
                 , SUM(CASE WHEN ISNUMERIC(Weight_per_piece) = 1 THEN CAST(Weight_per_piece AS float) END) AS Weight_per_piece
                 , SUM(CASE WHEN ISNUMERIC(Weight_price) = 1 THEN CAST(Weight_price AS money) END) AS Weight_price
                 , SUM(CASE WHEN ISNUMERIC(Base_Charge) = 1 THEN CAST(Base_Charge AS money) END) AS Base_Charge
                 , SUM(CASE WHEN ISNUMERIC(Automation_Discount_Value + '.0e0') = 1 THEN CAST(Automation_Discount_Value AS money) END) AS Automation_Discount_Value
                 , SUM(CASE WHEN ISNUMERIC(Fuel_Surcharge_Amount + '.0e0') = 1 THEN CAST(Fuel_Surcharge_Amount AS money) END) AS Fuel_Surcharge_Amount
                 , SUM(CASE WHEN ISNUMERIC(GST_Amount) = 1 THEN CAST(GST_Amount AS money) END) AS GST_Amount
                 , SUM(CASE WHEN ISNUMERIC(HST_Amount) = 1 THEN CAST(HST_Amount AS money) END) AS HST_Amount
            FROM report_Canada_Post_Shipment_Details
            GROUP BY Int_Sys_Date_Time, Invoice_Date, Invoice_Due_Date, Invoice_Num, Manifest_SOM_PO_Date, Manifest_SOM_PO_Num, Service_Desc, Rate_Code_Return_Service_Desc, Product_Id, GST_HST_Tax_Status, Provincial_Tax_Code
      ) AS a
      LEFT JOIN (SELECT track_number, order_id FROM magento.sales_flat_shipment_track) AS b
        ON a.Product_Id = CAST(b.track_number AS varchar(255))
       ;;
    indexes: ["product_id", "order_entity_id"]
    sql_trigger_value: SELECT COUNT(*) FROM report_Canada_Post_Shipment_Details
      ;;
  }

  dimension: id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension_group: accepted {
    type: time
    sql: ${TABLE}.Int_Sys_Date_Time ;;
    description: "Dates that shipments were picked up by Canada Post"
  }

  dimension_group: invoice {
    type: time
    sql: ${TABLE}.Invoice_Date ;;
    description: "Dates on Canada Post invoices"
  }

  dimension_group: manifest_som_po {
    type: time
    sql: ${TABLE}.Manifest_SOM_PO_Date ;;
  }

  dimension_group: invoice_due {
    type: time
    sql: ${TABLE}.Invoice_Due_Date ;;
    description: "Dates that Canada Post invoices are due"
  }

  dimension: invoice_reference_number {
    sql: ${TABLE}.Invoice_Num ;;
    description: "Canada Post invoice reference numbers"
  }

  measure: additional_coverage_charge {
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.Additional_Coverage_Charge ;;
  }

  dimension: manifest_som_po_num {
    sql: ${TABLE}.Manifest_SOM_PO_Num ;;
  }

  dimension: service_description {
    sql: ${TABLE}.Service_Desc ;;
  }

  dimension: rate_code_return_service_description {
    sql: ${TABLE}.Rate_Code_Return_Service_Desc ;;
  }

  dimension: tracking_code {
    sql: ${TABLE}.Product_Id ;;
    description: "Unique customer-facing tracking codes for Canada Post packages"
  }

  dimension: taxes_applied {
    sql: ${TABLE}.GST_HST_Tax_Status ;;
  }

  dimension: province {
    sql: ${TABLE}.Provincial_Tax_Code ;;
  }

  measure: transportation_charge {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.Transportation_Charge ;;
  }

  measure: weight_per_piece {
    type: average
    value_format: "0.00"
    sql: ${TABLE}.Weight_per_piece ;;
  }

  measure: weight_price {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.Weight_price ;;
  }

  measure: base_charge {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.Base_Charge ;;
  }

  measure: automation_discount_value {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.Automation_Discount_Value ;;
  }

  measure: fuel_surcharge_amount {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.Fuel_Surcharge_Amount ;;
  }

  measure: total_charges {
    type: sum
    hidden: yes
    sql: ${TABLE}.Total_Charges ;;
  }

  measure: average_rate_per_order {
    type: number
    value_format: "$#,##0.00"
    sql: (${avg_total_charges} - ${avg_gst_amount} - ${avg_hst_amount}) ;;
    description: "The average net charge per order"
  }

  measure: total_gross_charge {
    type: number
    value_format: "$#,##0.00"
    sql: ${total_charges} ;;
  }

  measure: total_net_charge {
    type: number
    value_format: "$#,##0.00"
    sql: ${total_charges} - ${gst_amount} - ${hst_amount} ;;
    description: "The total net cost of shipping"
  }

  measure: gst_amount {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.GST_Amount ;;
  }

  measure: hst_amount {
    type: sum
    value_format: "$#,##0.00"
    sql: ${TABLE}.HST_Amount ;;
  }

  measure: avg_total_charges {
    type: average
    hidden: yes
    sql: ${TABLE}.Total_Charges ;;
  }

  measure: avg_gst_amount {
    type: average
    hidden: yes
    sql: ${TABLE}.GST_Amount ;;
  }

  measure: avg_hst_amount {
    type: average
    hidden: yes
    sql: ${TABLE}.HST_Amount ;;
  }

  measure: count {
    type: count_distinct
    sql: ${TABLE}.Product_Id ;;
  }
}
