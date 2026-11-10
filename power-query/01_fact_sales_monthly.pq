// fact_sales_monthly
// Purpose: load actual monthly sales quantities from the MySQL sales database.
// Keeps only the columns the model needs and renames sold_quantity to Qty
// so actuals and forecast can be stacked later with the same column name.

let
    Source = MySQL.Database("localhost", "gdb041", [ReturnSingleDatabase = true]),
    gdb041_fact_sales_monthly = Source{[Schema = "gdb041", Item = "fact_sales_monthly"]}[Data],
    #"Renamed Columns" = Table.RenameColumns(gdb041_fact_sales_monthly, {{"sold_quantity", "Qty"}}),
    #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns", {"date", "product_code", "customer_code", "Qty"})
in
    #"Removed Other Columns"
