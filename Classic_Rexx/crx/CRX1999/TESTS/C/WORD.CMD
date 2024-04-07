/* WORD */
  say "Look for WORD OK"
/* These from the Rexx book. */
  if word('Now is the time',3) \== 'the' then exit
  if word('Now is the time',5) \== ''    then exit
/* These from Mark Hessling. */
  if word('This is certainly a test',1) \==  'This'    then exit
  if word('   This is certainly a test',1) \==  'This' then exit
  if word('This    is certainly a test',1) \==  'This' then exit
  if word('This    is certainly a test',2) \==  'is'   then exit
  if word('This is    certainly a test',2) \==  'is'   then exit
  if word('This is certainly a    test',5) \==  'test' then exit
  if word('This is certainly a test   ',5) \==  'test' then exit
  if word('This is certainly a test',6) \==  ''        then exit
  if word('',1) \==  ''                                then exit
  if word('',10) \==  ''                               then exit
  if word('test ',2) \==  ''                          then exit
  say "WORD OK"
