view: transactions_paypal_settlement {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY [Transaction Initiation Date]) AS row
      , [Transaction ID] AS transaction_id, * FROM (
        SELECT *
            , DATEADD(hh,4,[Transaction Completion Date]) AS completion_mst
            , DATEADD(hh,4,[Transaction Initiation Date]) AS initiation_mst
        FROM tbl_RawData_PayPal_Settlement
      ) AS a
       ;;
    indexes: ["transaction_id"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  dimension: transaction_id {
    label: "PayPal Txn ID"
    type: string
    sql: ${TABLE}.transaction_id ;;
    link: {
      label: "PayPal Transaction"
      url: "https://history.paypal.com/webscr?cmd=_history-details-from-hub&id={{ value }}"
      icon_url: "http://www.bobsleighcanadaskeleton.ca/images/favicon.paypal.16.png"
    }
  }

  dimension: fee_currency {
    type: string
    sql: ${TABLE}."Fee Currency" ;;
  }

  dimension: fee_debit_or_credit {
    type: string
    sql: ${TABLE}."Fee Debit or Credit" ;;
  }

  dimension: gross_transaction_currency {
    type: string
    sql: ${TABLE}."Gross Transaction Currency" ;;
  }

  dimension: pay_pal_reference_id {
    type: string
    sql: ${TABLE}."PayPal Reference ID" ;;
  }

  dimension: pay_pal_reference_id_type {
    type: string
    sql: ${TABLE}."PayPal Reference ID Type" ;;
  }

  dimension: transaction_debit_or_credit {
    type: string
    sql: ${TABLE}."Transaction  Debit or Credit" ;;
  }

  dimension_group: transaction_completion {
    type: time
    sql: ${TABLE}.completion_mst ;;
  }

  dimension: transaction_event_code {
    type: string
    sql: ${TABLE}."Transaction Event Code" ;;
  }

  dimension: transaction_event_description {
    type: string

    case: {
      when: {
        sql: ${transaction_event_code} = 'T1106' ;;
        label: "Payment Reversal, initiated by PayPal"
      }

      when: {
        sql: ${transaction_event_code} = 'T1107' ;;
        label: "Payment Refund, initiated by merchant"
      }

      when: {
        sql: ${transaction_event_code} = 'T1111' ;;
        label: "Cancellation of Hold for Dispute Resolution"
      }

      when: {
        sql: ${transaction_event_code} = 'T0300' ;;
        label: "General Funding of PayPal Account"
      }

      when: {
        sql: ${transaction_event_code} = 'T0400' ;;
        label: "General Withdrawal from PayPal Account"
      }

      when: {
        sql: ${transaction_event_code} = 'T0006' ;;
        label: "Payment from Express Checkout API"
      }

      when: {
        sql: ${transaction_event_code} = 'T0000' ;;
        label: "General: sent/received payment"
      }

      when: {
        sql: ${transaction_event_code} = 'T1110' ;;
        label: "Hold for Dispute Investigation"
      }

      when: {
        sql: ${transaction_event_code} = 'T2001' ;;
        label: "Settlement Consolidation"
      }

      else: "unknown"
    }
  }

  dimension_group: transaction_initiation {
    type: time
    sql: ${TABLE}.initiation_mst ;;
  }

  measure: fee_amount {
    type: sum
    label: "PayPal Fee $"
    description: "PayPal fee amount"
    value_format: "$#,##0.00;($#,##0.00)"
    sql: CASE WHEN ${fee_debit_or_credit} = 'CR' THEN ${TABLE}."Fee Amount" WHEN ${fee_debit_or_credit} = 'DR' THEN -${TABLE}."Fee Amount" END
      ;;
  }

  measure: gross_transaction_amount {
    description: "Total amount collected by PayPal, including taxes"
    label: "PayPal Collected $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: CASE WHEN ${transaction_debit_or_credit} = 'CR' THEN ${TABLE}."Gross Transaction Amount" WHEN ${transaction_debit_or_credit} = 'DR' THEN -${TABLE}."Gross Transaction Amount" END
      ;;
  }

  measure: tax_amount {
    type: sum
    label: "Paypal Tax $"
    description: "Tax amount collected by PayPal"
    value_format: "$#,##0.00;($#,##0.00)"
    sql: CASE WHEN ${transaction_debit_or_credit} = 'CR' THEN -(${TABLE}."Gross Transaction Amount" - (${TABLE}."Gross Transaction Amount" / (1 + (${tax.percent} / 100))))
           WHEN ${transaction_debit_or_credit} = 'DR' THEN ${TABLE}."Gross Transaction Amount" - (${TABLE}."Gross Transaction Amount" / (1 + (${tax.percent} / 100)))
      END
       ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
