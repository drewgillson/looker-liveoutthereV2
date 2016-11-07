view: snowplow {
  sql_table_name: snowplow.events ;;

  dimension: id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  filter: specific_channel {}

  dimension: specific_channel_with_all_other_channels {
    sql: CASE
        WHEN {% condition specific_channel %} ${channel} {% endcondition %}
        THEN ${channel}
        ELSE 'All Other Channels'
      END
       ;;
  }

  dimension: channel {
    case: {
      when: {
        sql: ${utm_medium} = 'affiliate' OR ${utm_source} = 'affiliate' ;;
        label: "Affiliate"
      }

      when: {
        sql: ${utm_source} = 'adroll' ;;
        label: "AdRoll"
      }

      when: {
        sql: ${utm_medium} = 'buynow' ;;
        label: "Brand Sites"
      }

      when: {
        sql: ${utm_medium} = 'cpc' AND (${utm_source} = 'bing' OR ${utm_source} = 'bing-yahoo') ;;
        label: "Bing/Yahoo SEM"
      }

      when: {
        sql: (${utm_medium} = 'cpc' OR ${utm_medium} = 'retargeting-banner') AND ${utm_source} = 'criteo' ;;
        label: "Criteo"
      }

      when: {
        sql: ${utm_medium} = 'cpc' AND ${utm_source} = 'facebook' ;;
        label: "Facebook CPC"
      }

      when: {
        sql: ${utm_medium} = 'cpc' AND ${utm_source} = 'google' ;;
        label: "Google SEM"
      }

      when: {
        sql: ${utm_medium} = 'cpc' AND (${utm_source} = 'google-shopping' OR ${utm_source} = 'googleshopping' OR ${utm_source} = 'googlepla') ;;
        label: "Google PLA"
      }

      when: {
        sql: ${utm_medium} = 'cpc' AND ${utm_source} = 'shopbot' ;;
        label: "Shopbot"
      }

      when: {
        sql: ${utm_medium} = 'cpc' AND ${utm_source} = 'twitter' ;;
        label: "Twitter CPC"
      }

      when: {
        sql: ${referrer_medium} = 'search' ;;
        label: "Organic Search"
      }

      when: {
        sql: ${referrer_medium} = 'social' AND ${utm_medium} != 'cpc' ;;
        label: "Social"
      }

      when: {
        sql: ${utm_medium} = 'social' ;;
        label: "LOT Social"
      }

      when: {
        sql: ${utm_medium} = 'email' ;;
        label: "Email"
      }

      when: {
        sql: ${utm_source} = 'talkable' ;;
        label: "Talkable"
      }

      when: {
        sql: ${utm_medium} = '' AND ${referrer_medium} != 'search' AND ${referrer_medium} != 'social' AND ${referrer_medium} != 'internal' ;;
        label: "Referral"
      }

      when: {
        sql: ${utm_medium} = '' AND ${utm_source} = '' AND ${referrer_medium} = '' AND ${referrer_source} = '' ;;
        label: "Direct"
      }

      when: {
        sql: ${utm_medium} = '' AND ${referrer_medium} = 'internal' ;;
        label: "Internal"
      }

      when: {
        sql: 1 = 1 ;;
        label: "Unknown"
      }
    }
  }

  dimension: app_id {
    sql: ${TABLE}.app_id ;;
  }

  dimension: session_number {
    type: number
    sql: ${TABLE}.domain_sessionidx ;;
  }

  dimension: is_mobile_device {
    label: "Is Mobile / Tablet Device"
    type: yesno
    sql: ${TABLE}.dvce_type = 'Mobile' OR ${TABLE}.dvce_type = 'Tablet' ;;
  }

  dimension: device_type {
    sql: ${TABLE}.dvce_type ;;
  }

  dimension: event_type {
    sql: ${TABLE}.event ;;
  }

  dimension: event_id {
    sql: ${TABLE}.event_id ;;
  }

  dimension: city {
    sql: ${TABLE}.geo_city ;;
  }

  dimension: country {
    sql: ${TABLE}.geo_country ;;
  }

  dimension: visitor_location {
    type: location
    sql_latitude: ${visitor_latitude} ;;
    sql_longitude: ${visitor_longitude} ;;
  }

  dimension: visitor_latitude {
    hidden: yes
    type: number
    sql: CASE WHEN ${TABLE}.geo_location != '' THEN CAST(LEFT(${TABLE}.geo_location,CHARINDEX(',',${TABLE}.geo_location)-1) AS decimal(10,6)) END
      ;;
  }

  dimension: visitor_longitude {
    hidden: yes
    type: number
    sql: CASE WHEN ${TABLE}.geo_location != '' THEN CAST(SUBSTRING(${TABLE}.geo_location,CHARINDEX(',',${TABLE}.geo_location)+1,100) AS decimal(10,6)) END
      ;;
  }

  dimension: region_name {
    sql: ${TABLE}.geo_region_name ;;
  }

  dimension: postal_code {
    sql: ${TABLE}.geo_zipcode ;;
  }

  dimension_group: visit {
    type: time
    sql: ${TABLE}.mdt_timestamp ;;
  }

  measure: engaged_minutes {
    type: count_distinct
    sql: CAST(FLOOR(DATEDIFF(s,'19700101',${visit_time})/(60*2))*2 AS varchar(255)) + ${TABLE}.domain_userid ;;
  }

  measure: page_views {
    type: count_distinct
    sql: CONVERT(VARCHAR, ${visit_time}, 120) + ${TABLE}.domain_userid ;;
  }

  measure: cumulative_page_views {
    type: running_total
    sql: ${page_views} ;;
  }

  measure: cumulative_engaged_minutes {
    type: running_total
    sql: ${engaged_minutes} ;;
  }

  measure: count_distinct_domain_userid {
    label: "Count of Distinct Visitors"
    type: count_distinct
    sql: ${TABLE}.domain_userid ;;
  }

  dimension: utm_campaign {
    sql: ${TABLE}.mkt_campaign ;;
  }

  dimension: utm_content {
    sql: ${TABLE}.mkt_content ;;
  }

  dimension: utm_medium {
    sql: ${TABLE}.mkt_medium ;;
  }

  dimension: utm_source {
    sql: ${TABLE}.mkt_source ;;
  }

  dimension: utm_term {
    sql: ${TABLE}.mkt_term ;;
  }

  dimension: page_referrer {
    sql: ${TABLE}.page_referrer ;;
  }

  dimension: page_title {
    sql: ${TABLE}.page_title ;;
  }

  dimension: page_url {
    sql: ${TABLE}.page_url ;;
  }

  dimension: page_url_query_string {
    sql: ${TABLE}.page_urlquery ;;
  }

  dimension: referrer_medium {
    sql: ${TABLE}.refr_medium ;;
  }

  dimension: referrer_source {
    sql: ${TABLE}.refr_source ;;
  }

  dimension: referrer_term {
    sql: ${TABLE}.refr_term ;;
  }

  dimension: referrer_host {
    sql: ${TABLE}.refr_urlhost ;;
  }

  dimension: referrer_url {
    sql: ${TABLE}.refr_urlpath ;;
  }

  dimension: referrer_url_query_string {
    sql: ${TABLE}.refr_urlquery ;;
  }

  dimension: snowplow_user_id {
    sql: ${TABLE}.domain_userid ;;
  }

  dimension: live_out_there_user_id {
    sql: ${TABLE}.user_id ;;
  }

  dimension: event_category {
    sql: ${TABLE}.se_category ;;
  }

  dimension: event_action {
    sql: ${TABLE}.se_action ;;
  }

  dimension: event_label {
    sql: ${TABLE}.se_label ;;
  }

  dimension: event_property {
    sql: ${TABLE}.se_property ;;
  }

  dimension: event_value {
    sql: ${TABLE}.se_value ;;
  }

  measure: count {
    label: "Count of Events"
    type: count
  }

  measure: cumulative_count_of_events {
    type: running_total
    sql: ${count} ;;
  }
}
