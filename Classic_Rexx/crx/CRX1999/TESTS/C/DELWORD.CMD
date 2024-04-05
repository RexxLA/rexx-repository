/* These from TRL */
  say "Look for DELWORD OK"
  if delword('Now is the  time',2,2) \== 'Now time'     then exit
  if delword('Now is the time ',3) \== 'Now is '        then exit
  if delword('Now  time',5) \== 'Now  time'             then exit
/* These from Mark Hessling. */
  if delword("Med lov skal land bygges", 3) \==  "Med lov "         then exit
  if delword("Med lov skal land bygges", 1) \==  ""                 then exit
  if delword("Med lov skal land bygges", 1,1) \==  "lov skal land bygges" then exit
  if delword("Med lov skal land bygges", 2,3) \==  "Med bygges"     then exit
  if delword("Med lov skal land bygges", 2,10) \==  "Med "          then exit
  if delword("Med lov   skal land bygges", 3,2) \==  "Med lov   bygges" then exit
  if delword("Med lov   skal land   bygges", 3,2) \==  "Med lov   bygges" then exit
  if delword("Med lov skal land   bygges", 3,2) \==  "Med lov bygges" then exit
  if delword("Med lov skal land bygges", 3,0) \==  "Med lov skal land bygges" then exit
  if delword("Med lov skal land bygges", 10) \==  "Med lov skal land bygges" then exit
  if delword("Med lov skal land bygges", 9,9) \==  "Med lov skal land bygges" then exit
  if delword("Med lov skal land bygges", 1,0) \==  "Med lov skal land bygges" then exit
  if delword("  Med lov skal", 1,0) \==  "  Med lov skal" then exit
  if delword("  Med lov skal   ", 4) \==  "  Med lov skal   " then exit
  if delword("", 1) \==  ""                                   then exit
  say "DELWORD OK"
