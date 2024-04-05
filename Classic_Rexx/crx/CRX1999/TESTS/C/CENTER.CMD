/* These from TRL */
  say "Look for CENTER OK"
  if centre(abc,7) \== '  ABC  '             then exit
  if center(abc,7) \== '  ABC  '             then exit
  if center(abc,8,'-') \== '--ABC---'        then exit
  if center('The blue sky',8) \== 'e blue s' then exit
  if center('The blue sky',7) \== 'e blue '  then exit
/* These from Mark Hessling. */
  if center('****',8,'-')      \=='--****--'  then exit
  if center('****',7,'-')      \=='-****--'   then exit
  if center('*****',8,'-')     \=='-*****--'  then exit
  if center('*****',7,'-')     \=='-*****-'   then exit
  if center('12345678',4,'-')  \=='3456'      then exit
  if center('12345678',5,'-')  \=='23456'     then exit
  if center('1234567',4,'-')   \=='2345'      then exit
  if center('1234567',5,'-')   \=='23456'     then exit
  say "CENTER OK"
