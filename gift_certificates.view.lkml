view: gift_certificates {
  derived_table: {
    sql: SELECT a.*, b.ts AS created FROM magento.ugiftcert_cert AS a
      LEFT JOIN (SELECT [cert_id], ts FROM (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY [cert_id] ORDER BY ts) AS seq
        FROM magento.ugiftcert_history
      ) AS a
      WHERE seq = 1) AS b
      ON a.cert_id = b.cert_id
       ;;
  }

  dimension: cert_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.cert_id ;;
  }

  measure: balance {
    type: sum
    value_format: "$#,##0"
    sql: ${TABLE}.balance ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}.created ;;
  }

  dimension: certificate_number {
    type: string
    sql: ${TABLE}.cert_number ;;
  }

  dimension: recipient_email {
    hidden: yes
    type: string
    sql: ${TABLE}.recipient_email ;;
  }

  dimension: sender_name {
    type: string
    sql: ${TABLE}.sender_name ;;
  }

  dimension: status {
    label: "Is Active"
    type: yesno
    sql: ${TABLE}.status = 'A' ;;
  }
}
