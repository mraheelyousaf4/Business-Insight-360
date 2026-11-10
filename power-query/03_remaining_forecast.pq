// Remaining Forecast
// Purpose: take forecast rows for months after the last actual sales month.
// These rows fill the rest of the year so the current fiscal year shows
// actuals plus estimates. forecast_quantity is renamed to Qty to match actuals.

let
    Source = fact_forecast_monthly,
    #"Filtered Rows" = Table.SelectRows(Source, each ([date] > LastSalesMonth)),
    #"Sorted Rows" = Table.Sort(#"Filtered Rows", {{"date", Order.Ascending}}),
    #"Renamed Columns" = Table.RenameColumns(#"Sorted Rows", {{"forecast_quantity", "Qty"}})
in
    #"Renamed Columns"
