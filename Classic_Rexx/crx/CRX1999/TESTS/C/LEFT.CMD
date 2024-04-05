/* These from TRL */
  say "Look for LEFT OK"
  if left('abc d',8) \== 'abc d   ' then exit
  if left('abc d',8,'.') \== 'abc d...' then exit
  if left('abc  def',7) \== 'abc  de' then exit
/* These from Mark Hessling. */
  if left("foobar",1) \==      "f"           then exit
  if left("foobar",0) \==      ""            then exit
  if left("foobar",6) \==      "foobar"      then exit
  if left("foobar",8) \==      "foobar  "    then exit
  if left("foobar",8,'*') \==  "foobar**"    then exit
  if left("foobar",1,'*') \==  "f"           then exit
  say "LEFT OK"
