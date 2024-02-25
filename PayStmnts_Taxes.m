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

    // Step 7: Invoke custom function to transform file content
    InvokeCustomFunction = Table.AddColumn(RenamedELSdate, "Transform File", each Table4_TaxInfoTransformFile([Content])),

    // Step 8: Remove other columns
    RemovedOtherColumns = Table.SelectColumns(InvokeCustomFunction,{"ELS Date", "Transform File"}),

    // Step 9: Expand columns in Transform File
    ExpandedTransformFile = Table.ExpandTableColumn(RemovedOtherColumns, "Transform File", {"Mrtl Status Federal", "Mrtl Status State ( SC )", "ExmptsMulti Jobs Federal", "ExmptsMulti Jobs State ( SC )", "Addtl Wthhld Federal", "Addtl Wthhld State ( SC )"}, {"Mrtl Status Federal", "Mrtl Status State ( SC )", "ExmptsMulti Jobs Federal", "ExmptsMulti Jobs State ( SC )", "Addtl Wthhld Federal", "Addtl Wthhld State ( SC )"})
in
    // Output the expanded Transform File
    ExpandedTransformFile