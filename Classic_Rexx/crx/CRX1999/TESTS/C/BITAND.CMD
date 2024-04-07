/* BITAND */
  say "Look for BITAND OK"
/* These from the Rexx book. */
  if bitand('73'x,'27'x) \== '23'x then exit
  if bitand('13'x,'5555'x) \== '1155'x then exit
  if bitand('13'x,'5555'x,'74'x) \== '1154'x then exit
/* These from Mark Hessling. */
  if bitand( '123456'x, '3456'x ) \==         '101456'x then exit
  if bitand( '3456'x, '123456'x, '99'x ) \==  '101410'x then exit
  if bitand( '123456'x,, '55'x) \==           '101454'x then exit
  if bitand( 'foobar' ) \==                   'foobar'  then exit
/* This one is ASCII dependent. */
  if bitand( 'FooBar' ,, 'df'x) \==           'FOOBAR'  then exit
  say "BITAND OK"
