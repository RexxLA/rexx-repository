/* LASTPOS */
  say "Look for LASTPOS OK"
/* These from the Rexx book. */
  if lastpos(' ','abc def ghi') \= 8    then exit
  if lastpos(' ','abcdefghi') \= 0      then exit
  if lastpos(' ','abc def ghi',7) \= 4  then exit
/* These from Mark Hessling. */
  if lastpos('b', 'abc abc') \==  6          then exit
  if lastpos('b', 'abc abc',5) \==  2        then exit
  if lastpos('b', 'abc abc',6) \==  6        then exit
  if lastpos('b', 'abc abc',7) \==  6        then exit
  if lastpos('x', 'abc abc') \==  0          then exit
  if lastpos('b', 'abc abc',20) \==  6       then exit
  if lastpos('b', '') \==  0                 then exit
  if lastpos('', 'c') \==  0                 then exit
  if lastpos('', '') \==  0                  then exit
  if lastpos('b', 'abc abc',20) \==  6       then exit
  if lastpos('bc', 'abc abc') \==  6         then exit
  if lastpos('bc ', 'abc abc',20) \==  2     then exit
  if lastpos('abc', 'abc abc',6) \==  1      then exit
  if lastpos('abc', 'abc abc') \==  5        then exit
  if lastpos('abc', 'abc abc',7) \==  5      then exit
/* These from elsewhere. */
  if pos('abc','abcdefabccdabcd',4) \== 7    then exit
  say "LASTPOS OK"
