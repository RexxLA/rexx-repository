/* LENGTH */
  say "Look for LENGTH OK"
/* These from the Rexx book. */
  if length('abcdefgh') \= 8         then exit
  if length('') \= 0                 then exit
/* These from Mark Hessling. */
  if length("") \==             0             then exit
  if length("a") \==            1             then exit
  if length("abc") \==          3             then exit
  if length("abcdefghij") \==  10             then exit
  say "LENGTH OK"
