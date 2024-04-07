/* VERIFY */
  say "Look for VERIFY OK"
/* These from the Rexx book. */
  if verify('123','1234567890') \= 0          then exit
  if verify('1Z3','1234567890') \= 2          then exit
  if verify('AB4T','1234567890','M') \= 3     then exit
  if verify('1P3Q4','1234567890',,3) \= 4     then exit
  if verify('ABCDE','',,3) \= 3               then exit
  if verify('AB3CD5','1234567890','M',4) \= 6 then exit
/* These from Mark Hessling. */
  if verify('foobar', 'barfo', N, 1) \==  0  then exit
  if verify('foobar', 'barfo', M, 1) \==  1  then exit
  if verify('', 'barfo') \==  0              then exit
  if verify('foobar', '') \==  1             then exit
  if verify('foobar', 'barf', N, 3) \==  3   then exit
  if verify('foobar', 'barf', N, 4) \==  0   then exit
  if verify('', '') \==  0                   then exit
  say "VERIFY OK"
