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

-- gc.rex - Performs a consistency check on the properties implemented by properties/gc.cls
--
-- See also build/gc.rex
  
  Call "Unicode.cls"

  self = .Unicode.General_Category
  
  super = self~superClass
  
  variables = self~variables
   
  nameOf. = "Cn"
  Do counter c variable over variables~makeArray( " " )
    char                           = x2c( d2x( c ) )
    Var2Char.[ Upper( variable ) ] = char
    nameOf.char                    = Left( variable, 2 )
    Call Value variable, char
  End
  
  Call Time "R"
  
  Say "Running consistency checks..."
  Say ""
  Say "Checking the 'General_Category' (gc) property for 1114112 codepoints..."
  
  inFile = super~UCDFile.Qualify( self~UnicodeData )
  
  Call Stream inFile,"C","Close"      -- Recovers if previous run crashed
  
  Call Stream inFile,"C","Open Read"
  
  last = -1
  count = 0
  Do While Lines(inFile)
    Parse Value LineIn(inFile) With code1";"name";"gc";"
    If X2D(code1) \== last + 1 Then Do
      Do i = last + 1 To X2D(code1) - 1
        iCode = D2X(i)
        count += 1
        If self[iCode] \== "Cn" Then Do
          Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected 'Cn'."
          Exit 1
        End
      End
    End
    If name~endsWith("First>") Then Do
      Parse Value LineIn(inFile) With code2";"
      Do i = X2D(code1) To X2D(code2)
        iCode = D2X(i)
        count += 1
        If self[iCode] \== gc Then Do
          Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected '"gc"'."
          Exit 1
        End
      End
      last = i - 1
    End
    Else Do
      count += 1
      If self[code1] \== gc Then Do
        Say "Consistency check failed at codepoint 'U+"code1"', got '"self[code1]"', expected '"gc"'."
        Exit 1
      End
      last = X2D(code1)
    End
  End
  If last < 1114111 Then Do
    Do i = last + 1 To 1114111
      iCode = D2X(i)
      count += 1
      If self[iCode] \== "Cn" Then Do
        Say "Consistency check failed at codepoint 'U+"iCode"', got '"self[iCode]"', expected 'Cn'."
        Exit 1
      End
    End
  End
  
  Call Stream inFile,"C","Close"
  
  elapsed = Time("E")
  If elapsed = 0 Then elapsed = "0.001"
  
  Say count "codepoints checked in" elapsed "seconds."
  Say "This is" (count/elapsed) "codepoints/second."
  Say 
  
  Exit 0