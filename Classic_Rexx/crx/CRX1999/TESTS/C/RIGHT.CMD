/* These from TRL */
  say "Look for RIGHT OK"
  if right('abc  d',8) \== '  abc  d'       then exit
  if right('abc def',5) \== 'c def'         then exit
  if right('12',5,'0') \== '00012'          then exit
/* These from Mark Hessling. */
  if right("",4) \==            "    "                   then exit
  if right("foobar",0) \==      ""                       then exit
  if right("foobar",3) \==      "bar"                    then exit
  if right("foobar",6) \==      "foobar"                 then exit
  if right("foobar",8) \==      "  foobar"               then exit
  if right("foobar",8,'*') \==  "**foobar"               then exit
  if right("foobar",4,'*') \==  "obar"                   then exit
  say "RIGHT OK"
