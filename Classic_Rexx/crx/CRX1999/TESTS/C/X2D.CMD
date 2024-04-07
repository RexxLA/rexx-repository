/* X2D */
  say "Look for X2D OK"
/* These from the Rexx book. */
  if x2d('0E') \== 14 then exit
  if x2d('81') \== 129 then exit
  if x2d('F81') \== 3969 then exit
  if x2d('FF81') \== 65409 then exit
/*  if x2d('c6 f0'x) \== 240 then exit  EBCDIC version */
  if x2d('F0') \== 240 then exit
  if x2d('81',2) \== -127 then exit
  if x2d('81',4) \== 129 then exit
  if x2d('F081',4) \== -3967 then exit
  if x2d('F081',3) \== 129 then exit
  if x2d('F081',2) \== -127 then exit
  if x2d('F081',1) \== 1 then exit
  if x2d('0031',0) \== 0 then exit
/* These from Mark Hessling. */
  if x2d( 'ff80', 2) \==  "-128"             then exit
  if x2d( 'ff80', 1) \==  "0"                then exit
  if x2d( 'ff 80', 1) \==  "0"               then exit
  if x2d( '' ) \==       "0"                 then exit
  if x2d( '101' ) \==   "257"                then exit
  if x2d( 'ff' ) \==    "255"                then exit
  if x2d( 'ffff') \==   "65535"              then exit
  if x2d( 'ffff', 2) \==  "-1"               then exit
  if x2d( 'ffff', 1) \==  "-1"               then exit
  if x2d( 'fffe', 2) \==  "-2"               then exit
  if x2d( 'fffe', 1) \==  "-2"               then exit
  if x2d( 'ffff', 4) \==  "-1"               then exit
  if x2d( 'ffff', 2) \==  "-1"               then exit
  if x2d( 'fffe', 4) \==  "-2"               then exit
  if x2d( 'fffe', 2) \==  "-2"               then exit
  if x2d( 'ffff', 3) \==  "-1"               then exit
  if x2d( '0fff') \==  "4095"                then exit
  if x2d( '0fff', 4) \==  "4095"             then exit
  if x2d( '0fff', 3) \==  "-1"               then exit
  if x2d( '07ff') \==  "2047"                then exit
  if x2d( '07ff', 4) \==  "2047"             then exit
  if x2d( '07ff', 3) \==  "2047"             then exit
  if x2d( 'ff7f', 1) \==  "-1"               then exit
  if x2d( 'ff7f', 2) \==  "127"              then exit
  if x2d( 'ff7f', 3) \==  "-129"             then exit
  if x2d( 'ff7f', 4) \==  "-129"             then exit
  if x2d( 'ff7f', 5) \==  "65407"            then exit
  if x2d( 'ff80', 1) \==  "0"                then exit
  if x2d( 'ff80', 2) \==  "-128"             then exit
  if x2d( 'ff80', 3) \==  "-128"             then exit
  if x2d( 'ff80', 4) \==  "-128"             then exit
  if x2d( 'ff80', 5) \==  "65408"            then exit
  if x2d( 'ff81', 1) \==  "1"                then exit
  if x2d( 'ff81', 2) \==  "-127"             then exit
  if x2d( 'ff81', 3) \==  "-127"             then exit
  if x2d( 'ff81', 4) \==  "-127"             then exit
  if x2d( 'ff81', 5) \==  "65409"            then exit
  if x2d( 'ffffffffffff', 12) \==  "-1"      then exit
/* These from SCXBIFA4 */
  if X2D((00000000000000001+1-0.000000)) \== '2'   then exit
  if X2D((1&1|0=22*33)) \==  '1'   then exit
  if X2D((99/3+10*126-(33||2)//5-1099)) \== '402' then exit
  if X2D(ABS((99/3+10*126-(33||2)//5-1099))) \==  '402' then exit
  if X2D(ABS((1&1|0=22*33))) \== '1'   then exit
  if X2D(ABS((00000000000000001+1-0.000000))) \== '2'   then exit
  if X2D(ABS(COPIES(0,249)||1)) \== '1'   then exit
  if X2D(ABS(RIGHT(LEFT(REVERSE(321),2),REVERSE(LEFT(123,ABS(-1)))))) \== '2'then exit
  if X2D(COPIES(0,249)||1) \== '1'   then exit
  if X2D(RIGHT(LEFT(REVERSE(321),2),REVERSE(LEFT(123,ABS(-1))))) \== '2'then exit
/* These from SCBx2d1 */
   if X2D('') \== '0' then exit
   if x2d(''X) \== '0' then exit
   if X2D('a') \== '10' then exit
   if X2D('0f') \== '15'  then exit
   if x2D('80') \== '128'  then exit
   if x2d('765') \== '1893' then exit
Numeric Digits 1000
   if x2D("eeeeeeeeeeeeeeeeeeeeeeeee") \==,
      '1183140560213014108063589658350' then exit
Numeric Digits
   if x2d(01234) \== '4660' then exit
   if x2d(1E2) \== '482' then exit
   if x2d(+1E+2) \== '256' then exit
   if x2d(+.1E2) \== '16' then exit
Signal Off Novalue
   if x2d(baba) \==  '47802' then exit
   if X2D(1 + 1E+2 ) \== '257' then exit
   if X2D('',0) \== '0' then exit
   if X2D('',12) \== '0' then exit
   if X2D('abc',0) \== '0' then exit
   if X2D('abc',1) \==  '-4' then exit
   if X2D('abc',3) \==  '-1348' then exit
   if X2D('abc',5) \==  '2748' then exit
   if X2D('abc',12345) \== '2748' then exit
   if x2d(1+3,1+3) \==  '4' then exit
   if x2D(256+12,10+2) \==  '616' then exit
   if x2d('12',987654321) \==  '18' then exit
   if d2x(X2D('12345')) \== '12345' then exit
  say "X2D OK"
