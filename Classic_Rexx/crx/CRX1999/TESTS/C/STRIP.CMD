/* STRIP */
  say "Look for STRIP OK"
/* These from the Rexx book. */
  if strip('  ab c  ') \== 'ab c'       then exit
  if strip('  ab c  ','L') \== 'ab c  ' then exit
  if strip('  ab c  ','t') \== '  ab c' then exit
  if strip('12.7000',,0) \== '12.7'     then exit
  if strip('0012.7000',,0) \== '12.7'   then exit
/* These from Mark Hessling. */
  if strip("  foo   bar   ") \==           "foo   bar"      then exit
  if strip("  foo   bar   ",'L') \==       "foo   bar   "   then exit
  if strip("  foo   bar   ",'T') \==       "  foo   bar"    then exit
  if strip("  foo   bar   ",'B') \==       "foo   bar"      then exit
  if strip("  foo   bar   ",'B','*') \==   "  foo   bar   " then exit
  if strip("  foo   bar",,'r') \==         "  foo   ba"     then exit
  say "STRIP OK"
