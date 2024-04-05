/* SIGN */
  say "Look for SIGN OK"
/* These from the Rexx book. */
  if sign('12.3') \= 1               then exit
  if sign(0.0) \= 0                  then exit
  if sign(' -0.307') \= -1           then exit
/* These from Mark Hessling. */
  if sign("0") \==     0                                  then exit
  if sign("-0") \==    0                                  then exit
  if sign("0.4") \==   1                                  then exit
  if sign("-10") \==  -1                                  then exit
  if sign("15") \==    1                                  then exit
  say "SIGN OK"
