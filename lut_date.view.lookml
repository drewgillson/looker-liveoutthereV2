- view: lut_date
  sql_table_name: lut_Date
  fields:

  - dimension: bi_week_number
    type: number
    sql: ${TABLE}.BiWeekNumber

  - dimension: bi_weekly_key
    type: string
    sql: ${TABLE}.BiWeeklyKey

  - dimension: character_date
    type: string
    sql: ${TABLE}.CharacterDate

  - dimension: date_definition
    type: string
    sql: ${TABLE}.DateDefinition

  - dimension_group: date_full
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.DateFull

  - dimension: date_key
    type: number
    sql: ${TABLE}.DateKey

  - dimension: full_year
    type: string
    sql: ${TABLE}.FullYear

  - dimension: month_day
    type: number
    sql: ${TABLE}.MonthDay

  - dimension: month_name
    type: string
    sql: ${TABLE}.MonthName

  - dimension: month_number
    type: number
    sql: ${TABLE}.MonthNumber

  - dimension: quarter_number
    type: number
    sql: ${TABLE}.QuarterNumber

  - dimension: utcoffset
    type: number
    sql: ${TABLE}.UTCOffset

  - dimension: week_day
    type: number
    sql: ${TABLE}.WeekDay

  - dimension: week_day_name
    type: string
    sql: ${TABLE}.WeekDayName

  - dimension: week_number
    type: number
    sql: ${TABLE}.WeekNumber

  - dimension: weekly_key
    type: string
    sql: ${TABLE}.WeeklyKey

  - dimension: year_day
    type: number
    sql: ${TABLE}.YearDay

  - measure: count
    type: count
    drill_fields: [week_day_name, month_name]

