/* X2C */
  say "Look for X2C OK"
/* These from the Rexx book. */
/* if x2c('F7F2 A2') \== '72s' then exit   EBCDIC */
/* if x2c('F7F2a2') \== '72s' then exit    EBCDIC */
  if x2c('F') \== '0F'x then exit
/* These from Mark Hessling. */
  if x2c("416263") \==  "Abc"                then exit
  if x2c("DeadBeef") \==  "deadbeef"x        then exit
  if x2c("1 02 03") \==  "010203"x           then exit
  if x2c("11 0222 3333 044444") \==  "1102223333044444"x then exit
  if x2c("") \==  ""                         then exit
  if x2c("2") \==  "02"x                     then exit
  if x2c("1   02   03") \==  "010203"x       then exit
  say "X2C OK"
