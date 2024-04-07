/* BITXOR */
  say "Look for BITXOR OK"
/* These from the Rexx book. */
  if bitxor('12'x,'22'x)    \== '30'x then exit
  if bitxor('1211'x,'22'x)    \== '3011'x then exit
/* EBCDIC dependent
  if bitxor('C711'x,'222222'x,' ')    \== 'E53362'x then exit
*/
  if bitxor('1111'x,'444444'x,'40'x)    \== '555504'x then exit
  if bitxor('1111'x,,'4D'x)    \== '5C5C'x then exit
/* These from Mark Hessling. */
  if bitxor( '123456'x, '3456'x ) \==         '266256'x then exit
  if bitxor( '3456'x, '123456'x, '99'x ) \==  '2662cf'x then exit
  if bitxor( '123456'x,, '55'x) \==           '476103'x then exit
  if bitxor( 'foobar' ) \==                   'foobar'  then exit
/* This one is ASCII dependent. */
  if bitxor( 'FooBar' ,, '20'x) \==           'fOObAR'  then exit

  say "BITXOR OK"
