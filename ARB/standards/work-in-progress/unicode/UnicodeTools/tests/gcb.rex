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

-- gcb.rex - Performs a consistency check on the properties implemented by 
-- /components/properties/gcb.cls
--
-- See also /components/bin/build/gcb.rex

  Call "Unicode.cls"

  self = .Unicode.Grapheme_Cluster_Break
  
  super = self~superClass
      
  Call Time "R"
  
  Say "Running consistency checks..."

  inFile = super~UCDFile.Qualify( self~UnicodeData )

  Call Stream inFile,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream inFile,"C","Open Read"

  ccc. = 0
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code";" ";"ccc";"
    If ccc \== 0 Then ccc.code = 1
  End
  
  Call Stream inFile,"C","Close"
  
  Say "Checking the 'Grapheme_Cluster_Break' property for 1114112 codepoints..."
  
  inFile = super~UCDFile.Qualify( self~GraphemeBreakProperty )
  
  Call Stream inFile,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream inFile,"C","Open Read"
  
  checked. = 0 -- Will allow us to check non-listed code points
  count = 0
  Do While Lines(inFile)
    line = LineIn(infile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value"#"
    codes = Strip(codes)
    value = Strip(value)
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do; min = codes; max = codes; End
    Do i = X2D(min) To X2D(max)
      checked.i = 1
      xCode = D2X(i)
      If Length(xCode) < 4 Then xCode = Right(xCode, 4, 0)
      count += 1
      If ccc.xCode, value == "Extend", self[xCode] == "Extend_ExtCccZwj" Then Nop
      Else If self[xCode] \== Value Then Do
        Say "Consistency check failed at codepoint 'U+"xCode"', got '"self[xCode]"', expected '"value"'."
        Exit 1
      End
    End
  End
  
  ExtPic. = 0
  ExtPics = 0
  Do i = 0 To 1114111
    If checked.i Then Iterate
    xCode = D2X(i)
    count += 1
    If Length(xCode) < 4 Then xCode = Right(xCode, 4, 0)
    If self[xCode] == "Extended_Pictographic" Then Do
      ExtPic.i = 1
      ExtPics += 1
    End
    Else If self[xCode] \== "Other" Then Do
      Say "Consistency check failed at codepoint 'U+"xCode"', got '"self[xCode]"', expected 'Other'."
      Exit 1
    End
  End

  Call Stream inFile,"C","Close"

  inFile = super~UCDFile.Qualify( self~Emoji_data )
  
  Call Stream inFile,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream inFile,"C","Open Read"
  
  extpic = 0
  Do While Lines(inFile)
    line = LineIn(infile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes";"value"#"
    codes = Strip(codes)
    value = Strip(value)
    If value \== "Extended_Pictographic" Then Iterate
    If Pos("..",codes) > 0 Then Parse Var codes min".."max
    Else Do; min = codes; max = codes; End
    Do i = X2D(min) To X2D(max)
      count += 1
      extpic += 1
      If ExtPic.i Then ExtPics -= 1
      Else Do
        xCode = D2X(i)
        If Length(xCode) < 4 Then xCode = Right(xCode, 4, 0)
        Say "Consistency check failed at codepoint 'U+"xCode"', marked as 'Extended_Pictographic' in '"inFile"' but not on binary file"
        Exit 1
      End
    End
  End
  If ExtPics \== 0 Then Do
    Say "Consistency check failed:" ExtPics "'Extended_Pictographic' items remaining"  
    Exit 1
  End

  Call Stream inFile,"C","Close"

  inFile = super~UCDFile.Qualify( self~GraphemeBreakTest )

  Say "Running all the tests in GraphemeBreakTest.txt..."

  bad = 0
  Do lineno = 1 By 1 While Lines(inFile) > 0
    line = LineIn(inFile)
    If line[1] == "#" Then Iterate
    If line    =  ""  Then Iterate
    Parse Var line codes"#"
    check = codes~MakeArray("÷")
    check~delete(check~items)
    check~delete(1)
    Do i = 1 To Check~items
      check[i] = Space(ChangeStr("×",check[i]," "))
    End
    save = codes
    codes = ChangeStr("÷",codes," ")
    codes = ChangeStr("×",codes," ")
    codes = Space(codes)
    codearray = codes~makeArray(" ")
    graphemes = .Unicode.Grapheme_Cluster_Break~codepointsToGraphemes(codearray,"UxTF8")
    items = graphemes~items
    good = 1
    Do i = 1 To items
      If graphemes[i] \= check[i] Then good = 0
    End
    If good Then Iterate
    bad = bad + 1
    Say lineno": Analyzing" Strip(save)"..."
    Say items "graphemes"
    Do i = 1 To items
      Say i":"graphemes[i] "(vs." check[i]")"
    End
  End
  If bad == 0 Then 
    Say "All tests PASSED"
  Else 
    Say bad "tests FAILED"

  elapsed = Time("E")
  If elapsed = 0 Then elapsed = "0.001"
  
  Say count "codepoints checked in" elapsed "seconds." 
  Say "This is" (count/elapsed) "codepoints/second."
  Say extpic "'Extended_Pictographic' values were checked twice."
  Say ccc.~items "values changed from 'Extend' to 'Extend_ExtCccZwj'."
  Say 
  
  Exit bad