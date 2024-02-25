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

    // Step 8: Invoke another custom function to transform file content
    InvokeCustomFunction = Table.AddColumn(RenamedELSdate, "Transform File (2)", each Table2TransformFunction([Content])),

    // Step 9: Remove other columns
    RemovedOtherColumns = Table.SelectColumns(InvokeCustomFunction,{"ELS Date", "Transform File (2)"}),

    // Step 10: Expand columns in the transformed file
    ExpandedTransform = Table.ExpandTableColumn(RemovedOtherColumns, "Transform File (2)", Table.ColumnNames(Table2TransformFunction(Table2SampleFile))),

    // Step 11: Sort rows by ELS Date in ascending order
    SortedELSdate = Table.Sort(ExpandedTransform,{{"ELS Date", Order.Ascending}})
in
    // Output the sorted table
    SortedELSdate