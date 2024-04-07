/* D2X */
  say "Look for D2X OK"
/* These from the Rexx book. */
  if d2x(9) \== '9'   then exit
  if d2x(129) \== '81'   then exit
  if d2x(129,1) \== '1'   then exit
  if d2x(129,2) \== '81'   then exit
  if d2x(129,4) \== '0081'   then exit
  if d2x(257,2) \== '01'   then exit
  if d2x(-127,2) \== '81'   then exit
  if d2x(-127,4) \== 'FF81'   then exit
  if d2x(12,0) \== ''   then exit
/* These from Mark Hessling. */
  if d2x(0) \==  ""             then exit
  if d2x(127) \==  "7F"         then exit
  if d2x(128) \==  "80"         then exit
  if d2x(129) \==  "81"         then exit
  if d2x(1) \==  "1"            then exit
  if d2x(-1,2) \==  "FF"        then exit
  if d2x(-127,2) \==  "81"      then exit
  if d2x(-128,2) \==  "80"      then exit
  if d2x(-129,2) \==  "7F"      then exit
  if d2x(-1,3) \==  "FFF"       then exit
  if d2x(-127,3) \==  "F81"     then exit
  if d2x(-128,4) \==  "FF80"    then exit
  if d2x(-129,5) \==  "FFF7F"   then exit
  if d2x(129,0) \==  ""         then exit
  if d2x(129,2) \==  "81"       then exit
  if d2x(256+129,4) \==  "0181" then exit
  if d2x(256*256+256+129,6) \==  "010181" then exit
  say "D2X OK"
