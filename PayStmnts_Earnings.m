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
    RenamedELSdate = Table.RenameColumns(ELSdateType,{{"Name", "ELSDate"}}),

    // Step 7: Invoke custom function to transform file content
    InvokeCustomFunction1 = Table.AddColumn(RenamedELSdate, "TransformFile", each Table5EARNINGSTransformFile([Content])),

    // Step 8: Remove unnecessary columns
    RemovedOtherColumns = Table.SelectColumns(InvokeCustomFunction1,{"TransformFile", "ELSDate"}),

    // Step 9: Reorder columns
    ReorderedColumns = Table.ReorderColumns(RemovedOtherColumns,{"ELSDate", "TransformFile"}),

    // Step 10: Expand columns in TransformFile
    ExpandedTransformFile1 = Table.ExpandTableColumn(ReorderedColumns, "TransformFile", {"Type", "Rate Adjusted", "ADJ Hours", "Hours", "Current YTD"}, {"Type", "Rate Adjusted", "ADJ Hours", "Hours", "Current YTD"}),

    // Step 11: Replace values in Current YTD column
    ReplacedValue = Table.ReplaceValue(ExpandedTransformFile1," 4,152.801"," 4,152.80 1",Replacer.ReplaceText,{"Current YTD"}),

    // Step 12: Split Current YTD column by delimiter
    SplitColumnbyDelimiter = Table.SplitColumn(ReplacedValue, "Current YTD", Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, true), {"Current YTD.1", "Current YTD.2"}),

    // Step 13: Change data types
    ChangedType = Table.TransformColumnTypes(SplitColumnbyDelimiter,{{"Current YTD.1", type text}, {"Current YTD.2", type text}}),

    // Step 14: Rename columns
    RenamedColumns = Table.RenameColumns(ChangedType,{{"Current YTD.2", "EARNINGSYTD"}, {"Current YTD.1", "EARNINGSCurrent"}}),

    // Step 15: Change data types
    ChangedType1 = Table.TransformColumnTypes(RenamedColumns,{{"EARNINGSYTD", Currency.Type}, {"EARNINGSCurrent", Currency.Type}}),

    // Step 16: Sort rows by Type
    SortedRows = Table.Sort(ChangedType1,{{"Type", Order.Descending}}),

    // Step 17: Unpivot other columns
    UnpivotedColumns = Table.UnpivotOtherColumns(SortedRows, {"ELSDate", "Type"}, "Attribute", "Value"),

    // Step 18: Merge columns
    MergedColumns = Table.CombineColumns(UnpivotedColumns,{"Type", "Attribute"},Combiner.CombineTextByDelimiter(" ", QuoteStyle.None),"Merged"),

    // Step 19: Pivot merged column
    PivotedColumn = Table.Pivot(MergedColumns, List.Distinct(MergedColumns[Merged]), "Merged", "Value")
in
    PivotedColumn