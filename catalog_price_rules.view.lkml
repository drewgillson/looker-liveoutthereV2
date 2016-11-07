view: catalog_price_rules {
  suggestions: no
  # OPENQUERY is used in this view because we always want recent prices from the Magento catalog price index
  derived_table: {
    sql: SELECT * FROM OPENQUERY(MAGENTO,'
      SELECT ''Production'' AS environment
           , a.rule_product_id
           , a.product_id
           , b.name
           , b.description
           , b.is_active
           , b.from_date
           , b.to_date
           , a.rule_id
           , a.action_operator
           , a.action_amount
           , a.action_stop
           , a.sort_order
      FROM catalogrule_product AS a
      INNER JOIN catalogrule AS b
        ON a.rule_id = b.rule_id
      WHERE a.customer_group_id = 0')
      UNION ALL
      SELECT * FROM OPENQUERY(STAGING,'
      SELECT ''Staging'' AS environment
           , a.rule_product_id
           , a.product_id
           , b.name
           , b.description
           , b.is_active
           , b.from_date
           , b.to_date
           , a.rule_id
           , a.action_operator
           , a.action_amount
           , a.action_stop
           , a.sort_order
      FROM catalogrule_product AS a
      INNER JOIN catalogrule AS b
        ON a.rule_id = b.rule_id
      WHERE a.customer_group_id = 0')
       ;;
    indexes: ["product_id"]
    persist_for: "8 hours"
  }

  dimension: environment {
    description: "Either 'Production' or 'Staging'. This dimension needs to be filtered when you use dimensions or measures from this view, otherwise you will get duplicate results."
    sql: ${TABLE}.environment ;;
    suggestions: ["Production", "Staging"]
  }

  dimension: rule_product_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.rule_product_id ;;
  }

  dimension: name {
    description: "Name of the Catalog Price Rule in Magento"
    sql: ${TABLE}.name ;;
  }

  dimension: description {
    description: "Description of the Catalog Price Rule in Magento"
    sql: CAST(${TABLE}.description AS varchar(512)) ;;
  }

  dimension: is_active {
    description: "Is 'Yes' if this Catalog Price Rule is active in Magento"
    type: yesno
    sql: (${TABLE}.is_active = 1) ;;
  }

  dimension_group: from {
    description: "Date this Catalog Price Rule is active from"
    type: time
    timeframes: [date]
    sql: ${TABLE}.from_date ;;
  }

  dimension_group: to {
    description: "Date this Catalog Price Rule is active through (until 11:59pm of *this* date)"
    type: time
    timeframes: [date]
    sql: ${TABLE}.to_date ;;
  }

  dimension: rule_id {
    description: "ID of the Catalog Price Rule in Magento"
    sql: ${TABLE}.rule_id ;;
  }

  dimension: action_operator {
    description: "Type of discount this Catalog Price Rule applies"
    sql: ${TABLE}.action_operator ;;
  }

  dimension: action_amount {
    description: "Used in combination with Action Operator to determine the discount"
    sql: ${TABLE}.action_amount ;;
  }

  dimension: action_stop {
    description: "Is 'Yes' if this rule prevents other rules from applying once it has been applied"
    type: yesno
    sql: (${TABLE}.action_stop = 1) ;;
  }

  dimension: sort_order {
    description: "Sort order / priority that this Catalog Price Rule is evaluated in Magento"
    sql: ${TABLE}.sort_order ;;
  }
}
