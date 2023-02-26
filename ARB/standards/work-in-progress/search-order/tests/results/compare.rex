-- Quick and dirty: compare two results of sotest.rex, 
-- and display the first test such that the result 
-- is different, or nothing if the results are identical.
Arg a1 a2

Call (a1)
p. = result

Call (a2)
q. = result

Do i = 1 To Min(p.0,q.0)
  If p.i \== q.i Then 
    Say "Different at '"p.i.test"'."
End