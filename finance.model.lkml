label: "3. Finance"

connection: "mssql"

# include all views in this project
include: "*.view"

# include all dashboards in this project
include: "*.dashboard"

explore: nri {
  description: "Use to figure out exactly what we're paying NRI on a line-item level"
  label: "NRI Invoices"
  from: nri_invoice_details
}
