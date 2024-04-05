/* D2C */
  say "Look for D2C OK"
/* These from the Rexx book. */
  if d2c(9) \== '09'x then exit
  if d2c(129) \== '81'x then exit
  if d2c(129,1) \== '81'x then exit
  if d2c(129,2) \== '0081'x then exit
  if d2c(257,1) \== '01'x then exit
  if d2c(-127,1) \== '81'x then exit
  if d2c(-127,2) \== 'FF81'x then exit
  if d2c(-1,4) \== 'FFFFFFFF'x then exit
  if d2c(12,0) \== '' then exit
/* These from Mark Hessling. */
  if d2c(127) \==  "7f"x                then exit
  if d2c(128) \==  "80"x                then exit
  if d2c(129) \==  "81"x                then exit
  if d2c(1) \==  "01"x                  then exit
  if d2c(-1,1) \==  "FF"x               then exit
  if d2c(-127,1) \==  "81"x             then exit
  if d2c(-128,1) \==  "80"x             then exit
  if d2c(-129,1) \==  "7F"x             then exit
  if d2c(-1,2) \==  "FFFF"x             then exit
  if d2c(-127,2) \==  "FF81"x           then exit
  if d2c(-128,2) \==  "FF80"x           then exit
  if d2c(-129,2) \==  "FF7F"x           then exit
  if d2c(129,0) \==  ""                 then exit
  if d2c(129,1) \==  "81"x              then exit
  if d2c(256+129,2) \==  "0181"x        then exit
  if d2c(256*256+256+129,3) \==  "010181"x then exit
  say "D2C OK"
