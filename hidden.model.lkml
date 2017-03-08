connection: "mssql"

# include all views in this project
include: "*.view"

# include all dashboards in this project
include: "*.dashboard"

fiscal_month_offset: 1

explore: new_products {
  description: "Hidden explore used to power a report that communicates changes in the product catalog to Adviso"
  hidden: yes
  from: elasticsearch_products_new_this_week
}

explore: orderforms_data_tracker {
  description: "Hidden explore that surfaces product data enrichment status filled in to a Google Sheet by Suntec"
  hidden: yes
  from: orderforms_data_tracker
}

explore: predictions {
  description: "Hidden explore that implements 'People who bought this buy these products too'"
  hidden: yes
  from: jaccard_product_view_affinity
}

explore: removed_products {
  description: "Hidden explore used to power a report that communicates changes in the product catalog to Adviso"
  hidden: yes
  from: elasticsearch_products_removed_this_week
}

explore: weekly_business_review {
  description: "Hidden explore used to power Anshuman's weekly business review Google sheets app"
  from: reports_weekly_business_review
  hidden: yes

  join: categories {
    from: catalog_categories
    sql_on: weekly_business_review.parent_id = categories.product_id ;;
    relationship: one_to_many
  }
}

explore: return_requests {
  from: report_return_requests_for_suntec
  hidden:  yes
}
