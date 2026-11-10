// dim_date
// Purpose: build a date table covering every month in the data,
// from September 2017 to August 2025.
// Adds the start of month and the fiscal year (September to August).
// Fiscal month number, quarter and YTD/YTG flags are added in DAX
// (see dax/calculated_columns.dax).

let
    Query1 = {Number.From(#date(2017, 9, 1))..Number.From(#date(2025, 8, 1))},
    #"Converted to Table" = Table.FromList(Query1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Changed Type" = Table.TransformColumnTypes(#"Converted to Table", {{"Column1", type date}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type", {{"Column1", "date"}}),
    #"Inserted Start of Month" = Table.AddColumn(#"Renamed Columns", "Start of Month", each Date.StartOfMonth([date]), type date),
    #"Renamed Columns1" = Table.RenameColumns(#"Inserted Start of Month", {{"Start of Month", "month"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns1", "fiscal_year", each Date.Year(Date.AddMonths([month], 4))),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom", {{"fiscal_year", type text}})
in
    #"Changed Type1"
