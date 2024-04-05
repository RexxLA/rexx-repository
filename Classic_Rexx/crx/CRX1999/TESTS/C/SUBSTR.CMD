/* SUBSTR */
  say "Look for SUBSTR OK"
/* These from the Rexx book. */
  if substr('abc',2) \== 'bc'           then exit
  if substr('abc',2,4) \== 'bc  '       then exit
  if substr('abc',2,6,'.') \== 'bc....' then exit
/* These from Mark Hessling. */
  if substr("foobar",2,3) \==   "oob"                then exit
  if substr("foobar",3) \==   "obar"                 then exit
  if substr("foobar",3,6) \==   "obar  "             then exit
  if substr("foobar",3,6,'*') \==   "obar**"         then exit
  if substr("foobar",6,3) \==   "r  "                then exit
  if substr("foobar",8,3) \==   "   "                then exit
  say "SUBSTR OK"
