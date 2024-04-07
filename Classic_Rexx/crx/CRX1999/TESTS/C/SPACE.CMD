/* SPACE */
  say "Look for SPACE OK"
/* These from the Rexx book. */
  if space('abc  def  ') \== 'abc def'        then exit
  if space('  abc  def',3) \== 'abc   def'    then exit
  if space('abc  def  ',1) \== 'abc def'      then exit
  if space('abc  def  ',0) \== 'abcdef'       then exit
  if space('abc  def  ',2,'+') \== 'abc++def' then exit
/* These from Mark Hessling. */
  if space(" foo ")                \== "foo"               then exit
  if space("  foo")                \== "foo"               then exit
  if space("foo  ")                \== "foo"               then exit
  if space("  foo  ")              \== "foo"               then exit
  if space(" foo bar ")            \== "foo bar"           then exit
  if space("  foo  bar  ")         \== "foo bar"           then exit
  if space(" foo bar " , 2)          \== "foo  bar"        then exit
  if space(" foo bar ",,"-")       \== "foo-bar"           then exit
  if space("  foo  bar  ",2,"-")   \== "foo--bar"          then exit
  if space(" f-- b-- ",2,"-")      \== "f----b--"          then exit
  if space(" f o o   b a r ",0)    \== "foobar"            then exit
  say "SPACE OK"
