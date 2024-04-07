/* C2X */
  say "Look for C2X OK"
/* These from the Rexx book. */
/* EBCDIC
  if c2x('72s') \== 'F7F2A2' then exit
*/
  if c2x('0123'x) \== '0123' then exit
/* These from Mark Hessling. */
  if c2x( 'foobar') \==          '666F6F626172'       then exit
  if c2x( '' )\==                  ''                 then exit
  if c2x( '101'x )\==              '0101'             then exit
  if c2x( '0123456789abcdef'x )\== '0123456789ABCDEF' then exit
  if c2x( 'ffff'x )\==             'FFFF'             then exit
  if c2x( 'ffffffff'x )\==         'FFFFFFFF'         then exit
  say "C2X OK"
