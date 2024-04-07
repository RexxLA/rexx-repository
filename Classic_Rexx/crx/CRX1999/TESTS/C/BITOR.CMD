/* BITOR */
  say "Look for BITOR OK"
/* These from the Rexx book. */
  if bitor('15'x,'24'x) \= '35'x  then exit
  if bitor('15'x,'2456'x) \= '3556'x  then exit
  if bitor('15'x,'2456'x,'F0'x) \= '35F6'x  then exit
  if bitor('1111'x,,'4D'x) \= '5D5d'x  then exit
/* These from Mark Hessling. */
  if bitor( '123456'x, '3456'x ) \==         '367656'x  then exit
  if bitor( '3456'x, '123456'x, '99'x ) \==  '3676df'x  then exit
  if bitor( '123456'x,, '55'x) \==           '577557'x  then exit
  if bitor( 'foobar' ) \==                   'foobar'   then exit
/* This one is ASCII dependent */
  if bitor( 'FooBar' ,, '20'x) \==           'foobar'   then exit
  say "BITOR OK"
