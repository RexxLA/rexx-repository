/* SUBWORD */
  say "Look for SUBWORD OK"
/* These from the Rexx book. */
  if subword('Now is the  time',2,2) \== 'is the'    then exit
  if subword('Now is the  time',3) \== 'the  time'   then exit
  if subword('Now is the  time',5) \== ''            then exit
/* These from Mark Hessling. */
  if subword(" to be or not to be ",5) \==   "to be"  then exit
  if subword(" to be or not to be ",6) \==   "be"     then exit
  if subword(" to be or not to be ",7) \==   ""       then exit
  if subword(" to be or not to be ",8,7) \==   ""     then exit
  if subword(" to be or not to be ",3,2) \==   "or not" then exit
  if subword(" to be or not to be ",1,2) \==   "to be"  then exit
  if subword(" to be or not   to be ",4,2) \==   "not   to" then exit
  if subword("abc de f", 3) \==  'f'                        then exit
  say "SUBWORD OK"
