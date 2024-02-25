let
    // Step 1: Access the folder containing pay statements
    Source = Folder.Files("X:\Pay Statements"),

    // Step 2: Filter files starting with "els-"
    FilteredELS = Table.SelectRows(Source, each Text.StartsWith([Name], "els-")),

    // Step 3: Extract date from file name
    ExtractedELSdate = Table.TransformColumns(FilteredELS, {{"Name", each Text.Middle(_, 4, 10), type text}}),

    // Step 4: Format extracted date
    FormatELSdate = Table.ReplaceValue(ExtractedELSdate,"_","/",Replacer.ReplaceText,{"Name"}),

    // Step 5: Convert date column to date type
    ELSdateType = Table.TransformColumnTypes(FormatELSdate,{{"Name", type date}}),

    // Step 6: Invoke custom function to transform file content
    InvokeELSFunction = Table.AddColumn(ELSdateType, "Transform File", each Table1TransformFile([Content])),

    // Step 7: Rename date column
    RenamedELSdate = Table.RenameColumns(InvokeELSFunction,{{"Name", "ELS Date"}}),

    // Step 8: Remove other columns
    RemovedOtherColumns = Table.SelectColumns(RenamedELSdate,{"ELS Date", "Transform File"}),

    // Step 9: Expand columns in Transform File
    ExpandedTransformFile = Table.ExpandTableColumn(RemovedOtherColumns, "Transform File", {"Pay Period #", "Annual Salary", "Pay Date", "Hourly Rate"}, {"Pay Period #", "Annual Salary", "Pay Date", "Hourly Rate"}),

    // Step 10: Sort rows by ELS Date in ascending order
    SortedELSdate = Table.Sort(ExpandedTransformFile,{{"ELS Date", Order.Ascending}}),

    // Step 11: Change data types of certain columns
    ChangedType = Table.TransformColumnTypes(SortedELSdate,{{"Annual Salary", Currency.Type}, {"Hourly Rate", Currency.Type}, {"Pay Date", type date}})
in
    // Output the table with changed data types
    ChangedType