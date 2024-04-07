/* VALUE */
  say "Look for VALUE OK"
/* These from the Rexx book. */
  drop A3; A33=7; K=3; fred='K'; list.5='?'
  if value('a'k) \== 'A3'     then exit
  if value('a'k||k) \== '7'     then exit
  if value('fred') \== 'K'     then exit
  if value(fred) \== '3'     then exit
  if value(fred,5) \== '3'     then exit
  if value(fred) \== '5'     then exit
  if value('LIST.'k) \== '?'     then exit
/* These from Mark Hessling. */
   x.a = 'asdf'
   x.b = 'foo'
   x.c = 'A'
   a = 'B'
   b = 'C'
   c = 'A'
  if value('a') \==  'B'       then exit
  if value(a) \==  'C'         then exit
  if value(c) \==  'B'         then exit
  if value('c') \==  'A'       then exit
  if value('x.A') \==  'foo'   then exit
  if value(x.B) \==  'B'       then exit
  if value('x.B') \==  'A'     then exit
  if value('x.'||a) \==  'A'   then exit
  if value(value(x.b)) \==  'C' then exit
   xyzzy = 'foo'
  if value('xyzzy') \==        'foo' then exit
  if value('xyzzy','bar') \==  'foo' then exit
  if value('xyzzy') \==        'bar' then exit
  if value('xyzzy','bar') \==  'bar' then exit
  if value('xyzzy') \==        'bar' then exit
  if value('xyzzy','foo') \==  'bar' then exit
  if value('xyzzy') \==        'foo' then exit
   xyzzy = 'void'
   if os = 'UNIX' Then
      envvar = '$xyzzy'
   else
      envvar = '%xyzzy%'
/* System dependent
   call value 'xyzzy', 'bar', 'SYSTEM'
  if value('xyzzy', 'bar', 'SYSTEM') \==  'bar' then exit
  if value('xyzzy',,       'SYSTEM') \==  'bar' then exit
  if value('xyzzy',      , 'SYSTEM') \==  'echo'(envvar) then exit
  if value('xyzzy', 'foo', 'SYSTEM') \==  'bar'          then exit
  if value('xyzzy', 'bar', 'SYSTEM') \==  'foo'          then exit
  if value('xyzzy',      , 'SYSTEM') \==  'echo'(envvar) then exit
  if value('xyzzy',      , 'SYSTEM') \==  'bar'          then exit
  if value('xyzzy', 'foo', 'SYSTEM') \==  'bar'          then exit
  if value('xyzzy',      , 'SYSTEM') \==  'echo'(envvar) then exit
*/
  say "VALUE OK"
