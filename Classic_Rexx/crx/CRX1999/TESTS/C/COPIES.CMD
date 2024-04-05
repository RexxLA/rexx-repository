/* These from TRL */
  say "Look for COPIES OK"
  if copies('abc',3) \== 'abcabcabc' then exit
  if copies('abc',0) \== ''          then exit
/* These from Mark Hessling. */
  if copies("foo",3)      \==  "foofoofoo"        then exit
  if copies("x", 10)      \==  "xxxxxxxxxx"       then exit
  if copies("", 50)       \==  ""                 then exit
  if copies("", 0)        \==  ""                 then exit
  if copies("foobar",0 )  \==  ""                 then exit
  say "COPIES OK"
