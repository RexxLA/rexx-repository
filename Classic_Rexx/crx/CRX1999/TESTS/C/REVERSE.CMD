/* REVERSE */
  say "Look for REVERSE OK"
/* These from the Rexx book. */
  if reverse('ABc.') \== '.cBA'      then exit
  if reverse('XYZ ') \== ' ZYX'      then exit
  if reverse('Tranquility') \== 'ytiliuqnarT'      then exit
/* These from Mark Hessling. */
  if reverse("foobar") \==     "raboof"                 then exit
  if reverse("") \==           ""                       then exit
  if reverse("fubar") \==      "rabuf"                  then exit
  if reverse("f") \==          "f"                      then exit
  if reverse("  foobar ") \==  " raboof  "              then exit
  say "REVERSE OK"
