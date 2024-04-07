/* ABS */
  say "Look for ABS OK"
/* These from the Rexx book. */
  if abs('12.3') \= 12.3      then exit
  if abs(' -0.307') \= 0.307  then exit
/* These from Mark Hessling. */
  if abs(-12.345) \== 12.345 then exit
  if abs(12.345)  \== 12.345 then exit
  if abs(-0.0)    \== 0      then exit
  if abs(0.0)     \== 0      then exit
  say "ABS OK"
