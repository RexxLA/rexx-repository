/* These from TRL */
  say "Look for OVERLAY OK"
  if overlay('.','abcdef',3,2) \== 'ab. ef'        then exit
  if overlay(' ','abcdef',3) \== 'ab def'          then exit
  if overlay('.','abcdef',3,2) \== 'ab. ef'        then exit
  if overlay('qq','abcd') \== 'qqcd'               then exit
  if overlay('qq','abcd',4) \== 'abcqq'            then exit
  if overlay('123','abc',5,6,'+') \== 'abc+123+++' then exit
/* These from Mark Hessling. */
  if overlay('foo', 'abcdefghi',3,4,'*') \==  'abfoo*ghi' then exit
  if overlay('foo', 'abcdefghi',3,2,'*') \==  'abfoefghi' then exit
  if overlay('foo', 'abcdefghi',3,4,) \==  'abfoo ghi'    then exit
  if overlay('foo', 'abcdefghi',3) \==  'abfoofghi'       then exit
  if overlay('foo', 'abcdefghi',,4,'*') \==  'foo*efghi'  then exit
  if overlay('foo', 'abcdefghi',9,4,'*') \==  'abcdefghfoo*' then exit
  if overlay('foo', 'abcdefghi',10,4,'*') \==  'abcdefghifoo*' then exit
  if overlay('foo', 'abcdefghi',11,4,'*') \==  'abcdefghi*foo*' then exit
  if overlay('', 'abcdefghi',3) \==  'abcdefghi'                then exit
  if overlay('foo', '',3) \==  '  foo'                          then exit
  if overlay('', '',3,4,'*') \==  '******'                      then exit
  if overlay('', '') \==  ''                                    then exit
  say "OVERLAY OK"
