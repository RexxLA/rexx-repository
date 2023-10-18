/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

--------------------------------------------------------------------------------
-- This program is part of the automated test suite. See tests/test.all.rex   --
--------------------------------------------------------------------------------

-- case.rex - Performs a consistency check on the properties implemented by properties/case.cls
--
-- See also build/case.rex

--
-- TODO: 
--
-- * Check SpecialCasing.txt
-- * Allow (maybe with an option) checking until U+10FFFF (currently only
--   until U+1FFFF).
--
--
 
  Call "Unicode.cls"
 
  self = .Unicode.Case
  
  super = self~superClass

  Call Time "R"    
  
  Say "Running consistency checks for the Unicode.Case class..."  
  Say 
  Say "Checking '"self~UnicodeData"'..."
  inFile = super~UCDFile.Qualify( self~UnicodeData )

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
        If ourUpper \== ourCode Then Do
          Say "Simple_Uppercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourUpper"'."
          Exit 1
        End
        If ourLower \== ourCode Then Do
          Say "Simple_Lowercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourLower"'."
          Exit 1
        End
      End
      last = n
    End
    ourUpper = self~Simple_Uppercase_Mapping(code)
    If upper == ""  Then Do
      If ourUpper \== code Then Do
        Say "Simple_Uppercase_Mapping for '"code"' should be '"code"', got '"ourUpper"'."
        Exit 1
      End
    End
    Else Do
      If ourUpper \== upper Then Do
        Say "Simple_Uppercase_Mapping for '"code"' should be '"upper"', got '"ourUpper"'."
        Exit 1 
      End
    End
    ourLower = self~Simple_Lowercase_Mapping(code)
    If lower == ""  Then Do
      If ourLower \== code Then Do
        Say "Simple_Lowercase_Mapping for '"code"' should be '"code"', got '"ourLower"'."
        Exit 1
      End
    End
    Else Do
      If ourLower \== lower Then Do
        Say "Simple_Lowercase_Mapping for '"code"' should be '"lower"', got '"ourLower"'."
        Exit 1
      End
    End
  End
  Do i = last + 1 To X2D('20000') - 1
    ourCode = D2X(i)
    If Length(ourCode) < 4 Then ourCode = Right(ourCode,4,0)
    ourUpper = self~Simple_Uppercase_Mapping(ourCode)
    ourLower = self~Simple_Lowercase_Mapping(ourCode)
    If ourUpper \== ourCode Then Do
      Say "Simple_Uppercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourUpper"'."
      Exit 1
    End
    If ourLower \== ourCode Then Do
      Say "Simple_Lowercase_Mapping for '"ourCode"' should be '"ourCode"', got '"ourLower"'."
      Exit 1
    End
  End
    
  Call CheckAFile self~DerivedCoreProperties, self~DerivedCoreProperties.Properties
   
  Call CheckAFile self~DerivedNormalizationProps, self~DerivedNormalizationProps.Properties

  Call CheckAFile self~PropList, self~PropList.Properties
  
Exit 0

CheckAFile: 
  
  Say
  Say "Checking '"Arg(1)"'..."
  
  inFile = super~UCDFile.Qualify(Arg(1))
  
  Do counter c property Over Arg(2)~makeArray(" ")
    -- Skip alias!
    If property = "Alpha"  Then Iterate
    If property = "Lower"  Then Iterate
    If property = "Upper"  Then Iterate
    If property = "CI"     Then Iterate
    If property = "CWL"    Then Iterate
    If property = "CWU"    Then Iterate
    If property = "CWT"    Then Iterate
    If property = "CWCF"   Then Iterate
    If property = "CWCM"   Then Iterate
    If property = "OAlpha" Then Iterate
    If property = "OLower" Then Iterate
    If property = "OUpper" Then Iterate
    If property = "SD"     Then Iterate
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
          If self~send(property,code) Then Do
            Say "Check failed for property '"property"', code U+"code": got 1, expected 0."
            Exit 1
          End
        End
      End
      Do i = min To max
        code = D2X(i)
        If Length(code) < 4 Then code = Right(code,4,"0")
        If \self~send(property,code) Then Do
          Say "Check failed for property '"property"', code U+"code": got 0, expected 1."
          Exit 1
        End
      End
      last = max + 1        
    End
    If last < X2D(1FFFF) Then Do
      Do i = last To X2D(1FFFF)
        code = D2X(i)
        If Length(code) < 4 Then code = Right(code,4,"0")
        If self~send(property,code) Then Do
          Say "**Check failed for property '"property"', code U+"code": got 1, expected 0."
          Exit 1
        End
      End
      last = i
    End
    Call Stream inFile, "c", "Close"
  End
  
Return