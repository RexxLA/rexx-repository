/* ARG */
  say "Look for ARG OK"
/* These from the Rexx book. */
  call name;call namex 1,,2
/* These from Mark Hessling. */
   call testarg2 1,,2
   call testarg1
  say "ARG OK"
  return
name:
  if arg() \= 0                      then exit
  if arg(1) \== ''                   then exit
  if arg(2) \== ''                   then exit
  if arg(1,'e')                      then exit
  if arg(1,'O') \= 1                 then exit
  return
namex:
  if arg() \= 3                      then exit
  if arg(1) \== 1                    then exit
  if arg(2) \== ''                   then exit
  if arg(3) \= 2                     then exit
  if arg(999) \== ''                 then exit
  if arg(1,'e') \= 1                 then exit
  if arg(2,'E') \= 0                 then exit
  if arg(2,'O') \= 1                 then exit
  if arg(3,'o') \= 0                 then exit
  if arg(4,'o') \= 1                 then exit
  return

testarg1:
  if  arg()       \== "0"  then exit
  if  arg(1)      \== ""   then exit
  if  arg(2)      \== ""   then exit
  if  arg(1,"e")  \== "0"  then exit
  if  arg(1,"O")  \== "1"  then exit
   return

testarg2:
  if  arg()      \== "3"   then exit
  if  arg(1)     \== "1"   then exit
  if  arg(2)     \== ""    then exit
  if  arg(3)     \== "2"   then exit
  if  arg(4)     \== ""    then exit
  if  arg(1,"e") \== "1"   then exit
  if  arg(2,"E") \== "0"   then exit
  if  arg(2,"O") \== "1"   then exit
  if  arg(3,"o") \== "0"   then exit
  if  arg(4,"o") \== "1"   then exit
   return
