/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

/*****************************************************************************/
/*                                                                           */
/*  The case.rex build program                                               */
/*  ==========================                                               */
/*                                                                           */
/*  This program generates the binary data needed by properties/case.cls.    */
/*                                                                           */
/*  See also tests/case.rex.                                                 */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.2  JMB 20230725 Moved from properties/case.cls                        */
/*                                                                           */
/*****************************************************************************/

  -- Inform our classes that we are building the .bin files, so that they don't
  -- complain that they are not there.
  
  .local~Unicode.Buildtime = 1

  -- Call instead of ::Requires allows us to set the above variable first.

  Call "Unicode.cls"

  self = .Unicode.Case
  
  super = self~superClass

  Do pair Over self~masks
    Call Value pair[1], pair[2]
  End
    
  Call Time "R"
  
  Say "Generating binary values for the Unicode.Case class..."

  -- Default is 0, a character maps to itself
  --
  -- No codepoint >= U+20000 has an explicit lowercase of uppercase mapping

  -- Parse UnicodeData.txt first to tabulate the Simple_Lowercase_Mapping 
  -- and Simple_Lowercase_Mapping properties.
  -- This property always return a single codepoint. To preserve space, 
  -- we calculate the difference between the source codepoint and the property
  -- itself, store these differences in an auxiliary table of 32-bit signed 
  -- integers, and then we store the index into this table as the value
  -- of the property. This effectively creates a three-stage table.
  
  inFile = super~UCDFile.Qualify( self~UnicodeData )
  
  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
  
  buffer = .MutableBuffer~new( Copies( "00"x, X2D( 20000 ) ) )

  code. = 0
  code.0 = 0
  diffs = ""
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";"lower";"
    If lower == "" Then Iterate
    diff = X2d(lower) - X2d(code)
    If code.diff = 0 Then Do
      code.0 += 1
      code.diff = code.0
      diff.[code.0] = diff
      diffs ||= D2C(diff,4)
    End
    buffer[X2d(code)+1] = X2C(D2X(code.diff))
  End
  
  Call Stream inFile, "c", "Close"
  array = .MultiStageTable~Compress(buffer)
  
  super~setPersistent("Lowercase.Table1",       array[1])
  super~setPersistent("Lowercase.Table2",       array[2])
  super~setPersistent("Lowercase.Differences",  diffs)
  
  -- Second pass, to collect upper
  
  Call Stream inFile, "c", "Open"

  buffer = .MutableBuffer~new( Copies( "00"x, X2D( 20000 ) ) )

  code. = 0
  code.0 = 0
  diffs = ""
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";"upper";"
    If upper == "" Then Iterate
    diff = X2d(upper) - X2d(code)
    If code.diff = 0 Then Do
      code.0 += 1
      code.diff = code.0
      diff.[code.0] = diff
      diffs ||= D2C(diff,4)
    End
    buffer[X2d(code)+1] = X2C(D2X(code.diff))
  End
  
  Call Stream inFile, "c", "Close"
    
  array = .MultiStageTable~Compress(buffer)
  
  super~setPersistent("Uppercase.Table1",       array[1])
  super~setPersistent("Uppercase.Table2",       array[2])
  super~setPersistent("Uppercase.Differences",  diffs)

  -- Now we parse SpecialCasing.txt for upper
  
  inFile = super~UCDFile.Qualify( self~SpecialCasing )

  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")

  count = 0
  string = ""
  Do Counter c While Lines(inFile)
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse var line code";" ";" ";"upper";"condition"#"
    If code = upper Then iterate
    upper = Strip(upper)
    If condition \= "" Then Iterate
    count += 1
    string ||= code":"upper";"
  End
  
  super~setPersistent("SpecialUpper", string)
  
  Call Stream inFile, "c", "Close"

  -- Now we parse DerivedCoreProperties.txt for the properties
  -- listed below, in the "valueList" variable.
  
  inFile = super~UCDFile.Qualify( self~DerivedCoreProperties )

  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
  
  buffer = .MutableBuffer~new( Copies( "00"x, 4*X2D( 20000 ) ) )

  valueList = self~DerivedCoreProperties.Properties

  Do While Lines(inFile) > 0
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";" value "#"
    value = Strip(value)
    If WordPos(value, valueList) == 0 Then Iterate
    value = Upper(value)
    codes = Strip(codes)
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do
      min = codes
      max = codes
    End
    If X2D(min) >= X2D("20000") Then Iterate
    Do i = X2D(min) to X2D(max)
      buffer[4*i+1,4] = BitOR(buffer[4*i+1,4], mask.value)
    End
  End
  
  Call Stream inFile, "c", "Close"

  -- Now we parse DerivedNormalizationProps.txt for the properties
  -- listed below, in the "valueList" variable.

  inFile = super~UCDFile.Qualify( self~DerivedNormalizationProps )

  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
    
  valueList = self~DerivedNormalizationProps.Properties

  Do While Lines(inFile) > 0
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";" value"#"
    If Pos(";",value) > 0 Then Parse var value value";" YNM
    value = Strip(value)
    If value~endsWith("_QC") Then value ||= "_"Strip(YNM)
    If WordPos(value, valueList) == 0 Then Iterate
    value = Upper(value)
    codes = Strip(codes)
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do
      min = codes
      max = codes
    End
    If X2D(min) >= X2D("20000") Then Iterate
    Do i = X2D(min) to X2D(max)
      buffer[4*i+1,4] = BitOR(buffer[4*i+1,4], mask.value)
    End
  End
  
  Call Stream inFile, "c", "Close"

  -- Now we parse DerivedNormalizationProps.txt for the properties
  -- listed below, in the "valueList" variable.

  inFile = super~UCDFile.Qualify( self~PropList )

  Call Stream inFile, "c", "query exists"
  
  If result == "" Then self~SyntaxError("File '"inFile"' not found. Aborting")
    
  valueList = self~PropList.Properties

  Do While Lines(inFile) > 0
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";" value "#"
    value = Strip(value)
    If WordPos(value, valueList) == 0 Then Iterate
    value = Upper(value)
    codes = Strip(codes)
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do
      min = codes
      max = codes
    End
    If X2D(min) >= X2D("20000") Then Iterate
    Do i = X2D(min) to X2D(max)
      buffer[4*i+1,4] = BitOR(buffer[4*i+1,4], mask.value)
    End
  End
  
  Call Stream inFile, "c", "Close"

  smallBuffer = .MutableBuffer~new( Copies( "00"x, X2D( 20000 ) ) )
  
  code. = 0
  count = 0
  codes = ""
  Do i = 0 To X2D(1FFFF)
    mask = buffer[4*i+1,4]
    If code.mask == 0 Then Do
      count += 1
      code.mask = count
      codes ||= mask
    End
    smallBuffer[i+1] = X2C(D2X(code.mask))
  End
  Say "Found a total of" count "different bit masks."

  array = .MultiStageTable~Compress(smallBuffer)
  
  super~setPersistent("CaseAndCaseMappingBitProperties.Table1", array[1])
  super~setPersistent("CaseAndCaseMappingBitProperties.Table2", array[2])
  super~setPersistent("CaseAndCaseMappingBitProperties.Table3", codes)
  
  super~SavePersistent( super~BinFile.Qualify( self~binaryFile ) )
  
  elapsed = Time("E")
  Say "Done, took" elapsed "seconds."