// fact_actuals_estimates
// Purpose: build the main fact table used by every dashboard.
// 1. Stack actual sales and the remaining forecast into one table.
// 2. Add the fiscal year. AtliQ's fiscal year starts in September,
//    so adding 4 months to the date gives the fiscal year.
// 3. Bring in the gross price and calculate gross sales.
// 4. Bring in the customer's pre-invoice discount and calculate
//    net invoice sales.
// Post-invoice deductions, costs and operating expenses are added later
// as DAX calculated columns (see dax/calculated_columns.dax).

let
    Source = Table.Combine({fact_sales_monthly, #"Remaining Forecast"}),
    #"Added Fiscal Year" = Table.AddColumn(Source, "fiscal_year", each Date.Year(Date.AddMonths([date], 4))),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Fiscal Year", {{"fiscal_year", type text}}),

    // Gross sales = Qty x gross price for that product and fiscal year
    #"Merged With Gross Price" = Table.NestedJoin(#"Changed Type", {"product_code", "fiscal_year"}, gross_price, {"product_code", "fiscal_year"}, "gdb056 gross_price", JoinKind.LeftOuter),
    #"Expanded gdb056 gross_price" = Table.ExpandTableColumn(#"Merged With Gross Price", "gdb056 gross_price", {"gross_price"}, {"gross_price"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Expanded gdb056 gross_price", {{"gross_price", Currency.Type}}),
    #"Added GS" = Table.AddColumn(#"Changed Type1", "gross_sales_amount", each [gross_price] * [Qty]),
    #"Changed Type2" = Table.TransformColumnTypes(#"Added GS", {{"gross_sales_amount", Currency.Type}}),

    // Net invoice sales = gross sales minus the customer's pre-invoice discount
    #"Merged Queries1" = Table.NestedJoin(#"Changed Type2", {"customer_code", "fiscal_year"}, pre_invoice_deductions, {"customer_code", "fiscal_year"}, "gdb056 pre_invoice_deductions", JoinKind.LeftOuter),
    #"Expanded gdb056 pre_invoice_deductions" = Table.ExpandTableColumn(#"Merged Queries1", "gdb056 pre_invoice_deductions", {"pre_invoice_discount_pct"}, {"pre_invoice_discount_pct"}),
    #"Changed Type3" = Table.TransformColumnTypes(#"Expanded gdb056 pre_invoice_deductions", {{"pre_invoice_discount_pct", Percentage.Type}}),
    #"Added Custom2" = Table.AddColumn(#"Changed Type3", "pre_invoice_discount_amount", each [gross_sales_amount] * [pre_invoice_discount_pct]),
    #"Changed Type4" = Table.TransformColumnTypes(#"Added Custom2", {{"pre_invoice_discount_amount", Currency.Type}}),
    #"Added Custom3" = Table.AddColumn(#"Changed Type4", "net_invoice_sales_amount", each [gross_sales_amount] - [pre_invoice_discount_amount]),
    #"Changed Type5" = Table.TransformColumnTypes(#"Added Custom3", {{"net_invoice_sales_amount", Currency.Type}}),

    // Drop helper columns to keep the model small
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type5", {"gross_price", "pre_invoice_discount_pct", "pre_invoice_discount_amount"})
in
    #"Removed Columns"
