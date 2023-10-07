Say "Running all tests..."
Say "--------------------"

Call "rxu.rex" "test.charin.rxu auto" 
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/linein.rxu auto" 
If result \== 0 Then Exit result

Call "testutf8.rex"
If result \== 0 Then Exit result

Call "rxu.rex" "basic.rxu"
If result \== 0 Then Exit result

Say "Calling textrxu.rxu..."
Call "rxu.rex" "../samples/testrxu.rxu"
If result \== 0 Then Exit result
Say 

Call "rxu.rex" "../samples/datatypec.rxu"
If result \== 0 Then Exit result

Call "rxu.rex" "../samples/pos.rxu"
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