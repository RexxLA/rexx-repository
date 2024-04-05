/* X2B */
  say "Look for X2B OK"
/* These from the Rexx book. */
  if x2b('C3') \== '11000011'     then exit
  if x2b('7') \== '0111'     then exit
  if x2b('1 C1') \== '000111000001'     then exit
  if x2b(c2x('C3'x)) \== '11000011'     then exit
  if x2b(d2x('129')) \== '10000001'     then exit
  if x2b(d2x('12')) \== '1100'     then exit
/* These from Mark Hessling. */
  if x2b("416263") \==  "010000010110001001100011"  then exit
  if x2b("DeadBeef") \==  "11011110101011011011111011101111" then exit
  if x2b("1 02 03") \==  "00010000001000000011"              then exit
  if x2b("102 03") \==  "00010000001000000011"               then exit
  if x2b("102") \==  "000100000010"                          then exit
  if x2b("11 2F") \==  "0001000100101111"                    then exit
  if x2b("") \==  ""                                         then exit
  say "X2B OK"
