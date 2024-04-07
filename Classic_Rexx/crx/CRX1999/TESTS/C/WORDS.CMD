/* WORDS */
  say "Look for WORDS OK"
/* These from the Rexx book. */
  if words('Now is the time') \= 4   then exit
  if words(' ') \= 0                 then exit
/* These from Mark Hessling. */
  if words('This is certainly a test') \==  5      then exit
  if words('   This is certainly a test') \==  5   then exit
  if words('This    is certainly a test') \==  5   then exit
  if words('This is certainly a test   ') \==  5   then exit
  if words('  hepp ') \==  1                       then exit
  if words('  hepp        hepp   ') \==  2         then exit
  if words('') \==  0                              then exit
  if words('   ') \==  0                           then exit
  say "WORDS OK"
