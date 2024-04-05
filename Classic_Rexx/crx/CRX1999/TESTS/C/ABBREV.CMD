/* ABBREV */
  say "Look for ABBREV OK"
/* These from the Rexx book. */
  if \abbrev('Print','Pri')          then exit
  if  abbrev('PRINT','Pri')          then exit
  if  abbrev('PRINT','PRI',4)        then exit
  if  abbrev('PRINT','PRY')          then exit
  if \abbrev('PRINT','')             then exit
  if  abbrev('PRINT','',1)           then exit
/* These from Mark Hessling. */
  if \abbrev('information','info',4) then exit
  if \abbrev('information','',0)     then exit
  if  abbrev('information','Info',4) then exit
  if  abbrev('information','info',5) then exit
  if  abbrev('information','info ')  then exit
  if \abbrev('information','info',3) then exit
  if  abbrev('info','information',3) then exit
  if  abbrev('info','info',5)        then exit
  say "ABBREV OK"
