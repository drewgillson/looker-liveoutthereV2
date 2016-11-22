view: sales_order_address {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER (ORDER BY entity_id) AS row, a.*, b.latitude, b.longitude FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY entity_id DESC) AS sequence, UPPER(REPLACE(REPLACE(postcode,' ',''),'-','')) AS postal_code
        FROM magento.sales_flat_order_address
        WHERE address_type = 'shipping'
        UNION ALL
        SELECT *, ROW_NUMBER() OVER (PARTITION BY email ORDER BY entity_id DESC) AS sequence, UPPER(REPLACE(REPLACE(postcode,' ',''),'-','')) AS postal_code
        FROM magento.sales_flat_order_address
        WHERE address_type = 'billing'
      ) AS a
      LEFT JOIN lut_Canadian_Cities AS b
      ON b.postal_code = a.postal_code
      WHERE sequence = 1
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
