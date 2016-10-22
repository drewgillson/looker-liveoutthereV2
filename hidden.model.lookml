- connection: mssql

- include: "*.view.lookml"       # include all views in this project
- include: "*.dashboard.lookml"  # include all dashboards in this project

- explore: new_products
  description: "Hidden explore used to power a report that communicates changes in the product catalog to Adviso"
  hidden: true
  from: elasticsearch_products_new_this_week

- explore: orderforms_data_tracker
  description: "Hidden explore that surfaces product data enrichment status filled in to a Google Sheet by Suntec"
  hidden: true
  from: orderforms_data_tracker

- explore: predictions
  description: "Hidden explore that implements 'People who bought this buy these products too'"
  hidden: true
  from: jaccard_product_view_affinity
  
- explore: removed_products
  description: "Hidden explore used to power a report that communicates changes in the product catalog to Adviso"
  hidden: true
  from: elasticsearch_products_removed_this_week
  
- explore: weekly_business_review
  description: "Hidden explore used to power Anshuman's weekly business review Google sheets app"
  from: reports_weekly_business_review
  hidden: true
  joins:
    - join: categories
      from: catalog_categories
      sql_on: weekly_business_review.parent_id = categories.product_id
      relationship: one_to_many