/* WORDPOS */
  say "Look for WORDPOS OK"
/* These from the Rexx book. */
  if wordpos('the','Now is the time') \= 3         then exit
  if wordpos('The','Now is the time') \= 0         then exit
  if wordpos('is the','Now is the time') \= 2      then exit
  if wordpos('is    the','Now is the time') \= 2   then exit
  if wordpos('be','To be or not to be') \= 2       then exit
  if wordpos('be','To be or not to be',3) \= 6     then exit
/* These from Mark Hessling. */
  if wordpos('This','This is a small test') \==  1        then exit
  if wordpos('test','This is a small test') \==  5        then exit
  if wordpos('foo','This is a small test') \==  0         then exit
  if wordpos('  This  ','This is a small test') \==  1    then exit
  if wordpos('This','  This is a small test') \==  1      then exit
  if wordpos('This','This   is a small test') \==  1      then exit
  if wordpos('This','this is a small This') \==  5        then exit
  if wordpos('This','This is a small This') \==  1        then exit
  if wordpos('This','This is a small This', 2) \==  5     then exit
  if wordpos('is a ','This  is a small test') \==  2      then exit
  if wordpos('is   a ','This  is a small test') \==  2    then exit
  if wordpos('  is a ','This  is  a small test') \==  2   then exit
  if wordpos('is a ','This  is a small test', 2) \==  2   then exit
  if wordpos('is a ','This  is a small test',3) \==  0     then exit
  if wordpos('is a ','This  is a small test',4) \==  0    then exit
  if wordpos('test  ','This  is a small test') \==  5     then exit
  if wordpos('test  ','This  is a small test',5) \==  5   then exit
  if wordpos('test  ','This  is a small test',6) \==  0   then exit
  if wordpos('test  ','This  is a small test   ') \==  5  then exit
  if wordpos('  test','This  is a small test   ',6) \==  0 then exit
  if wordpos('test  ','This  is a small test   ',5) \==  5 then exit
  if wordpos('      ','This  is a small test') \==  0      then exit
  if wordpos('      ','This  is a small test',3) \==  0    then exit
  if wordpos('','This  is a small test',4) \==  0          then exit
  if wordpos('test  ','') \==  0                           then exit
  if wordpos('','') \==  0                                 then exit
  if wordpos('','  ') \==  0                               then exit
  if wordpos('  ','') \==  0                               then exit
  if wordpos('  ','', 3) \==  0                            then exit
  if wordpos(' a ','') \==  0                              then exit
  if wordpos(' a ','a') \==  1                             then exit
  say "WORDPOS OK"
