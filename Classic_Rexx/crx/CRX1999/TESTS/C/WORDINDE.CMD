/* WORDINDEX */
  say "Look for WORDINDEX OK"
/* These from the Rexx book. */
  if wordindex('Now is the time',3) \=8 then exit
  if wordindex('Now is the time',6) \=0 then exit
/* These from Mark Hessling. */
  if wordindex('This is certainly a test',1) \==  '1' then exit
  if wordindex('  This is certainly a test',1) \==  '3' then exit
  if wordindex('This   is certainly a test',1) \==  '1' then exit
  if wordindex('  This   is certainly a test',1) \==  '3' then exit
  if wordindex('This is certainly a test',2) \==  '6' then exit
  if wordindex('This   is certainly a test',2) \==  '8' then exit
  if wordindex('This is   certainly a test',2) \==  '6' then exit
  if wordindex('This   is   certainly a test',2) \==  '8' then exit
  if wordindex('This is certainly a test',5) \==  '21'  then exit
  if wordindex('This is certainly a   test',5) \==  '23' then exit
  if wordindex('This is certainly a test  ',5) \==  '21' then exit
  if wordindex('This is certainly a test  ',6) \==  '0'  then exit
  if wordindex('This is certainly a test',6) \==  '0'    then exit
  if wordindex('This is certainly a test',7) \==  '0'    then exit
  if wordindex('This is certainly a test  ',7) \==  '0'   then exit
  say "WORDINDEX OK"
