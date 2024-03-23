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
  
-- gc.rex - Performs a consistency check on the properties implemented by properties/name.cls
--
-- See also build/name.rex
  
  Call "Unicode.cls"

  self = .Unicode.Name

  Call Time "R"

  Say "Running consistency checks..."
  Say "" 
  Say "Checking the 'Name' ('na') property for 1114112 codepoints..."

  Do i = 0 To X2D(10FFFF)
    code = d2x(i)
    If i // 100000 = 0 Then Say i "codepoints checked..."
    If Length(code) < 4    Then code = Right(code,4,0)
    Else If code[1] == "0" Then code = Strip(code, "L",0)
    name = P2N(code)
    If name \== "", code == N2P(name) Then Iterate
    Say "Consistency check failed at code point: '"code"'X"
    Say "Name is:" name
    Say "Round trip:" N2P(name)
    Exit 1
  End

  count = i - 1
  elapsed = Time("E")
  If elapsed = 0 Then elapsed = "0.001"
  
  Say count "codepoints checked in" elapsed "seconds."
  Say "This is" (count/elapsed) "codepoints/second."
  Say 
  
Exit 0