/* WORDLENGTH */
  say "Look for WORDLENGTH OK"
/* These from the Rexx book. */
  if wordlength('Now is the time',2) \=2 then exit
  if wordlength('Now comes the time',2) \=5 then exit
  if wordlength('Now is the time',6) \=0 then exit
/* These from Mark Hessling. */
  if wordlength('This is certainly a test',1) \==  '4'    then exit
  if wordlength('This   is   certainly a test',2) \==  '2' then exit
  if wordlength('This is certainly a test',5) \==  '4'     then exit
  if wordlength('This is certainly a test ',5) \==  '4'    then exit
  if wordlength('This is certainly a test',6) \==  '0'     then exit
  if wordlength('',1) \==  '0'                             then exit
  if wordlength('',10) \==  '0'                            then exit
  say "WORDLENGTH OK"
