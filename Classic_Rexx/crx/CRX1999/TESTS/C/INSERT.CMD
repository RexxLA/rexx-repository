/* These from TRL */
  say "Look for INSERT OK"
  if insert(' ','abcdef',3) \== 'abc def'            then exit
  if insert('123','abc',5,6) \== 'abc  123   '       then exit
  if insert('123','abc',5,6,'+') \== 'abc++123+++'   then exit
  if insert('123','abc') \== '123abc'                then exit
  if insert('123','abc',,5,'-') \== '123--abc'       then exit
/* These from Mark Hessling. */
  if insert("abc","def") \==  "abcdef" then exit
  if insert("abc","def",2) \==  "deabcf" then exit
  if insert("abc","def",3) \==  "defabc" then exit
  if insert("abc","def",5) \==  "def  abc" then exit
  if insert("abc","def",5,,'*') \==  "def**abc" then exit
  if insert("abc" ,"def",5,4,'*') \==  "def**abc*" then exit
  if insert("abc","def",,0) \==  "def"       then exit
  if insert("abc","def",2,1) \==  "deaf"     then exit
  say "INSERT OK"
