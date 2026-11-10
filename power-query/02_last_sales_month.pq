// LastSalesMonth
// Purpose: find the latest month that has actual sales.
// Everything after this date is treated as forecast (estimate).

let
    Source = List.Max(fact_sales_monthly[date])
in
    Source
