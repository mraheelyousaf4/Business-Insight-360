// gross_price
// Purpose: load the gross price of each product for each fiscal year
// from the MySQL finance database.

let
    Source = MySQL.Database("localhost", "gdb056", [ReturnSingleDatabase = true]),
    gdb056_gross_price = Source{[Schema = "gdb056", Item = "gross_price"]}[Data]
in
    gdb056_gross_price


// pre_invoice_deductions
// Purpose: load the pre-invoice discount % agreed with each customer
// for each fiscal year from the MySQL finance database.

let
    Source = MySQL.Database("localhost", "gdb056", [ReturnSingleDatabase = true]),
    gdb056_pre_invoice_deductions = Source{[Schema = "gdb056", Item = "pre_invoice_deductions"]}[Data]
in
    gdb056_pre_invoice_deductions
