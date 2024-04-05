/* TRANSLATE */
  say "Look for TRANSLATE OK"
/* These from the Rexx book. */
  if translate('abcdef') \== 'ABCDEF'  then exit
  if translate('abbc','&','b') \== 'a&&c'  then exit
  if translate('abcdef','12','ec') \== 'ab2d1f'  then exit
  if translate('abcdef','12','abcd','.') \== '12..ef'  then exit
  if translate('4123','abcd','1234') \== 'dabc'  then exit
/* These from Mark Hessling. */
  if translate("Foo Bar") \==  "FOO BAR"       then exit
  if translate("Foo Bar",,"") \==  "Foo Bar"   then exit
  if translate("Foo Bar","",) \==  "       "   then exit
  if translate("Foo Bar","",,'*') \==  "*******" then exit
  if translate("Foo Bar",xrange('01'x,'ff'x)) \==  "Gpp!Cbs" then exit
  if translate("","klasjdf","woieruw") \==  ""  then exit
  if translate("foobar","abcdef","fedcba") \==  "aooefr" then exit
  say "TRANSLATE OK"
