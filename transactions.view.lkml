view: transactions {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY [entity_id]) AS row, * FROM (
        SELECT 'sale' AS type, 'LiveOutThere.com' AS storefront, a.entity_id, a.created_at, a.increment_id, NULL AS credit_memo_id, NULL AS authorization_number, ISNULL(a.giftcert_amount,0) + ISNULL(a.gift_voucher_discount,0) AS giftcert_amount, ISNULL(a.customer_credit_amount,0) + ISNULL(a.use_gift_credit_amount,0) AS customer_credit_amount, b.amount_paid AS grand_total, a.subtotal, a.tax_amount, a.shipping_amount, b.method AS payment_method, CASE WHEN b.method = 'optimal_hosted' AND b.cc_type IS NULL THEN magento.extractValueFromSerializedPhpString('brand',b.additional_information) ELSE b.cc_type END AS cc_type, b.cc_trans_id AS transaction_id
        FROM magento.sales_flat_order AS a
        LEFT JOIN magento.sales_flat_order_payment AS b
          ON a.entity_id = b.parent_id
        WHERE a.marketplace_order_id IS NULL
        UNION ALL
        SELECT 'credit', 'LiveOutThere.com', a.order_id, a.created_at, a.increment_id, a.entity_id, NULL, -a.giftcert_amount, -a.customer_credit_amount, -a.grand_total, -a.subtotal, CASE WHEN a.tax_amount IS NULL OR a.tax_amount = 0 THEN -CAST(a.grand_total - (a.grand_total / (1 + (b.[percent] / 100))) AS money) ELSE -a.tax_amount END AS tax_amount, -a.shipping_amount, c.method, CASE WHEN c.method = 'optimal_hosted' AND c.cc_type IS NULL THEN magento.extractValueFromSerializedPhpString('brand',c.additional_information) ELSE c.cc_type END AS cc_type, a.transaction_id
        FROM magento.sales_flat_creditmemo AS a
        LEFT JOIN magento.sales_order_tax AS b
          ON a.order_id = b.order_id AND b.position = 1
        LEFT JOIN magento.sales_flat_order_payment AS c
          ON a.order_id = c.parent_id
        UNION ALL
        SELECT CASE WHEN [order-transactions-kind] = 'refund' THEN 'credit' ELSE [order-transactions-kind] END, 'TheVan.ca', CAST([order-order_number] AS nvarchar(10)), [order-transactions-created_at], CAST([order-order_number] AS nvarchar(10)), NULL, [order-transactions-authorization], NULL, NULL, NULL, NULL, NULL, NULL, [order-transactions-gateway], [order-payment_method], NULL
        FROM shopify.transactions
        WHERE [order-transactions-status] = 'success'
        UNION ALL
        SELECT 'sale', 'Amazon', entity_id, created_at, increment_id, NULL, NULL, NULL, NULL, grand_total, subtotal, tax_amount, shipping_amount, 'Amazon', NULL, NULL
        FROM magento.sales_flat_order
        WHERE marketplace_order_id IS NOT NULL
      ) AS a
       ;;
    indexes: ["storefront", "entity_id"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.row ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: entity_id {
    type: string
    hidden: yes
    sql: ${TABLE}.entity_id ;;
  }

  dimension: credit_memo_id {
    type: string
    hidden: yes
    sql: ${TABLE}.credit_memo_id ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}.increment_id ;;

    link: {
      label: "Magento Sales Order"
      url: "https://admin.liveoutthere.com/index.php/inspire/sales_order/view/order_id/{{ reconciliation.entity_id._value }}"
      icon_url: "https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico"
    }

    link: {
      label: "Magento Credit Memo"
      url: "https://admin.liveoutthere.com/index.php/inspire/sales_creditmemo/view/creditmemo_id/{{ reconciliation.credit_memo_id._value }}"
      icon_url: "https://www.liveoutthere.com/skin/adminhtml/default/default/favicon.ico"
    }
  }

  dimension: storefront {
    type: string
    sql: ${TABLE}.storefront ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}.payment_method ;;
  }

  dimension: card_type {
    type: string
    sql: CASE WHEN ${TABLE}.cc_type = 'AE' OR ${TABLE}.cc_type = 'AM' OR ${TABLE}.cc_type = 'American Express' THEN 'American Express'
           WHEN ${TABLE}.cc_type = 'VI' OR ${TABLE}.cc_type = 'Visa' THEN 'Visa'
           WHEN ${TABLE}.cc_type = 'MC' OR ${TABLE}.cc_type = 'MasterCard' THEN 'MasterCard'
           ELSE ${TABLE}.cc_type
      END
       ;;
  }

  dimension: reference {
    type: string
    sql: CASE WHEN ${netbanx_transactions.transaction_number} IS NOT NULL THEN ${netbanx_transactions.transaction_number}
           WHEN ${paypal_settlement.transaction_id} IS NOT NULL THEN ${paypal_settlement.transaction_id}
      END
       ;;
  }

  measure: total_expected {
    description: "Total amount charged to customer, including taxes, shipping, redeemed gift cards, and customer credit"
    label: "Total Charged $"
    type: number
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${grand_total} + ${redeemed_amount} ;;
  }

  measure: grand_total {
    hidden: yes
    type: sum
    sql: ${TABLE}.grand_total ;;
  }

  measure: tax_expected {
    description: "Tax charged to customer"
    label: "Tax Charged $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.tax_amount ;;
  }

  measure: shipping_collected {
    description: "Shipping charged to customer"
    label: "Shipping Charged $"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.shipping_amount ;;
  }

  measure: redeemed_amount {
    description: "Total amount of gift certificates and customer credit redeemed"
    label: "Redeemed Gift Certs & Credit"
    type: number
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${gift_certificate_amount} + ${customer_credit_amount} ;;
  }

  measure: gift_certificate_amount {
    description: "Amount of redeemed gift cards"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.giftcert_amount ;;
  }

  measure: customer_credit_amount {
    description: "Amount of redeemed customer credit"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: ${TABLE}.customer_credit_amount ;;
  }
}
