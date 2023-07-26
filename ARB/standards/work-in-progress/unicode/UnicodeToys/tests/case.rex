/*****************************************************************************/
/*                                                                           */
/*  The UNICODE Toys for ooRexx                                              */
/*  ===========================                                              */
/*                                                                           */
/*  Copyright (c) 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>     */
/*                                                                           */
/*  See https://github.com/RexxLA, rexx-repository,                          */
/*      path ARB/standards/work-in-progress/unicode/UnicodeToys              */
/*                                                                           */
/*  License: Apache License 2.0 https://www.apache.org/licenses/LICENSE-2.0  */
/*                                                                           */
/*                                                                           */
/*  case.rex                                                                 */
/*  ========                                                                 */
/*                                                                           */
/*  Performs a consistency check on the properties implemented by            */
/*  properties/case.cls.                                                     */
/*                                                                           */
/*  See also build/case.rex.                                                 */
/*                                                                           */
/*  Version history                                                          */
/*  ===============                                                          */
/*                                                                           */
/*  Vers. Aut Date     Comments                                              */
/*  ----- --- -------- ----------------------------------------------------- */
/*  00.2  JMB 20230725 Moved from properties/case.cls                        */
/*                                                                           */
/*****************************************************************************/

--
-- TODO: 
--
-- * Check SpecialCasing.txt
-- * Allow (maybe with an option) checking until U+10FFFF (currently only
--   until U+1FFFF).
--
--
 
  self = .Unicode.Case

  Call Time "R"    
  
  Say "Running consistency checks for the Unicode.Case class..."  
  Say 
  Say "Checking '"self~UnicodeData"'..."
  inFile = self~UCDFile.Qualify( self~UnicodeData )

  last = -1  
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";" ";"upper";"lower";"
                                   -- 10D0 ;   ;   ;   ;   ;   ;   ;   ;   ;   ;   ;   ;1C90;;10D0
    If upper == "", lower == "" Then Iterate                                   
    n = X2D(code)
    If n > last, n < X2D('20000') Then Do
      Do i = last + 1 To n - 1
        ourCode = D2X(i)
        If Length(ourCode) < 4 Then ourCode = Right(ourCode,4,0)
        ourUpper = self~Simple_Uppercase_Mapping(ourCode)
        ourLower = self~Simple_Lowercase_Mapping(ourCode)
        If ourUpper \== ourCode Then
          Say "Simple_Uppercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourUpper"'."
        If ourLower \== ourCode Then
          Say "Simple_Lowercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourLower"'."
      End
      last = n
    End
    ourUpper = self~Simple_Uppercase_Mapping(code)
    If upper == ""  Then Do
      If ourUpper \== code Then 
        Say "Simple_Uppercase_Mapping for '"code"' should be '"code"', got '"ourUpper"'."
    End
    Else Do
      If ourUpper \== upper Then
        Say "Simple_Uppercase_Mapping for '"code"' should be '"upper"', got '"ourUpper"'."
    End
    ourLower = self~Simple_Lowercase_Mapping(code)
    If lower == ""  Then Do
      If ourLower \== code Then 
        Say "Simple_Lowercase_Mapping for '"code"' should be '"code"', got '"ourLower"'."
    End
    Else Do
      If ourLower \== lower Then
        Say "Simple_Lowercase_Mapping for '"code"' should be '"lower"', got '"ourLower"'."
    End
  End
  Do i = last + 1 To X2D('20000') - 1
    ourCode = D2X(i)
    If Length(ourCode) < 4 Then ourCode = Right(ourCode,4,0)
    ourUpper = self~Simple_Uppercase_Mapping(ourCode)
    ourLower = self~Simple_Lowercase_Mapping(ourCode)
    If ourUpper \== ourCode Then
      Say "Simple_Uppercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourUpper"'."
    If ourLower \== ourCode Then
      Say "Simple_Lowercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourLower"'."
  End
    
    
  Call CheckAFile self~DerivedCoreProperties, self~DerivedCoreProperties.Properties
   
  Call CheckAFile self~DerivedNormalizationProps, self~DerivedNormalizationProps.Properties

  Call CheckAFile self~PropList, self~PropList.Properties
  
Return

CheckAFile: 
  
  Say
  Say "Checking '"Arg(1)"'..."
  
  inFile = self~UCDFile.Qualify(Arg(1))
  
  Do counter c property Over Arg(2)~makeArray(" ")
    Say Right(c,2) "Checking '"property"'..."
    Call Stream inFile, "c", "Close"
    Call Stream inFile, "c", "Open"
    last = 0
    Do Label Check1 While Lines(inFile)
      line = LineIn(inFile)
      If line[1] == "#" Then Iterate
      If line    =  ""  Then Iterate
      Parse Var line codes";"value"#"
      If Pos(";",value) > 0 Then Parse var value value";" YNM
      value = Strip(value)
      If value~endsWith("_QC") Then value ||= "_"Strip(YNM)
      If value \= property Then Iterate
      codes = Strip(codes)
      If Pos("..",codes) > 0 Then Do
        Parse Var codes min".."max
        min = X2D(min)
        max = X2D(max)
      End
      Else Do
        min = X2D(codes)
        max = min
      End
      If min > last, min <= X2D(1FFFF) Then Do
        Do i = last To min - 1
          code = D2X(i)
          If Length(code) < 4 Then code = Right(code,4,"0")
          If self~send(property,code) Then
            Say "Check failed for property '"property"', code U+"code": got 1, expected 0."
        End
      End
      Do i = min To max
        code = D2X(i)
        If Length(code) < 4 Then code = Right(code,4,"0")
        If \self~send(property,code) Then Do
          Say "Check failed for property '"property"', code U+"code": got 0, expected 1."
        End
      End
      last = max + 1        
    End
    If last < X2D(1FFFF) Then Do
      Do i = last To X2D(1FFFF)
        code = D2X(i)
        If Length(code) < 4 Then code = Right(code,4,"0")
        If self~send(property,code) Then
            Say "**Check failed for property '"property"', code U+"code": got 1, expected 0."
      End
      last = i
    End
    Call Stream inFile, "c", "Close"
  End
  
Return  
  
::Requires "case.cls"
