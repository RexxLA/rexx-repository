/* CHANGESTR */
  say "Look for CHANGESTR OK"
  if changestr('bc','abcabcabc','xy') \== 'axyaxyaxy' then exit
  if changestr('bc','abcabcabc','') \== 'aaa'         then exit
  if changestr('','abcabcabc','xy') \== 'abcabcabc'   then exit
/* These from the Rexx book. */
/* These from Mark Hessling. */
    if changestr('a','fred','c')  \==  'fred'     then exit
    if changestr('','','x')  \==  ''              then exit
    if changestr('a','abcdef','x')  \==  'xbcdef' then exit
    if changestr('0','0','1')  \==  '1'           then exit
    if changestr('a','def','xyz')  \==  'def'     then exit
    if changestr('a','','x')  \==  ''             then exit
    if changestr('','def','xyz')  \==  'def'      then exit
    if changestr('abc','abcdef','xyz')  \==  'xyzdef'  then exit
    if changestr('abcdefg','abcdef','xyz')  \==  'abcdef' then exit
    if changestr('abc','abcdefabccdabcd','z')  \==  'zdefzcdzd' then exit
  say "CHANGESTR OK"
