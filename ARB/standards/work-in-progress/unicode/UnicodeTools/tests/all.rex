Say "Running all tests..."
Say "--------------------"

Call "rxu.rex" "basic.rxu"
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