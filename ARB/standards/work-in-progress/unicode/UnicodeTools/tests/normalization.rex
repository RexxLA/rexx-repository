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

-- normalization.rex - Performs a consistency check on the properties implemented by 
-- components/properties/normalization.cls
--
-- See also /components/bin/build/normalization.rex

  Call "Unicode.cls"

  self = .Unicode.normalization
  
  super = self~superClass
      
  Call Time "R"
  
  Say "Running tests for Unicode.normalization.cls..."
  
  Say
  
  Say "Running normalization test suite..."
    
  inFile = super~UCDFile.Qualify( self~NormalizationTest ) 
  
  If Stream(inFile,"C","Query Exists") == "" Then Do
    Say "File '"inFile"' not found."
    Exit 1
  End
  
  Call Stream inFile,"C","Close" -- In case it was left open elsewhere
  
  tests = 0
  
  Do While Lines(inFile)
    line = LineIn(inFile)
    c = line[1]
    If Pos(c,"#@") > 0 Then Iterate
    tests += 1
    Parse Var line source";"NFC";"NFD";"NFKC";"NFKD";"
    source = Codepoints(C2S(source))
    NFD    = C2S(NFD)
    If source == NFD Then Do
      If \Unicode(source,"isNFD") Then Do
        Say "isNFD failed!"
        Parse Var line source";"NFC";"NFD";"NFKC";"NFKD";"
        Say "Source:" source
        Say "NFD   :" NFD
        Say "isNFD :" Unicode(source,"isNFD")
        Exit 1
      End
    End
    Else Do
      If Unicode(source,"isNFD") Then Do
        Say "isNFD failed!"
        Say "Error:" line
        Parse Var line source";"NFC";"NFD";"NFKC";"NFKD";"
        Say "Source:" source
        Say "NFD   :" NFD
        Say "isNFD :" Unicode(source,"isNFD")
        Exit 1
      End
    End
    If Unicode(source,"toNFD") == NFD Then Iterate
    Say "toNFD failed!"
    Say "Error:" line
    Parse Var line source";"NFC";"NFD";"NFKC";"NFKD";"
    Say "Source:" source
    Say "NFD   :" NFD
    Say "toNFD :" Unicode(source,"toNFD")
    Exit 1
  End
  
  Call Stream inFile,"C","Close"
  
  Say "All" tests "tests in the test suite PASSED, t=" Time("E")

  Say
  
  Say "Checking the Canonical_Combining_Class property in UnicodeData.txt..."

  inFile = super~UCDFile.Qualify( self~UnicodeData ) 
  
  If Stream(inFile,"C","Query Exists") == "" Then Do
    Say "File '"inFile"' not found."
    Exit 1
  End
  
  Call Stream inFile,"C","Close" -- In case it was left open elsewhere
  
  tests = 0
  
  oldcode = 0
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";" ";"ccc";"
    dcode = X2D(code)
    If ccc == 0, dcode < X2D(20000) Then Iterate
    Do n = oldcode To dcode-1
      If self~Canonical_Combining_Class(d2x(n)) \== "00"X Then Do
        Say "FAILED! UnicodeData ccc for '"d2x(n)"'U says 0, found" self~Canonical_Combining_Class(d2x(n))~c2x~x2d "instead."
        Exit 1
      End
      tests += 1
    End
    If dcode >= X2D(20000) Then Leave
    If self~Canonical_Combining_Class(code)~c2x~x2d \== ccc Then Do
      Say "FAILED! UnicodeData ccc for '"code"'U says" ccc", found" self~Canonical_Combining_Class(code)~c2x~x2d "instead."
      Exit 1
    End
    tests += 1
    oldcode = dcode + 1
  End

  Call Stream inFile,"C","Close" 
  
  Say "All" tests "ccc tests PASSED, t=" Time("E")"!"
  
  Say 
  
  Say "Checking the Canonical_Decomposition property in UnicodeData.txt..."
  
  tests = 0

  oldCode = 0
  
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";"  ";"  ";"  ";"  ";"decomp";"
    dcode = X2D(code)
    If decomp == ""    , dcode < X2D(30000) Then Iterate
    If decomp[1] == "<", dcode < X2D(30000) Then Iterate
    Do n = oldcode To dcode-1
      If n >= X2D(AC00), n <= X2D(DA73) Then Iterate -- Skip Hangul Syllabes
      nx = NiceCode(D2X(n))
      If self~Canonical_Decomposition(nx) \== nx Then Do
        Say "FAILED! UnicodeData canonical decomposition for '"d2x(n)"'U says '', found" self~Canonical_Decomposition(nx) "instead."
        Exit 1
      End
      tests += 1
    End
    If dcode >= X2D(30000) Then Leave    
    If self~Canonical_Decomposition(code) \== decomp Then Do
      Say "FAILED! UnicodeData canonical decomposition for '"code"'U says '"decomp"', found" self~Canonical_Decomposition(code) "instead."
      Exit 1
    End
    tests += 1
    oldCode = dCode + 1
  End

  Call Stream inFile,"C","Close" 
  
  Say "All" tests "decomposition tests PASSED, t=" Time("E")"!"
  
  Say

  Say "End of tests for Unicode.normalization.cls. All tests PASSED!"  
  
  Say
  
Exit 0

NiceCode: 
  Arg aCode
  aCode = Strip(aCode,"L",0)
  If Length(aCode) < 4 Then aCode = Right(aCode,4,0)
Return aCode  

C2S: Procedure
  Arg source
  res = ""
  Do Words(source)
    Parse var source code source
    res ||= UTF8(code)
  End
Return res  

UTF8: Procedure
  Use Arg code
  n = X2D(code)
  b = X2B(code)
  If b~length == 20 Then b = "0000"||b
  If b~length == 8, n >= 128 Then b = "0000"||b
  Select
    When n <= 127   Then Return X2C(code[3,2])
    When n <= 2047  Then Return X2C(B2X("110"SubStr(b,6,5)"10"Right(b,6)))
    When n <= 65535 Then Return X2C(B2X("1110"Left(b,4)"10"SubStr(b,5,6)"10"Right(b,6)))
    Otherwise            Return X2C(B2X("11110"SubStr(b,4,3) "10"SubStr(b,7,6) "10"SubStr(b,13,6) "10"Right(b,6)))
  End

  