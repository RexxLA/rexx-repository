/* COUNTSTR */
  say "Look for COUNTSTR OK"
  if countstr('bc','abcabcabc') \= 3    then exit
  if countstr('aa','aaaa') \= 2         then exit
  if countstr('','a  a') \= 0           then exit
/* These from the Rexx book. */
/* These from Mark Hessling. */
    if countstr('','')  \==  0                    then exit
    if countstr('a','abcdef')  \==  1             then exit
    if countstr(0,0)  \==  1                      then exit
    if countstr('a','def')  \==  0                then exit
    if countstr('a','')  \==  0                   then exit
    if countstr('','def')  \==  0                 then exit
    if countstr('abc','abcdef')  \==  1           then exit
    if countstr('abcdefg','abcdef')  \==  0       then exit
    if countstr('abc','abcdefabccdabcd')  \==  3  then exit
  say "COUNTSTR OK"
