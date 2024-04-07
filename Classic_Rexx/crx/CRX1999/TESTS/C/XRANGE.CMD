/* XRANGE */
  say "Look for XRANGE OK"
/* These from the Rexx book. */
  if xrange('a','f') \== 'abcdef'          then exit
  if xrange('03'x,'07'x) \== '0304050607'x then exit
  if xrange('04'x)       \== '0001020304'x then exit
  if xrange('FE'x,'02'x) \== 'FEFF000102'x then exit
/* These from Mark Hessling. */
  if xrange('f','r') \==  'fghijklmnopqr'          then exit
  if xrange('7d'x,'83'x) \==  '7d7e7f80818283'x    then exit
  if xrange('a','a') \==  'a'                      then exit
  say "XRANGE OK"
