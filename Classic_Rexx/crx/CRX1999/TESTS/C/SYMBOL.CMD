/* SYMBOL */
  say "Look for SYMBOL OK"
/* These from the Rexx book. */
  drop A.3; j=3
  if symbol('J') \== 'VAR'     then exit
  if symbol(J) \== 'LIT'     then exit
  if symbol('a.j') \== 'LIT'     then exit
  if symbol(2) \== 'LIT'     then exit
  if symbol('*') \== 'BAD'     then exit
/* These from Mark Hessling. */
   parse value 'foobar' with alpha 1 beta 1 omega 1 gamma.foobar
   omega = 'FOOBAR'
  if symbol("HEPP") \==          "LIT"        then exit
  if symbol("ALPHA") \==         "VAR"        then exit
  if symbol("Un*x") \==          "BAD"        then exit
  if symbol("gamma.delta") \==   "LIT"        then exit
  if symbol("gamma.FOOBAR") \==  "VAR"        then exit
  if symbol("gamma.alpha") \==   "LIT"        then exit
  if symbol("gamma.omega") \==   "VAR"        then exit
  if symbol("gamma.Un*x") \==    "LIT"        then exit
  if symbol("Un*x.gamma") \==    "BAD"        then exit
  if symbol("!!") \==            "LIT"        then exit
  if symbol("") \==              "BAD"        then exit
  if symbol("00"x) \==           "BAD"        then exit
  if symbol("foo-bar") \==       "BAD"        then exit
  say "SYMBOL OK"
