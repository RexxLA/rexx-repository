/* POS */
  say "Look for POS OK"
/* These from the Rexx book. */
  if pos('day','Saturday') \= 6      then exit
  if pos('x','abc def ghi') \= 0     then exit
  if pos(' ','abc def ghi') \= 4     then exit
  if pos(' ','abc def ghi',5) \= 8   then exit
/* These from Mark Hessling. */
  if pos('foo','a foo foo b') \==  3                            then exit
  if pos('foo','a foo foo',3) \==  3                            then exit
  if pos('foo','a foo foo',4) \==  7                            then exit
  if pos('foo','a foo foo b',30) \==  0                         then exit
  if pos('foo','a foo foo b',1) \==  3                          then exit
  if pos('','a foo foo b') \==  0                               then exit
  if pos('foo','') \==  0                                       then exit
  if pos('','') \==  0                                          then exit
  if pos('b' , 'a') \==  0                                      then exit
  if pos('b','b') \==  1                                        then exit
  if pos('b','abc') \==  2                                      then exit
  if pos('b','def') \==  0                                      then exit
  if pos('foo','foo foo b') \==  1                              then exit
  say "POS OK"
