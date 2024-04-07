/* These from TRL */
  say "Look for DELSTR OK"
  if delstr('abcd',3) \== 'ab'             then exit
  if delstr('abcde',3,2) \== 'abe'         then exit
  if delstr('abcde',6) \== 'abcde'         then exit
/* These from Mark Hessling. */
  if delstr("Med lov skal land bygges", 6) \==  "Med l"             then exit
  if delstr("Med lov skal land bygges", 6,10) \==  "Med lnd bygges" then exit
  if delstr("Med lov skal land bygges", 1) \==  ""                  then exit
  if delstr("Med lov skal", 30) \==  "Med lov skal"                 then exit
  if delstr("Med lov skal", 8 , 8) \==  "Med lov"                   then exit
  if delstr("Med lov skal", 12) \==  "Med lov ska"                  then exit
  if delstr("Med lov skal", 13) \==  "Med lov skal"                 then exit
  if delstr("Med lov skal", 14) \==  "Med lov skal"                 then exit
  if delstr("", 30) \==  ""                                         then exit
  say "DELSTR OK"
