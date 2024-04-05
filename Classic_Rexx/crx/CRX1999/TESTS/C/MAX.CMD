/* MAX */
  say "Look for MAX OK"
/* These from the Rexx book. */
  if max(12,6,7,9) \= 12      then exit
  if max(17.3,19,17.03) \= 19 then exit
  if max(-7,-3,-4.3) \= -3 then exit
/* These from Mark Hessling. */
  if max( 10.1 ) \==                "10.1"     then exit
  if max( -10.1, 3.8 ) \==          "3.8"      then exit
  if max( 10.1, 10.2, 10.3 ) \==    "10.3"     then exit
  if max( 10.3, 10.2, 10.3 ) \==    "10.3"     then exit
  if max( 10.1, 10.2, 10.3 ) \==    "10.3"     then exit
  if max( 10.1, 10.4, 10.3 ) \==    "10.4"     then exit
  if max( 10.3, 10.2, 10.1 ) \==    "10.3"     then exit
  if max( 1, 2, 4, 5 ) \==          "5"        then exit
  if max( -0, 0 ) \==               "0"        then exit
  if max( 1,2,3,4,5,6,7,8,7,6,5,4,3,2 ) \==    "8" then exit
  say "MAX OK"
