/* COMPARE */
  say "Look for COMPARE OK"
/* These from the Rexx book. */
  if compare('abc','abc') \= 0         then exit
  if compare('abc','ak') \= 2          then exit
  if compare('ab ','ab') \= 0          then exit
  if compare('ab ','ab',' ') \= 0      then exit
  if compare('ab ','ab','x') \= 3      then exit
  if compare('ab-- ','ab','-') \= 5    then exit
/* These from Mark Hessling. */
  say "COMPARE OK"
  if compare("foo", "bar")       \==  1           then exit
  if compare("foo", "foo")       \==  0           then exit
  if compare("   ", "" )         \==  0           then exit
  if compare("foo", "f", "o")    \==  0           then exit
  if compare("foobar", "foobag") \==  6           then exit
