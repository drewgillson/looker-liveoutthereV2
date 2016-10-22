- view: snowplow_utm_sequences_for_orders
  sql_table_name: snowplow.utm_sequences_for_orders

  fields:

  - dimension: event_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.event_id

  - dimension: increment_id
    hidden: true
    sql: ${TABLE}.increment_id

  - dimension: utm_sequence_reverse_from_order
    label: "Nth UTM Sequence Before Order"
    description: "This can be used to get last-touch attribution for an order, or even to create looser attribution filters like 'came from CPC within last 3 UTMs before order'."
    type: number
    sql: ${TABLE}.utm_sequence