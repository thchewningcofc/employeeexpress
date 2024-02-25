let
    // Step 1: Access the folder containing pay statements
    Source = Folder.Files("X:\Pay Statements"),

    // Step 2: Filter files starting with "els-"
    FilteredELS = Table.SelectRows(Source, each Text.StartsWith([Name], "els-")),
    
    // Step 3: Extract date from file names
    ExtractedELSdate = Table.TransformColumns(FilteredELS, {{"Name", each Text.Middle(_, 4, 10), type text}}),
    
    // Step 4: Format date from "YYYY_MM_DD" to "YYYY/MM/DD"
    FormatELSdate = Table.ReplaceValue(ExtractedELSdate,"_","/",Replacer.ReplaceText,{"Name"}),
    
    // Step 5: Convert date column to date type
    ELSdateType = Table.TransformColumnTypes(FormatELSdate,{{"Name", type date}}),
    
    // Step 6: Rename the date column
    RenamedELSdate = Table.RenameColumns(ELSdateType,{{"Name", "ELS Date"}}),
    
    // Step 7: Invoke transformation function on each file content
    InvokeDEDUCTIONSTransformFile = Table.AddColumn(RenamedELSdate, "DEDUCTIONSTransformFile", each Table5DEDUCTIONSTransformFile([Content])),
    
    // Step 8: Remove unnecessary columns
    RemovedOtherColumns = Table.RemoveColumns(InvokeDEDUCTIONSTransformFile,{"Content", "Extension", "Date accessed", "Date modified", "Date created", "Attributes", "Folder Path"}),
    
    // Step 9: Expand the table column containing transformed file data
    ExpandedDEDUCTIONSTransformFile = Table.ExpandTableColumn(RemovedOtherColumns, "DEDUCTIONSTransformFile", {"Merged", "Value"}, {"Merged", "Value"}),
    
    // Step 10: Sort rows by ELS Date and Merged
    SortedRows = Table.Sort(ExpandedDEDUCTIONSTransformFile,{{"ELS Date", Order.Ascending}, {"Merged", Order.Ascending}}),
    
    // Step 11: Pivot the Merged column
    PivotedColumn = Table.Pivot(SortedRows, List.Distinct(SortedRows[Merged]), "Merged", "Value", List.Sum),
    
    // Step 12: Change data types of currency columns
    ChangedType = Table.TransformColumnTypes(PivotedColumn,{
        {"Basic Life Insurance Current", Currency.Type}, 
        {"Basic Life Insurance YTD", Currency.Type}, 
        {"FERS Retirement Current", Currency.Type}, 
        {"FERS Retirement YTD", Currency.Type}, 
        {"Federal Tax Current", Currency.Type}, 
        {"Federal Tax YTD", Currency.Type}, 
        {"Medicare Current", Currency.Type}, 
        {"Medicare YTD", Currency.Type}, 
        {"OASDI or Social Security Current", Currency.Type}, 
        {"OASDI or Social Security YTD", Currency.Type}, 
        {"State Tax 1 ( SC ) Current", Currency.Type}, 
        {"State Tax 1 ( SC ) YTD", Currency.Type}, 
        {"Thrift Savings Plan Current", Currency.Type}, 
        {"Thrift Savings Plan YTD", Currency.Type}, 
        {"Dental Current", Currency.Type}, 
        {"Dental YTD", Currency.Type}, 
        {"FSA DC Current", Currency.Type}, 
        {"FSA DC YTD", Currency.Type}, 
        {"FSA HC Current", Currency.Type}, 
        {"FSA HC YTD", Currency.Type}, 
        {"TSP Roth Current", Currency.Type}, 
        {"TSP Roth YTD", Currency.Type}, 
        {"Health Benefits - Pretax Current", Currency.Type}, 
        {"Health Benefits - Pretax YTD", Currency.Type}, 
        {"Pretax Current", Currency.Type}, 
        {"Pretax YTD", Currency.Type}, 
        {"Vision Current", Currency.Type}, 
        {"Vision YTD", Currency.Type}, 
        {"Savings Allotment Current", Currency.Type}, 
        {"Savings Allotment YTD", Currency.Type}})
in
    ChangedType