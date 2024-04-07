/* B2X */
  say "Look for B2X OK"
/* These from the Rexx book. */
  if b2x('11000011') \== 'C3'   then exit
  if b2x('10111') \== '17'   then exit
  if b2x('101') \== '5'   then exit
  if b2x('1 1111  0000') \== '1F0'   then exit
  if x2d(b2x('10111')) \== '23'   then exit
/* These from Mark Hessling. */
  if b2x("") \== ""                        then exit
  if b2x("0") \== "0"                      then exit
  if b2x("1") \== "1"                      then exit
  if b2x("10") \== "2"                     then exit
  if b2x("010") \== "2"                    then exit
  if b2x("1010") \== "A"                   then exit
  if b2x("1 0101") \== "15"                then exit
  if b2x("1 01010101") \== "155"           then exit
  if b2x("1 0101 0101") \== "155"          then exit
  if b2x("10101 0101") \== "155"           then exit
  if b2x("0000 00000000 0000") \== "0000"  then exit
  if b2x("11111111 11111111") \== "FFFF"   then exit
  say "B2X OK"
