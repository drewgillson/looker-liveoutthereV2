- view: snowplow
  fields:

  - dimension: id
    primary_key: true
    type: number
    sql: ${TABLE}.id

  - dimension: app_id
    type: string
    sql: ${TABLE}.app_id

  - dimension: br_colordepth
    type: string
    sql: ${TABLE}.br_colordepth

  - dimension: br_cookies
    type: string
    sql: ${TABLE}.br_cookies

  - dimension: br_family
    type: string
    sql: ${TABLE}.br_family

  - dimension: br_features_director
    type: string
    sql: ${TABLE}.br_features_director

  - dimension: br_features_flash
    type: string
    sql: ${TABLE}.br_features_flash

  - dimension: br_features_gears
    type: string
    sql: ${TABLE}.br_features_gears

  - dimension: br_features_java
    type: string
    sql: ${TABLE}.br_features_java

  - dimension: br_features_pdf
    type: string
    sql: ${TABLE}.br_features_pdf

  - dimension: br_features_quicktime
    type: string
    sql: ${TABLE}.br_features_quicktime

  - dimension: br_features_realplayer
    type: string
    sql: ${TABLE}.br_features_realplayer

  - dimension: br_features_silverlight
    type: string
    sql: ${TABLE}.br_features_silverlight

  - dimension: br_features_windowsmedia
    type: string
    sql: ${TABLE}.br_features_windowsmedia

  - dimension: br_lang
    type: string
    sql: ${TABLE}.br_lang

  - dimension: br_name
    type: string
    sql: ${TABLE}.br_name

  - dimension: br_renderengine
    type: string
    sql: ${TABLE}.br_renderengine

  - dimension: br_type
    type: string
    sql: ${TABLE}.br_type

  - dimension: br_version
    type: string
    sql: ${TABLE}.br_version

  - dimension: br_viewheight
    type: string
    sql: ${TABLE}.br_viewheight

  - dimension: br_viewwidth
    type: string
    sql: ${TABLE}.br_viewwidth

  - dimension: build_num
    type: string
    sql: ${TABLE}.buildNum

  - dimension: collector_tstamp
    type: string
    sql: ${TABLE}."collector_tstamp?"

  - dimension: columns
    type: string
    sql: ${TABLE}.columns

  - dimension: custom_formats
    type: string
    sql: ${TABLE}.customFormats

  - dimension: default_index
    type: string
    sql: ${TABLE}.defaultIndex

  - dimension: description
    type: string
    sql: ${TABLE}.description

  - dimension: doc_charset
    type: string
    sql: ${TABLE}.doc_charset

  - dimension: doc_height
    type: string
    sql: ${TABLE}.doc_height

  - dimension: doc_width
    type: string
    sql: ${TABLE}.doc_width

  - dimension: domain_sessionidx
    type: string
    sql: ${TABLE}.domain_sessionidx

  - dimension: domain_userid
    type: string
    sql: ${TABLE}.domain_userid

  - dimension: dvce_ismobile
    type: string
    sql: ${TABLE}.dvce_ismobile

  - dimension: dvce_screenheight
    type: string
    sql: ${TABLE}.dvce_screenheight

  - dimension: dvce_screenwidth
    type: string
    sql: ${TABLE}.dvce_screenwidth

  - dimension: dvce_tstamp
    type: string
    sql: ${TABLE}."dvce_tstamp?"

  - dimension: dvce_type
    type: string
    sql: ${TABLE}.dvce_type

  - dimension: element_classes
    type: string
    sql: ${TABLE}.elementClasses

  - dimension: element_id
    type: string
    sql: ${TABLE}.elementId

  - dimension: element_target
    type: string
    sql: ${TABLE}.elementTarget

  - dimension: etl_tstamp
    type: string
    sql: ${TABLE}.etl_tstamp

  - dimension: event
    type: string
    sql: ${TABLE}.event

  - dimension: event_id
    type: string
    sql: ${TABLE}.event_id

  - dimension: fields
    type: string
    sql: ${TABLE}.fields

  - dimension: geo_city
    type: string
    sql: ${TABLE}.geo_city

  - dimension: geo_country
    type: string
    sql: ${TABLE}.geo_country

  - dimension: geo_latitude
    type: string
    sql: ${TABLE}.geo_latitude

  - dimension: geo_location
    type: string
    sql: ${TABLE}.geo_location

  - dimension: geo_longitude
    type: string
    sql: ${TABLE}.geo_longitude

  - dimension: geo_region
    type: string
    sql: ${TABLE}.geo_region

  - dimension: geo_region_name
    type: string
    sql: ${TABLE}.geo_region_name

  - dimension: geo_zipcode
    type: string
    sql: ${TABLE}.geo_zipcode

  - dimension: hits
    type: string
    sql: ${TABLE}.hits

  - dimension: interval_name
    type: string
    sql: ${TABLE}.intervalName

  - dimension_group: mdt_timestamp
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.mdt_timestamp

  - dimension: mkt_campaign
    type: string
    sql: ${TABLE}.mkt_campaign

  - dimension: mkt_content
    type: string
    sql: ${TABLE}.mkt_content

  - dimension: mkt_medium
    type: string
    sql: ${TABLE}.mkt_medium

  - dimension: mkt_source
    type: string
    sql: ${TABLE}.mkt_source

  - dimension: mkt_term
    type: string
    sql: ${TABLE}.mkt_term

  - dimension: name_tracker
    type: string
    sql: ${TABLE}.name_tracker

  - dimension: network_userid
    type: string
    sql: ${TABLE}.network_userid

  - dimension: os_family
    type: string
    sql: ${TABLE}.os_family

  - dimension: os_manufacturer
    type: string
    sql: ${TABLE}.os_manufacturer

  - dimension: os_name
    type: string
    sql: ${TABLE}.os_name

  - dimension: os_timezone
    type: string
    sql: ${TABLE}.os_timezone

  - dimension: page_referrer
    type: string
    sql: ${TABLE}.page_referrer

  - dimension: page_title
    type: string
    sql: ${TABLE}.page_title

  - dimension: page_url
    type: string
    sql: ${TABLE}.page_url

  - dimension: page_urlfragment
    type: string
    sql: ${TABLE}.page_urlfragment

  - dimension: page_urlhost
    type: string
    sql: ${TABLE}.page_urlhost

  - dimension: page_urlpath
    type: string
    sql: ${TABLE}.page_urlpath

  - dimension: page_urlport
    type: string
    sql: ${TABLE}.page_urlport

  - dimension: page_urlquery
    type: string
    sql: ${TABLE}.page_urlquery

  - dimension: page_urlscheme
    type: string
    sql: ${TABLE}.page_urlscheme

  - dimension: platform
    type: string
    sql: ${TABLE}.platform

  - dimension: pp_xoffset_max
    type: string
    sql: ${TABLE}.pp_xoffset_max

  - dimension: pp_xoffset_min
    type: string
    sql: ${TABLE}.pp_xoffset_min

  - dimension: pp_yoffset_max
    type: string
    sql: ${TABLE}.pp_yoffset_max

  - dimension: pp_yoffset_min
    type: string
    sql: ${TABLE}.pp_yoffset_min

  - dimension: refr_medium
    type: string
    sql: ${TABLE}.refr_medium

  - dimension: refr_source
    type: string
    sql: ${TABLE}.refr_source

  - dimension: refr_term
    type: string
    sql: ${TABLE}.refr_term

  - dimension: refr_urlhost
    type: string
    sql: ${TABLE}.refr_urlhost

  - dimension: refr_urlpath
    type: string
    sql: ${TABLE}.refr_urlpath

  - dimension: refr_urlport
    type: string
    sql: ${TABLE}.refr_urlport

  - dimension: refr_urlquery
    type: string
    sql: ${TABLE}.refr_urlquery

  - dimension: refr_urlscheme
    type: string
    sql: ${TABLE}.refr_urlscheme

  - dimension: saved_search_id
    type: string
    sql: ${TABLE}.savedSearchId

  - dimension: se_action
    type: string
    sql: ${TABLE}.se_action

  - dimension: se_category
    type: string
    sql: ${TABLE}.se_category

  - dimension: se_label
    type: string
    sql: ${TABLE}.se_label

  - dimension: se_property
    type: string
    sql: ${TABLE}.se_property

  - dimension: se_value
    type: string
    sql: ${TABLE}.se_value

  - dimension: search_source_json
    type: string
    sql: ${TABLE}.searchSourceJSON

  - dimension: sort
    type: string
    sql: ${TABLE}.sort

  - dimension: target_url
    type: string
    sql: ${TABLE}.targetUrl

  - dimension: time_field_name
    type: string
    sql: ${TABLE}.timeFieldName

  - dimension: title
    type: string
    sql: ${TABLE}.title

  - dimension: tz_offset
    type: number
    sql: ${TABLE}.tz_offset

  - dimension: user_fingerprint
    type: string
    sql: ${TABLE}.user_fingerprint

  - dimension: user_id
    type: string
    sql: ${TABLE}.user_id

  - dimension: user_ipaddress
    type: string
    sql: ${TABLE}.user_ipaddress

  - dimension: useragent
    type: string
    sql: ${TABLE}.useragent

  - dimension: v_collector
    type: string
    sql: ${TABLE}.v_collector

  - dimension: v_etl
    type: string
    sql: ${TABLE}.v_etl

  - dimension: v_tracker
    type: string
    sql: ${TABLE}.v_tracker

  - dimension: version
    type: string
    sql: ${TABLE}.version

  - dimension: vis_state
    type: string
    sql: ${TABLE}.visState

  - measure: count
    type: count
    drill_fields: detail*


  # ----- Sets of fields for drilling ------
  sets:
    detail:
    - id
    - br_name
    - geo_region_name
    - interval_name
    - os_name
    - time_field_name

