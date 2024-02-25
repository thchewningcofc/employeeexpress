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

    // Step 6: Rename date column
    RenamedELSdate = Table.RenameColumns(ELSdateType,{{"Name", "ELS Date"}}),

    // Step 7: Filter out hidden files
    FilteredHiddenFiles = Table.SelectRows(RenamedELSdate, each [Attributes]?[Hidden]? <> true),

    // Step 8: Invoke custom function to transform file content
    InvokeCustomFunction = Table.AddColumn(FilteredHiddenFiles, "Transform File", each PayStmnts4_PayTransformFile([Content])),

    // Step 9: Remove other columns
    RemovedOtherColumns = Table.SelectColumns(InvokeCustomFunction,{"ELS Date", "Transform File"}),

    // Step 10: Expand columns in Transform File
    ExpandedTableColumn = Table.ExpandTableColumn(RemovedOtherColumns, "Transform File", Table.ColumnNames(PayStmnts4_PayTransformFile(PayStmnts4_PaySampleFile)))
in
    // Output the expanded table column
    ExpandedTableColumn