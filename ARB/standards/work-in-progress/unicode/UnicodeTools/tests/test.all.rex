Say "Running all tests..."
Say "--------------------"

Call "rxu.rex" "basic.rxu"
If result \== 0 Then Exit result

Call "rxu.rex" "test.charin.rxu auto" 
If result \== 0 Then Exit result

Call "rxu.rex" "test.charout.rxu auto" 
If result \== 0 Then Exit result

Call "rxu.rex" "test.chars.rxu auto" 
If result \== 0 Then Exit result

Call "rxu.rex" "test.linein.rxu auto" 
If result \== 0 Then Exit result

Call "rxu.rex" "test.lines.rxu auto" 
If result \== 0 Then Exit result

Call "test.utf8.rex"
If result \== 0 Then Exit result

Say "Calling textrxu.rxu..."
Call "rxu.rex" "../samples/testrxu.rxu auto"
If result \== 0 Then Exit result
Say 

Call "rxu.rex" "../samples/coercions.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/datatype.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/datatypec.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/decode.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/lineout.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/lower.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/pos.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/stream.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/streamseek.rxu auto"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/upper.rxu auto"
If result \== 0 Then Exit result

Call "case.rex"
If result \== 0 Then Exit result

Call "gc.rex"
If result \== 0 Then Exit result

Call "gcb.rex"
If result \== 0 Then Exit result

Call "name.rex"
If result \== 0 Then Exit result

Say "All tests PASSED!"
Say "-----------------"
Exit 0