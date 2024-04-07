/* C2D */
  say "Look for C2D OK"
/* These from the Rexx book. */
  if c2d('09'x) \== 9      then exit
  if c2d('81'x) \== 129    then exit
/* EBCDIC
  if c2d('a'x) \== 129    then exit
*/
  if c2d('FF81'x) \== 65409    then exit
  if c2d('') \== 0    then exit
  if c2d('81'x,1) \== -127    then exit
  if c2d('81'x,2) \== 129    then exit
  if c2d('FF81'x,2) \== -127    then exit
  if c2d('FF81'x,1) \== -127    then exit
  if c2d('FF7F'x,1) \==  127    then exit
  if c2d('F081'x,2) \== -3967  then exit
  if c2d('F081'x,1) \== -127  then exit
  if c2d('0031'x,0) \== 0  then exit
/* These from Mark Hessling. */
  if c2d( 'ff80'x, 1) \== '-128'     then exit
/* ASCII */
  if c2d( 'foo' )  \==  "6713199"    then exit
/* ASCII */
  if c2d( 'bar' ) \==   "6447474"    then exit
  if c2d( '' ) \==      "0"          then exit
  if c2d( '101'x ) \==  "257"        then exit
  if c2d( 'ff'x ) \==   "255"        then exit
  if c2d( 'ffff'x) \==  "65535"      then exit
  if c2d( 'ffff'x, 2) \== "-1"       then exit
  if c2d( 'ffff'x, 1) \== "-1"       then exit
  if c2d( 'fffe'x, 2) \== "-2"       then exit
  if c2d( 'fffe'x, 1) \== "-2"       then exit
  if c2d( 'ffff'x, 3) \== "65535"    then exit
  if c2d( 'ff7f'x, 1) \== "127"      then exit
  if c2d( 'ff7f'x, 2) \== "-129"     then exit
  if c2d( 'ff7f'x, 3) \== "65407"    then exit
  if c2d( 'ff80'x, 1) \== "-128"     then exit
  if c2d( 'ff80'x, 2) \== "-128"     then exit
  if c2d( 'ff80'x, 3) \== "65408"    then exit
  if c2d( 'ff81'x, 1) \== "-127"     then exit
  if c2d( 'ff81'x, 2) \== "-127"     then exit
  if c2d( 'ff81'x, 3) \== "65409"    then exit
  if c2d( 'ffffffffff'x, 5) \== "-1" then exit
  say "C2D OK"
