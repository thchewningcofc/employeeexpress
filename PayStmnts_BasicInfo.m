let
    // Access the folder containing pay statements
    Source = Folder.Files("X:\Pay Statements"),

    // Filter files starting with "els-"
    FilteredELS = Table.SelectRows(Source, each Text.StartsWith([Name], "els-")),

    // Extract date from file name
    ExtractedELSdate = Table.TransformColumns(FilteredELS, {{"Name", each Text.Middle(_, 4, 10), type text}}),

    // Format extracted date
    FormatELSdate = Table.ReplaceValue(ExtractedELSdate, "_", "/", Replacer.ReplaceText, {"Name"}),

    // Convert date column to date type
    ELSdateType = Table.TransformColumnTypes(FormatELSdate, {{"Name", type date}}),

    // Rename date column
    RenamedELSdate = Table.RenameColumns(ELSdateType, {{"Name", "ELSDate"}}),

    // Invoke custom function to transform file content
    InvokeCustomFunction1 = Table.AddColumn(RenamedELSdate, "ELSdata3", each Table3TransformFunction([Content])),

    // Remove unnecessary columns
    RemovedOtherColumns1 = Table.SelectColumns(InvokeCustomFunction1, {"ELSDate", "ELSdata3"}),

    // Expand columns in ELSdata3
    ExpandedELSdata3 = Table.ExpandTableColumn(RemovedOtherColumns1, "ELSdata3", 
        {"ABA/Bank Routing", "Service Comp Date", "Agency", "Number", "Hire Date", "FLSA Class", 
        "Organization Code", "TSP %", "FEGLI Code", "Organization Name", "Employee ID", 
        "Retirement Code", "FEHBA Code"}, 
        {"ABA/Bank Routing", "Service Comp Date", "Agency", "Number", "Hire Date", "FLSA Class", 
        "Organization Code", "TSP %", "FEGLI Code", "Organization Name", "Employee ID", 
        "Retirement Code", "FEHBA Code"})
in
    // Output the expanded ELSdata3
    ExpandedELSdata3
