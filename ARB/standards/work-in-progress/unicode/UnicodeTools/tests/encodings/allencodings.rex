/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

-- Runs all encoding tests. Returns 0 if everything ok, and 1 otherwise. Will take a couple minutes.
 
Call Time "R"

myName = "[Testing all encodings]"

Call Tick "Testing all encodings"
Call Tick "====================="
Say

Call Tick "Testing the CP-437 encoding..."
Call Tick ""
If "testenc.IBM437.rex"()     > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the CP-850 encoding..."
Call Tick ""
If "testenc.IBM850.rex"()     > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the CP-1252 encoding..."
Call Tick ""
If "testenc.windows-1252.rex"()    > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the ISO-8859-1 encoding..."
Call Tick ""
If "testenc.ISO-8859-1.rex"() > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the UTF-8 encoding..."
Call Tick ""
If "testenc.UTF-8.rex"()      > 0 Then Exit 1

Call Tick ""
Call Tick "Testing the UTF-16 encoding..."
Call Tick ""
If "testenc.UTF-16.rex"()     > 0 Then Exit 1

Call Tick ""
Call Tick "All tests for all encodings PASSED!"
Exit 0

Tick:
  Parse Value Time("E") WIth l"."r
  If r == "" Then t = "0.000"  
  Else            t = l"."Left(r,3)
  Say Right(t,10) myName Arg(1)
Return  
