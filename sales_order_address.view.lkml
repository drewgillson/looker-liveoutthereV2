view: sales_order_address {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY entity_id) AS row
          , a.*
          , CAST(b.latitude AS decimal(9,6)) AS latitude
          , CAST(b.longitude AS decimal(9,6)) AS longitude
        FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY entity_id DESC) AS sequence, UPPER(REPLACE(REPLACE(postcode,' ',''),'-','')) AS postal_code
        FROM magento.sales_flat_order_address
        WHERE address_type = 'shipping'
        UNION ALL
        SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY entity_id DESC) AS sequence, UPPER(REPLACE(REPLACE(postcode,' ',''),'-','')) AS postal_code
        FROM magento.sales_flat_order_address
        WHERE address_type = 'billing'
        UNION ALL
        SELECT [order-id], [order-id], NULL, NULL, NULL, NULL, NULL, [order-billing_address-province], NULL, NULL, NULL, [order-billing_address-city], [order-email], NULL, CASE WHEN [order-billing_address-country] = 'Canada' THEN 'CA' ELSE [order-billing_address-country] END, NULL, 'billing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ROW_NUMBER() OVER (PARTITION BY [order-email] ORDER BY [order-order_number] DESC), NULL
        FROM (SELECT DISTINCT c.[order-id], a.[order-order_number], a.[order-billing_address-province], a.[order-billing_address-city], a.[order-billing_address-country], a.[order-email] FROM shopify.order_items AS a
        LEFT JOIN shopify.transactions AS c
                  ON a.[order-order_number] = c.[order-order_number] AND c.[order-transactions-kind] = 'sale' AND c.[order-transactions-status] = 'success') AS x
        UNION ALL
        SELECT [order-id], [order-id], NULL, NULL, NULL, NULL, NULL, [order-billing_address-province], NULL, NULL, NULL, [order-billing_address-city], [order-email], NULL, CASE WHEN [order-billing_address-country] = 'Canada' THEN 'CA' ELSE [order-billing_address-country] END, NULL, 'shipping', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ROW_NUMBER() OVER (PARTITION BY [order-email] ORDER BY [order-order_number] DESC), NULL
        FROM (SELECT DISTINCT c.[order-id], a.[order-order_number], a.[order-billing_address-province], a.[order-billing_address-city], a.[order-billing_address-country], a.[order-email] FROM shopify.order_items AS a
        LEFT JOIN shopify.transactions AS c
                  ON a.[order-order_number] = c.[order-order_number] AND c.[order-transactions-kind] = 'sale' AND c.[order-transactions-status] = 'success') AS x
        ) AS a
      LEFT JOIN lut_Canadian_Cities AS b
      ON b.postal_code = a.postal_code
      ;;
    indexes: ["email", "address_type"]
    sql_trigger_value: SELECT CAST(DATEADD(hh,-5,GETDATE()) AS date)
      ;;
  }

  dimension: row {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.row ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.firstname ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.lastname ;;
  }

  dimension: address_type {
    type: string
    sql: ${TABLE}.address_type ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}.company ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country_id ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postcode ;;
  }

  dimension: prefix {
    type: string
    sql: ${TABLE}.prefix ;;
  }

  dimension: region {
    description: "Province or state"
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: region_code {
    type: number
    sql: ${TABLE}.region_id ;;
  }

  dimension: street {
    type: string
    sql: REPLACE(REPLACE(REPLACE(${TABLE}.street,CHAR(13),' '),CHAR(10),' '),CHAR(9),' ') ;;
  }

  dimension: suffix {
    type: string
    sql: ${TABLE}.suffix ;;
  }

  dimension: telephone {
    alias: [telephone_1st]
    type: string
    value_format: "###-###-####"
    sql: ${TABLE}.telephone ;;
  }

  dimension: map_location {
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }
}
