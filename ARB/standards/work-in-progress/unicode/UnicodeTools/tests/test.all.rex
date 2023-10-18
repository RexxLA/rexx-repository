/****************************************************************************************************************

 ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐  
 │ This file is part of The Unicode Tools Of Rexx (TUTOR).                                                       │
 │ See https://github.com/RexxLA/rexx-repository/tree/master/ARB/standards/work-in-progress/unicode/UnicodeTools │
 │ Copyright © 2023 Josep Maria Blasco <josep.maria.blasco@epbcn.com>.                                           │
 │ License: Apache License 2.0 (https://www.apache.org/licenses/LICENSE-2.0).                                    │
 └───────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
 *****************************************************************************************************************/

Call Time("R")

Say Time("E") "Running all tests..."
Say Time("E") "--------------------"

Say Time("E") "Calling basic.rxu..."
Call "rxu.rex" "basic.rxu"
If result \== 0 Then Exit result

Say Time("E") "Calling test.charin.rxu..."
Call "rxu.rex" "test.charin.rxu auto" 
If result \== 0 Then Exit result

Say Time("E") "Calling test.charout.rxu..."
Call "rxu.rex" "test.charout.rxu auto" 
If result \== 0 Then Exit result

Say Time("E") "Calling test.chars.rxu..."
Call "rxu.rex" "test.chars.rxu auto" 
If result \== 0 Then Exit result

Say Time("E") "Calling test.linein.rxu..."
Call "rxu.rex" "test.linein.rxu auto" 
If result \== 0 Then Exit result

Say Time("E") "Calling test.lines.rxu..."
Call "rxu.rex" "test.lines.rxu auto" 
If result \== 0 Then Exit result

Say Time("E") "Calling test.unicode.property.rxu..."
Call "rxu.rex" "test.unicode.property.rxu auto" 
If result \== 0 Then Exit result

Say Time("E") "Calling test.utf8.rex..."
Call "test.utf8.rex"
If result \== 0 Then Exit result

Say Time("E") "Calling testrxu.rxu..."
Call "rxu.rex" "../samples/testrxu.rxu auto"
If result \== 0 Then Exit result
Say 

Say Time("E") "Calling samples/coercions.rxu..."
Call "rxu.rex" "../samples/coercions.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/datatype.rxu..."
Call "rxu.rex" "../samples/datatype.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/datatypec.rxu..."
Call "rxu.rex" "../samples/datatypec.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/decode.rxu..."
Call "rxu.rex" "../samples/decode.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/lineout.rxu..."
Call "rxu.rex" "../samples/lineout.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/lower.rxu..."
Call "rxu.rex" "../samples/lower.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/nfd.rxu..."
Call "rxu.rex" "../samples/nfd.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/pos.rxu..."
Call "rxu.rex" "../samples/pos.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/stream.rxu..."
Call "rxu.rex" "../samples/stream.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/streamseek.rxu..."
Call "rxu.rex" "../samples/streamseek.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling samples/upper.rxu..."
Call "rxu.rex" "../samples/upper.rxu auto"
If result \== 0 Then Exit result

Say Time("E") "Calling case.rex..."
Call "case.rex"
If result \== 0 Then Exit result

Say Time("E") "Calling gc.rex..."
Call "gc.rex"
If result \== 0 Then Exit result

Say Time("E") "Calling gcb.rex..."
Call "gcb.rex"
If result \== 0 Then Exit result

Say Time("E") "Calling name.rex..."
Call "name.rex"
If result \== 0 Then Exit result

Say Time("E") "Calling normalization.rex..."
Call "normalization.rex"
If result \== 0 Then Exit result

Say Time("E")
Say Time("E") "All tests PASSED!"
Say Time("E") "-----------------"

Exit 0