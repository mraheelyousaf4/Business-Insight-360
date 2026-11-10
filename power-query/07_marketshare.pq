// marketshare
// Purpose: load yearly market sales by sub-zone and category, and reshape it
// so each manufacturer (AtliQ and competitors) is a row, not a column.
// This lets one measure calculate market share for any manufacturer.
//
// SourceFolder is a text parameter pointing to the folder that holds
// marketshare-v2025.xlsx. Set it in Power Query before refreshing.

let
    Source = Excel.Workbook(File.Contents(SourceFolder & "marketshare-v2025.xlsx"), null, true),
    marketshare_Table = Source{[Item = "marketshare", Kind = "Table"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(marketshare_Table, {{"sub_zone", type text}, {"category", type text}, {"fy_desc", Int64.Type}, {"total_market_sales_$", type number}, {"atliq_sales_$", type number}, {"dale_sales_$", type number}, {"innovo_sales_$", type number}, {"pacer_sales_$", type number}, {"bp_sales_$", type number}, {"others_sales_$", type number}}),

    // One column per manufacturer becomes one row per manufacturer
    #"Unpivoted Columns" = Table.UnpivotOtherColumns(#"Changed Type", {"sub_zone", "category", "fy_desc", "total_market_sales_$"}, "Attribute", "Value"),
    #"Renamed Columns" = Table.RenameColumns(#"Unpivoted Columns", {{"Attribute", "manufacturer"}, {"Value", "sales_$"}}),

    // "atliq_sales_$" becomes "atliq"
    #"Extracted Text Before Delimiter" = Table.TransformColumns(#"Renamed Columns", {{"manufacturer", each Text.BeforeDelimiter(_, "_"), type text}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Extracted Text Before Delimiter", {{"fy_desc", "fy"}}),

    // The North America sub-zone "NA" is read as blank, so restore it
    #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns1", null, "NA", Replacer.ReplaceValue, {"sub_zone"})
in
    #"Replaced Value"
